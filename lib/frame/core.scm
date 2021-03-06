(define-module (frame core)
               #:use-module (csv csv)
               #:use-module (ice-9 optargs)
               #:use-module (ice-9 receive)
               #:export (frame:header frame:data frame:width frame:depth frame:get frame:columns
                         load-csv reframe
                         pick
                         frame-map frame-map! frame-fold))

(define (vector-map f v) (let* ((n (vector-length v))
                                (u (make-vector n)))
                           (do ((i 0 (1+ i)))
                             ((>= i n) u)
                             (vector-set! u i (f (vector-ref v i))))))

(define (vector-map! f v) (let ((m (vector-length v)))
                            (do ((i 0 (1+ i))) ((>= i m) v)
                              (vector-set! v i (f (vector-ref v i))))))

(define (load-csv f)
  (let* ((reader (make-csv-reader #\,))
         (p (open-file f "r"))
         (raw (reader p)))
    (close-input-port p)
    raw))

(define (vectorize f raw)
  (let* ((n (min (length raw)))
         (m (vector-length (car raw)))
         (T (make-vector m)))
    (do ((j 0 (1+ j))) ((>= j m))
      (vector-set! T j (make-f32vector n)))

    (do ((r raw (cdr r)) (i 0 (1+ i))) ((>= i n) T)
      (do ((j 0 (1+ j))) ((>= j m))
        (f32vector-set! (vector-ref T j)
                        i
                        (f (vector-ref (car r) j)))))))

(define frame:header car)
(define frame:data cdr) 
(define (frame:width f) (vector-length (frame:header f)))
(define (frame:depth f) (f32vector-length (vector-ref (frame:data f) 0))) 

(define (getter d) (lambda (i j) (f32vector-ref (vector-ref d j) i)))
(define (frame:get f) (getter (frame:data f)))

(define (row-setter d)
  (let ((m (vector-length d)))
    (lambda (i vals)
      ; (format #t "setting: i ~a; vals: ~a~%" i vals)
      (do ((v vals (cdr vals)) (j 0 (1+ j))) ((or (null? vals) (>= j m)))
        (f32vector-set! (vector-ref d j) i (car v))))))

; Структура frame будет такая: пара из вектора имён колонок и вектора из
; векторов значений
(define (reframe raw)
    (cons (vector-map (lambda (s) (string-trim-both s char-set:whitespace))
                      (frame:header raw))
          (vectorize (lambda (s) (string->number (string-trim-both s char-set:whitespace)))
                     (frame:data raw)))) 

(define (field-index frame)
  (let* ((positions (make-hash-table))
         (h (frame:header frame))
         (m (vector-length h)))
    (do ((i 0 (1+ i))) ((>= i m) positions)
      ; (format #t "indexing. i: ~a~%" i)
      (hash-set! positions (vector-ref h i) i))))

(define (select-fields frame fields)
  ; (format #t "selecting from frame: ~a~%" (frame:header frame))
  (let* ((positions (field-index frame))
         (d (frame:data frame))
         (m (vector-length fields))
         (v (make-vector m)))
    (do ((i 0 (1+ i))) ((>= i m) v)
      (let* ((k (vector-ref fields i))
             (j (hash-ref positions k)))
        ; (format #t "picking field: ~a(~a)~%" k j)
        (if (not j)
            (error "No field:" k)
            (vector-set! v i (vector-ref d j)))))))

(define (skip-keys args . keys)
  (let loop ((l args))
    (if (null? l)
        '()
        (let ((v (car l)))
          (if (member v keys)
              (loop (cddr l))
              (cons v (loop (cdr l))))))))

; FIXME: Надо бы проверять повторы
(define* (pick frame #:key (copy #t) . fields)
  (let ((cp (if (not copy)
                identity
                (lambda (v) (let ((u (make-f32vector (f32vector-length v))))
                              (array-copy! v u)
                              u))))
        (h (list->vector (skip-keys fields #:copy))))
    ; (format #f "picking. header: ~a~%" h)
    (cons h (vector-map! cp (select-fields frame h)))))  

(define (map-applicator f D)
  (let ((get (getter D)))
    (lambda (i)
      (do ((j (- (vector-length D) 1) (- j 1))
           (args '() (cons (get i j) args)))
          ((negative? j) (apply f args))))))

(define (fold-applicator f D)
  (let ((get (getter D)))
    (lambda (r i)
      (do ((j (- (vector-length D) 1) (- j 1))
           (args '() (cons (get i j) args)))
          ((negative? j) (apply f r args))))))

(define (frame-map proc frame field . fields)
  (let* ((a (map-applicator proc (select-fields frame (list->vector (cons field fields)))))
         (v (make-vector (frame:depth frame)))
         (n (vector-length v)))
    (do ((i 0 (1+ i))) ((>= i n) v)
      (vector-set! v i (a i)))))

(define (frame-fold proc init frame field . fields)
  (let ((a (fold-applicator proc (select-fields frame (list->vector (cons field fields)))))
        (n (frame:depth frame)))
    (do ((i 0 (1+ i)) (r init (a r i))) ((>= i n) r))))

(define (frame-map! proc frame field . fields)
  (let* ((d (select-fields frame (list->vector (cons field fields))))
         (a (map-applicator proc d))
         (n (frame:depth frame))
         (row-set! (row-setter d)))
    (do ((i 0 (1+ i))) ((>= i n))
      (receive (. results) (a i)
               (row-set! i results))))) 

; FIXME: Странная своей неэффективностью процедура. Конечно, у нас не Clojure, к
; сожалению, и не получится apply применять к вектору
(define (frame:columns frame field . fields)
  (vector->list (select-fields frame (list->vector (cons field fields)))))
