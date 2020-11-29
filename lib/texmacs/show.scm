(define-module (texmacs show)
               #:use-module (ice-9 optargs)
               #:use-module (frame core) 
               #:export (tabulate plotter-2d dots graph function-graph))

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
    (quasiquote
      ((unquote font-size)
       (wide-tabular
         (table (unquote-splicing (cons header rows)))))))) 

; Процедура plotter-2d должна сформировать tm-конструкцию, которая описывает
; график. У этой конструкции будут различные параметры, которые нужно учесть при
; изображении различных объектов. Например, масштабы по различным осям, по
; которым надо бы пересчитывать координаты точек тех объектов, которые надо
; изобразить.  Не хотелось бы, чтобы об этих параметрах заботился пользователь,
; то есть, чтобы он вручную передавал бы эти параметры в конструкторы
; изображаемых объектов (dots и прочие). Поэтому, plotter-2d породит процедуру,
; которая на вход будет брать список процедур, генерирующие объекты для
; изображения по данным пользователя, с учётом параметров изображения. Эти
; процедуры будут порождены конструкторами различных изображаемых сущностей
; (dots и прочие).

(define* (plotter-2d #:key
                     (cells '(20.0 . 10.0))
                     (x-scale (cons (/ (car cells) 2.0) (/ (car cells) 2.0)))
                     (y-scale (cons (/ (cdr cells) 2.0) (/ (cdr cells) 2.0)))
                     (pivot (cons (/ (car cells) 2.0) (/ (cdr cells) 2.0))))
  (let* ((x car)
         (y cdr)
         (gw (lambda (v) (format #f "~fgw" v)))
         (gh (lambda (v) (format #f "~fgh" v)))
         (x-cells (* 1.0 (car cells)))
         (y-cells (* 1.0 (cdr cells)))
         (cell-width (gw (/ 1.0 x-cells)))
         (drawing-height (gw (/ y-cells x-cells)))
         (x-pivot (/ (x pivot) x-cells))
         (y-pivot (/ (y pivot) y-cells))
         (x-scale-factor 1.0)
         (y-scale-factor 1.0))

    ; (display (list cells scales pivot x-pivot y-pivot))
    ; (newline)
    (lambda images
      (quasiquote
        (with "gr-geometry" (tuple "geometry" "1.0gw" (unquote drawing-height) "center")
              "gr-frame" (tuple "scale"
                                (unquote cell-width) 
                                (tuple (unquote (gw x-pivot))
                                       (unquote (gh y-pivot))))
              "gr-grid" (tuple "cartesian" (point "0" "0") "1")
              "gr-grid-aspect" (tuple (tuple "axes" "#808080")
                                      (tuple "1" "#c0c0c0"))
              (graphics
                (unquote-splicing
                  (map (lambda (i) (i x-scale-factor y-scale-factor))
                       images))))))))
