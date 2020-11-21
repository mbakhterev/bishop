(load "../ch1/polynomial.scm")

(define raw-data (load-csv "data/vpered-7-all.csv"))
(define frame-1 (reframe raw-data))

(define frame-2 (pick frame-1 "time" "axRaw_1"))

; (write )
; (newline)

(format #t "header width: ~a~%data width: ~a~%"
        (vector-length (frame:header frame-1))
        (vector-length (frame:data frame-1)))

; (define* (fn x #:key (hello 'world) (y 'from) (z 'space) . rest)
;   (cons* x hello y z (skip-keys rest #:hello #:y #:z)))
; 
; (define* (gn x #:optional (y 10) (z (+ x y))) (list x y z))
; 
; (display (skip-keys '(#:k1 a #:k3 b #:k2 c d e) #:k1 #:k2))
; (newline)
; 
; (define* (fn #:optional (x 10) (y (+ 1 x)) #:key (hello 'world))
;   (display (list x y hello))
;   (newline))
; 
; (define* (gn #:key (hello 'world) #:optional (x 10) (y (+ 1 x)) )
;   (display (list x y hello))
;   (newline))
; 
; (fn)
; (fn 13 14)
; (fn 13 #:hello 'Jupiter 14)
; (fn 13 #:hello 'Jupiter) 

(hash-for-each (lambda k (display k) (newline)) (field-index frame-1))
(newline)
(hash-for-each (lambda k (display k) (newline)) (field-index frame-2))
(newline)

(display (vector-length (select-fields frame-1 #("time" "axRaw_1"))))
(newline)

(display frame-2)
(newline)

(display (frame-map cons frame-2 "time" "axRaw_1"))
(newline) 

(display -inf)
(newline)
