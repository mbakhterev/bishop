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
             (srfi srfi-13)
             (csv csv))

(define (skip-keys args . keys)
  (let loop ((l args))
    (if (null? l)
        '()
        (let ((v (car l)))
          (if (member v keys)
              (loop (cddr l))
              (cons v (loop (cdr l))))))))

(define (map-vector f v)
  (let* ((n (vector-length v))
         (u (make-vector n)))
    (do ((i 0 (1+ i)))
        ((>= i n))
        (vector-set! u i (f (vector-ref v i))))
    u))

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

    (do ((r raw (cdr r)) (i 0 (1+ i))) ((>= i n))
      (do ((j 0 (1+ j))) ((>= j m))
        (f32vector-set! (vector-ref T j)
                        i
                        (f (vector-ref (car r) j)))))

    T))

(define frame:header car)
(define frame:data cdr) 
(define (frame:width f) (vector-length (frame:header f)))
(define (frame:depth f) (f32vector-length (vector-ref (frame:data f) 0))) 

(define (getter d) (lambda (i j) (f32vector-ref (vector-ref d j) i)))
(define (frame:get f) (getter (frame:data f)))

; Структура frame будет такая: пара из вектора имён колонок и вектора из
; векторов значений
(define (reframe raw)
    (cons (map-vector (lambda (s) (string-trim-both s char-set:whitespace))
                      (frame:header raw))
          (vectorize (lambda (s) (string->number (string-trim-both s char-set:whitespace)))
                     (frame:data raw))))

(define (correct-index i from upto)
  (if (not (negative? i))
      (min (- upto 1) (max from i))
      (max from (+ upto i))))

(define* (tabulate frame
                   #:key
                   (font-size 'small)
                   (from 0)
                   (upto (+ (correct-index from 0 (frame:depth frame)) 15)))
  (let* ((n (frame:depth frame))
         (f (correct-index from 0 n))
         (t (correct-index upto f n))
         (h (frame:header frame))
         (m (vector-length h))
         (get (frame:get frame))
         (cell (lambda (v) (quasiquote (cell (unquote v)))))
         (row (lambda (r prefix)
                (quasiquote
                  (row (unquote-splicing (cons prefix (reverse r)))))))
         (gather (lambda (i) (do ((j 0 (1+ j))
                                  (r '() (cons (cell (format #f "~f" (get i j)))
                                               r)))
                                 ((>= j m) (row r (number->string i))))))
         (header (do ((j 0 (1+ j))
                      (r '()  (cons (cell (vector-ref h j)) r)))
                     ((>= j m) (row r ""))))
         (rows (do ((i f (1+ i))
                    (r '() (cons (gather i) r)))
                   ((> i t) (reverse r)))))
    (object->tree (quasiquote
                    ((unquote font-size)
                     (wide-tabular
                       (table (unquote-splicing (cons header rows)))))))))

(define (field-index frame)
  (let* ((positions (make-hash-table))
         (h (frame:header frame))
         (m (vector-length h)))
    (do ((i 0 (1+ i))) ((>= i m) positions)
      (format #t "indexing. i: ~a~%" i)
      (hash-set! positions (vector-ref h i) i))))

(define (select-fields frame fields)
  (format #t "selecting from frame: ~a~%" (frame:header frame))
  (let* ((positions (field-index frame))
         (d (frame:data frame))
         (m (vector-length fields))
         (v (make-vector m)))
    (do ((i 0 (1+ i))) ((>= i m) v)
      (let* ((k (vector-ref fields i))
             (j (hash-ref positions k)))
        (format #t "picking field: ~a(~a)~%" k j)
        (if (not j)
            (error "No field:" k)
            (vector-set! v i (vector-ref d j)))))))

; FIXME: Надо бы проверять повторы
(define* (pick frame #:key (copy #t) . fields)
  (let ((cp (if (not copy)
                identity
                (lambda (v) (let ((u (make-f32vector (f32vector-length v))))
                              (array-copy! v u)
                              u))))
        (h (list->vector (skip-keys fields #:copy))))
    (format #f "picking. header: ~a~%" h)
    (cons h (vector-map! cp (select-fields frame h))))) 

(define (vector-map! f v) (let ((m (vector-length v)))
                            (do ((i 0 (1+ i))) ((>= i m) v)
                              (vector-set! v i (f (vector-ref v i))))))

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

(define (frame-map! frame field . fields) #f)
