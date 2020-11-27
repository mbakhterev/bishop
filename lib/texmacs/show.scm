(define-module (texmacs show)
               #:use-module (ice-9 optargs)
               #:use-module (frame core) 
               #:export (tabulate))

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
