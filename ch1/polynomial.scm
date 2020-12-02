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
  ; (display (list "transposing" M))
  ; (newline)
  (when (not (= 2 (array-rank M)))
    (error "Expecting matrix. Given something with rank:" (array-rank M)))

  (let* ((s (array-dimensions M))
         (T (make-typed-array (array-type M) *unspecified* (cadr s) (car s))))
    ; (display (list s (cadr s) (car s)))
    ; (newline)
    (array-index-map! T (lambda (i j) (array-ref M j i)))
    T))
