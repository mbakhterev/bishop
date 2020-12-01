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

(define show object->tree)

(load "../lib/frame/core.scm")

(load "../lib/texmacs/show.scm")

; (display frame-map)
; (newline)
; 
; (display pick)
; (newline)
