;;; Грязные хаки, чтобы работать с библиотеками

(when (not (and (file-exists? "ch1/polynomial.scm")
                (file-exists? "lib/csv")
                (file-exists? "data")))
  (error "Load this source with current working directory set to repository root"))

(when (let loop ((l %load-path))
        (cond ((null? l) #t)
              ((string=? (car l) "lib") #f)
              (else (loop (cdr l)))))
  (set! %load-path (cons "lib" %load-path)))

;;; Хаки закончились

(use-modules (csv csv))

(define (show-filename) (object->tree filename))

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

; Структура frame будет такая: пара из вектора имён колонок и вектора из
; векторов значений
(define (reframe raw)
  (let* ((header (car raw))
         (frame (cdr raw))
         (m (vector-length header))
         (n (length frame)))
    (cons (map-vector (lambda (s) (string-trim-both s char-set:whitespace))
                      header)
          header)))

(define frame:header car)
(define frame:data cdr)
