(load "../ch1/polynomial.scm")

(define raw-data (load-csv "data/vpered-7-all.csv"))
(define frame (reframe raw-data))

(write (pick frame "time" "axRaw_101"))
(newline)

(format #t "header width: ~a~%data width: ~a~%"
        (vector-length (frame:header frame))
        (vector-length (frame:data frame)))

(define* (fn x #:key (hello 'world) (y 'from) (z 'space) . rest)
  (cons* x hello y z (skip-keys rest #:hello #:y #:z)))

(define* (gn x #:optional (y 10) (z (+ x y))) (list x y z))

(display (skip-keys '(#:k1 a #:k3 b #:k2 c d e) #:k1 #:k2))
(newline)

(define* (fn #:optional (x 10) (y (+ 1 x)) #:key (hello 'world))
  (display (list x y hello))
  (newline))

(define* (gn #:key (hello 'world) #:optional (x 10) (y (+ 1 x)) )
  (display (list x y hello))
  (newline))

(fn)
(fn 13 14)
(fn 13 #:hello 'Jupiter 14)
(fn 13 #:hello 'Jupiter) 
