;;; Грязные хаки, чтобы работать с библиотеками

(if (not (and (file-exists? "ch1/polynomial.scm")
              (file-exists? "lib/csv")
              (file-exists? "data")))
    (error "Load this source with current working directory set to repository root"))

(if (let loop ((l %load-path))
      (cond ((null? l) #t)
            ((string=? (car l) "lib") #f)
            (else (loop (cdr l)))))
    (set! %load-path (cons "lib" %load-path)))

;;; Хаки закончились

; (use-syntax (ice-9 syncase))

(use-modules (ice-9 optargs)
             (ice-9 receive)
             (srfi srfi-13)
             (frame core)
             (texmacs show))

; (load "../lib/frame/core.scm")
; (load "../lib/texmacs/show.scm")

(define (vandermonde X m)
  (let* ((n (f32vector-length X))
         (A (make-typed-array 'f32 *unspecified* n m)))
    (do ((i 0 (1+ i))) ((>= i n))
      (array-set! A 1.0 i 0))

    (do ((j 0 (1+ j))) ((>= j (- m 1)) A)
      (do ((i 0 (1+ i))) ((>= i n))
        (array-set! A
                    (* (array-ref A i j) (f32vector-ref X i))
                    i
                    (1+ j))))))

(define (matrix-transpose M)
  (when (not (= 2 (array-rank M)))
    (error "Expecting matrix. Given something with rank:" (array-rank M)))

  (let* ((s (array-dimensions M))
         (T (make-typed-array (array-type M) *unspecified* (cadr s) (car s))))
    (array-index-map! T (lambda (i j) (array-ref M j i)))
    T))

(define (matrix-transpose-shared M)
  (when (not (= 2 (array-rank M)))
    (error "Expecting matrix. Given something with rank:" (array-rank M)))
  (transpose-array M 1 0))

(define (matrix-mul A B)
  (when (not (= 2 (array-rank A) (array-rank B)))
    (error "Expecting matrices. Given something with ranks:"
           (array-rank A)
           (array-rank B)))

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
                                             (sum 0.0 (+ sum (* (array-ref A i k)
                                                                (array-ref B k j)))))
                                            ((>= k M) sum))))
      R)))

(define (array-clone A)
  (let ((R (apply
             make-typed-array (array-type A) *unspecified* (array-dimensions A))))
    (array-copy! A R)
    R))

(define (matrix-vector-mul A v)
  (when (not (and (= 1 (array-rank v))
                  (= 2 (array-rank A))))
    (error "Expecting matrix and vector. Given something with ranks:"
           (array-rank A)
           (array-rank v)))

  (let* ((dim-A (array-dimensions A))
         (dim-v (array-dimensions v))
         (type (array-type A))
         (L (car dim-A))
         (M (cadr dim-A)))
    (when (not (and (= M (car dim-v))
                    (eq? type (array-type v))))
      (error "Vector and matrix shapes mismatch:"
             (list type L M) (list (array-type v) (car dim-v))))

    ; (display (list type dim-A dim-v L M))
    ; (newline)
    (let ((R (make-typed-array type *unspecified* L)))
      (display R)
      (newline)
      (array-index-map! R (lambda (i) (do ((k 0 (1+ k))
                                           (sum 0.0 (+ sum (* (array-ref A i k)
                                                              (array-ref v k)))))
                                          ((>= k M) sum))))
      R)))

(define (matrix-decompose-lup A tolerance)
  (when (not (= 2 (array-rank A)))
    (error "Expecting matrix. Given something with rank:" (array-rank A)))

  (let* ((dim-A (array-dimensions A))
         (L (car dim-A))
         (M (cadr dim-A))

         (P-data (make-u32vector (1+ L)))
         (P (lambda (i) (u32vector-ref P-data i)))
         (P! (lambda (i v) (u32vector-set! P-data i v))) 

         (LU-data (make-typed-array (array-type A) *unspecified* L M))
         (LU (lambda (i j) (array-ref LU-data i j)))
         (LU! (lambda (i j v) (array-set! LU-data v i j)))

         (swap (lambda (i j) (let ((pi (P i))
                                   (pj (P j))
                                   (n-swaps (P L)))
                               (P! i pj)
                               (P! j pi)
                               (P! L (1+ n-swaps)))))

         (pivot (lambda (i) (let loop ((k i) (max-abs 0.0) (i-max i))
                              (if (>= k L)
                                  (values max-abs i-max)
                                  (let ((v (abs (LU (P k) i))))
                                    (if (< max-abs v)
                                        (loop (1+ k) v k)
                                        (loop (1+ k) max-abs i-max))))))))
    (array-index-map! P-data (lambda (i) i))
    (array-copy! A LU-data)

    (do ((i 0 (1+ i))) ((>= i L) (values LU-data P-data))
      (display i)
      (newline)
      (display LU-data)
      (newline)
      (force-output)
      (receive (max-abs i-max) (pivot i)
        (display (list max-abs i-max i))
        (newline)
        (when (< max-abs tolerance)
          (error "Matrix is degenerate: pivot value below tolerance:" max-abs))

        (when (not (= i-max i)) (swap i-max i))

        ; Строки матрицы переставляются для выбора более качественного pivot.
        ; Перестановка учитывается в таблице P, оттуда же выбираются индексы
        ; актуальные индексы строк ri и rj.
        (let* ((ri (P i))
               (Lii (LU ri i)))
          (display (list ri Lii))
          (newline)
          (do ((j (1+ i) (1+ j))) ((>= j L))
            (let* ((rj (P j))
                   (Lji (/ (LU rj i) Lii)))
              (display (list i rj Lji))
              (newline)
              (LU! rj i Lji)
              (display (LU rj i))
              (newline)
              (do ((k (1+ i) (1+ k))) ((>= k M))
                (LU! rj k (- (LU rj k) (* Lji (LU rj k))))))))))))

(define (matrix-inverse A)
  #t
  )
