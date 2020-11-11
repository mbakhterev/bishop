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

(use-modules ; (srfi srfi-1)
             (srfi srfi-13)
             (csv csv))

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
(define (frame:get f)
  (let ((d (frame:data f)))
    (lambda (i j)
      (f32vector-ref (vector-ref d j) i))))

; Структура frame будет такая: пара из вектора имён колонок и вектора из
; векторов значений
(define (reframe raw)
    (cons (map-vector (lambda (s) (string-trim-both s char-set:whitespace))
                      (frame:header raw))
          (vectorize (lambda (s) (string->number (string-trim-both s char-set:whitespace)))
                     (frame:data raw))))


(define (tabulate frame font-size from upto)
  (let* ((f (if from from 0))
         (t (if upto upto (f32vector-length (vector-ref (frame:data frame) 0))))
         (h (frame:header frame))
         (m (vector-length h))
         (get (frame:get frame))
         (cell (lambda (v) (quasiquote (cell (unquote v)))))
         (row (lambda (r) (quasiquote (row (unquote-splicing (reverse r))))))
         (gather (lambda (i) (do
                               ((j 0 (1+ j))
                                (r '() (cons (cell (format #f "~,2f" (get i j)))
                                             r)))
                               ((>= j m) (row r)))))
         (header (do
                   ((j 0 (1+ j))
                    (r '()  (cons (cell (vector-ref h j)) r)))
                   ((>= j m) (row r))))
         (rows (do
                 ((i f (1+ i))
                  (r '() (cons (gather i) r)))
                 ((>= i t) (reverse r)))))
    (quasiquote ((unquote font-size) (wide-tabular
                                       (table (unquote-splicing (cons header rows))))))))

; FIXME: Надо бы проверять повторы
(define (pick frame . fields)
  (let* ((positions (make-hash-table))
         (h (frame:header frame))
         (d (frame:data frame))
         (m (vector-length h))
         (ph (list->vector fields))
         (pm (vector-length ph))
         (pd (make-vector pm)))
    (do ((i 0 (1+ i))) ((>= i m))
      (hash-set! positions (vector-ref h i) i))

    (do ((i 0 (1+ i))) ((>= i pm) (cons ph pd))
      (let* ((k (vector-ref ph i))
             (j (hash-ref positions k)))
        (if (not j)
            (error "No such key:" k)
            (vector-set! pd i (vector-ref d j)))))))

; Тесты
; (define raw-data (load-csv "data/vpered-7-all.csv"))
; (define frame (reframe raw-data))
; 
; (write frame)
; (newline)
; 
; (format #t "header width: ~a~%data width: ~a~%"
;         (vector-length (frame:header frame))
;         (vector-length (frame:data frame)))
