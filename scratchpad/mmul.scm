(use-modules (ice-9 receive))

(define (matrix-mul A B)
  (when (not (= 2 (array-rank A) (array-rank B)))
    (error "Expecting matrices. Given values with shapes:"
           (array-dimensions A)
           (array-dimensions B)))

  (let* ((dim-A (array-dimensions A))
         (dim-B (array-dimensions B))
         (type (array-type A))
         (L (car dim-A))
         (M (cadr dim-A))
         (N (cadr dim-B)))
    (when (not (and (= M (car dim-B))
                    (eq? type (array-type B))))
      (error "Matrix shapes mismatch:" (list type L M) (list (array-type B) (car dim-B) N)))

    (let ((R (make-typed-array type *unspecified* L N)))
      (array-index-map! R (lambda (i j) (do ((k 0 (1+ k))
                                             (sum 0 (+ sum (* (array-ref A i k)
                                                              (array-ref B k j)))))
                                            ((>= k M) sum))))
      R)))

; Little access helpers
(define (u32vector-load V) (lambda (i) (u32vector-ref V i)))
(define (u32vector-store V) (lambda (i v) (u32vector-set! V i v)))

(define (matrix-load M) (lambda (i j) (array-ref M i j)))
(define (matrix-store M) (lambda (i j v) (array-set! M v i j)))

; Recursive Cormen-style algorithm
(define (matrix-decompose-lup A tolerance)
  (when (not (and (= 2 (array-rank A))
                  (apply = (array-dimensions A))))
    (error "Expecting square matrix. Given value with shape:" (array-dimensions A)))

  (let* ((N (car (array-dimensions A)))

         (P-data (make-u32vector (1+ N)))
         (P (u32vector-load P-data))
         (P! (u32vector-store P-data)) 

         (LU-data (make-typed-array (array-type A) *unspecified* N N))
         (LU (matrix-load LU-data))
         (LU! (matrix-store LU-data))

         (swap (lambda (i j) (let ((pi (P i))
                                   (pj (P j))
                                   (n-swaps (P N)))
                               (P! i pj)
                               (P! j pi)
                               (P! N (1+ n-swaps)))))

         (pivot (lambda (i) (let loop ((k i) (max-abs 0) (i-max i))
                              (if (>= k N)
                                  (values max-abs i-max)
                                  (let ((v (abs (LU (P k) i))))
                                    (if (> v max-abs)
                                        (loop (1+ k) v k)
                                        (loop (1+ k) max-abs i-max)))))))

         (subtract-row (lambda (c j α i) (do ((k c (1+ k))) ((>= k N))
                                           (LU! j k (- (LU j k) (* α (LU i k))))))))
    (array-index-map! P-data (lambda (i) i))
    (array-copy! A LU-data)

    (do ((i 0 (1+ i))) ((>= i N) (values LU-data P-data))

      (receive (max-abs i-max) (pivot i)
        (when (< max-abs tolerance)
          (error "Matrix is degenerate: pivot value below tolerance:" max-abs))

        (when (not (= i-max i)) (swap i-max i))

        (let* ((ri (P i))
               (Uii (LU ri i)))
          (do ((j (1+ i) (1+ j))) ((>= j N))
            (let* ((rj (P j))
                   (Lji (/ (LU rj i) Uii)))
              (LU! rj i Lji)
              (subtract-row (1+ i) rj Lji ri))))))))


; Dumb naive LUP recomposition
(define (matrix-lup-compose LU P)
  (let ((L (lambda (i k) (if (< k i) (array-ref LU (u32vector-ref P i) k) (if (= k i) 1 0))))
        (U (lambda (k j) (if (<= k j) (array-ref LU (u32vector-ref P k) j) 0)))
        (R (apply make-typed-array (array-type LU) *unspecified* (array-dimensions LU))))
    (array-index-map!
      R
      (lambda (i j)
        (do ((k 0 (1+ k))
             (sum 0 (+ sum (* (L i k) (U k j)))))
          ((>= k (car (array-dimensions LU))) sum))))
    R))

(define (matrix-inverse A)
  (when (not (and (= 2 (array-rank A))
                  (apply = (array-dimensions A))))
    (error "Expecting square matrix. Given value with shape:" (array-dimensions A)))

  (let* ((N (car (array-dimensions A)))
         (R-data (make-typed-array (array-type A) *unspecified* N N)))
    (receive (LU-data P-data) (matrix-decompose-lup A 1e-15)
      (let ((R (matrix-load R-data))
            (R! (matrix-store R-data))
            (P (u32vector-load P-data))
            (LU (matrix-load LU-data)))
        (do ((j 0 (1+ j))) ((>= j N) R-data)
          (do ((i 0 (1+ i))) ((>= i N))
            (let ((ri (P i)))
              (R! i j (if (= j ri) 1 0))

              (do ((k 0 (1+ k))
                   (v (R i j) (- v (* (LU ri k) (R k j)))))
                  ((>= k i) (R! i j v)))))

          (do ((i (1- N) (1- i))) ((negative? i))
            (let ((ri (P i)))
              (do ((k (1+ i) (1+ k))
                   (v (R i j) (- v (* (LU ri k) (R k j)))))
                  ((>= k N) (R! i j v)))

              (R! i j (/ (R i j) (LU ri i))))))))))

; Testing 

(define (2d-semi-random L M bound)
  (let ((time (gettimeofday)))
    (set! *random-state* (seed->random-state (+ (car time)
                                                (cdr time)))))

  (let ((M (make-typed-array #t *unspecified* L M)))
    (array-index-map! M (lambda (i j) (random bound)))
    M))

(define X (2d-semi-random 4 4 10000000000))

(define (display-rows A)
  (for-each (lambda (r) (display r) (newline)) (array->list A))
  (newline))

(display-rows X)

(receive (LU P) (matrix-decompose-lup X 1e-15)
         (display-rows (matrix-lup-compose LU P))
         (for-each (lambda (p) (display p) (newline)) (u32vector->list P))
         (newline))

(display-rows (matrix-mul X (matrix-inverse X)))

