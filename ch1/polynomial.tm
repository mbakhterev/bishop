<TeXmacs|1.99.14>

<style|<tuple|generic|old-lengths>>

<\body>
  GGjkkkkkkkkkkkkkkkjjjjjjjjjjjjjjjjjjjjk<line-break>j\<#43B\>kk

  <\program|scheme|default>
    <\unfolded-prog-io|Scheme] >
      (getcwd)
    <|unfolded-prog-io>
      "/home/mob/wrk/bishop"
    </unfolded-prog-io|>

    <\input|Scheme] >
      (load "ch1/polynomial.scm")
    </input>

    <\input|Scheme] >
      (define frame (pick (reframe (load-csv "data/vpered-7-all.csv")) "time"
      "axRaw_1"))
    </input>

    <\input|Scheme] >
      (gc)
    </input>

    <\unfolded-prog-io|Scheme] >
      (o2t (tabulate frame)<line-break>)
    <|unfolded-prog-io>
      <text|<small|<wide-tabular|<table|<row||<cell|time>|<cell|axRaw_1>>|<row|0|<cell|625.925720214844>|<cell|181.0>>|<row|1|<cell|625.925720214844>|<cell|168.0>>|<row|2|<cell|625.92578125>|<cell|159.0>>|<row|3|<cell|625.92578125>|<cell|136.0>>|<row|4|<cell|625.925842285156>|<cell|103.0>>|<row|5|<cell|625.925842285156>|<cell|128.0>>|<row|6|<cell|625.925842285156>|<cell|125.0>>|<row|7|<cell|625.925842285156>|<cell|132.0>>|<row|8|<cell|625.925903320312>|<cell|193.0>>|<row|9|<cell|625.925903320312>|<cell|141.0>>|<row|10|<cell|625.925903320312>|<cell|160.0>>|<row|11|<cell|625.925964355469>|<cell|170.0>>|<row|12|<cell|625.925964355469>|<cell|163.0>>|<row|13|<cell|625.925964355469>|<cell|153.0>>|<row|14|<cell|625.925964355469>|<cell|158.0>>|<row|15|<cell|625.926025390625>|<cell|207.0>>>>>>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define time-min ((frame:get frame) 0 0))
    </input>

    <\input|Scheme] >
      (frame-map! (lambda (t) (- t time-min)) frame "time")
    </input>

    <\input|Scheme] >
      (define time-max ((frame:get frame) (- (frame:depth frame) 1) 0))
    </input>

    <\unfolded-prog-io|Scheme] >
      (list 0.0 time-max)
    <|unfolded-prog-io>
      (0.0 0.85943603515625)
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define ax-min (frame-fold min +inf.0 frame "axRaw_1"))
    </input>

    <\input|Scheme] >
      (define ax-max (frame-fold max -inf.0 frame "axRaw_1"))
    </input>

    <\unfolded-prog-io|Scheme] >
      (list ax-min ax-max)
    <|unfolded-prog-io>
      (-2076.0 3992.0)
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (o2t (tabulate frame))
    <|unfolded-prog-io>
      <text|<small|<wide-tabular|<table|<row||<cell|time>|<cell|axRaw_1>>|<row|0|<cell|0.0>|<cell|181.0>>|<row|1|<cell|0.0>|<cell|168.0>>|<row|2|<cell|0.00006103515625>|<cell|159.0>>|<row|3|<cell|0.00006103515625>|<cell|136.0>>|<row|4|<cell|0.0001220703125>|<cell|103.0>>|<row|5|<cell|0.0001220703125>|<cell|128.0>>|<row|6|<cell|0.0001220703125>|<cell|125.0>>|<row|7|<cell|0.0001220703125>|<cell|132.0>>|<row|8|<cell|0.00018310546875>|<cell|193.0>>|<row|9|<cell|0.00018310546875>|<cell|141.0>>|<row|10|<cell|0.00018310546875>|<cell|160.0>>|<row|11|<cell|0.000244140625>|<cell|170.0>>|<row|12|<cell|0.000244140625>|<cell|163.0>>|<row|13|<cell|0.000244140625>|<cell|153.0>>|<row|14|<cell|0.000244140625>|<cell|158.0>>|<row|15|<cell|0.00030517578125>|<cell|207.0>>>>>>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define shape '(cspline (point "-6.08337278210347" "3.79268362048499")
      (point "-3.19652437011566" "3.33295989715251") (point
      "-0.738158172254764" "1.07232209648264") (point "2.74613224073265"
      "2.473811582599"))))
    </input>

    <\input|Scheme] >
      (define p2 (plotter-2d #:x-scale (cons 0.0 time-max) #:y-scale (cons
      ax-min ax-max)))
    </input>

    <\input|Scheme] >
      (define G (p2 (apply dots 3 'round (frame:columns frame "time"
      "axRaw_1"))))
    </input>

    <\input|Scheme] >
      (o2t G)
    </input>

    <\input|Scheme] >
      (define degree 7)
    </input>

    <\input|Scheme] >
      (define X (vector-ref (frame:data frame) 0))
    </input>

    <\input|Scheme] >
      (define Y (vector-ref (frame:data frame) 1))
    </input>

    <\input|Scheme] >
      (define T (vandermonde X (1+ degree)))
    </input>

    <\unfolded-prog-io|Scheme] >
      (array-dimensions X)
    <|unfolded-prog-io>
      (295)
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (array-dimensions T)
    <|unfolded-prog-io>
      (295 8)
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define Tt (matrix-transpose T))
    </input>

    <\unfolded-prog-io|Scheme] >
      (define TtT (matrix-mul Tt T)))
    <|unfolded-prog-io>
      <errput|Unbound variable: Tt>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (gc)
    </input>

    <\input|Scheme] >
      (load "ch1/polynomial.scm")
    </input>

    <\unfolded-prog-io|Scheme] >
      (matrix-decompose-lup #2f32((1.0 0.0) (0.0 1.0)) 1e-10)
    <|unfolded-prog-io>
      #\<less\>values (#2f32((1.0 0.0) (0.0 1.0)) #u32(0 1 2))\<gtr\>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (list-\<gtr\>typed-array 'f32 2 '((1 0 0) (0 1)))
    <|unfolded-prog-io>
      <errput|too few elements for array dimension 1, need 3>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (matrix-decompose-lup #2f32((2 7 6 2) (9 5 1 3) (4 3 8 4) (5 6 7 8))
      1e-10)
    <|unfolded-prog-io>
      #\<less\>values (#2f32((0.222222223877907 5.44444465637207
      4.66666650772095 1.55555558204651) (9.0 5.0 1.0 3.0) (0.444444447755814
      0.306122422218323 3.08390045166016 1.54195022583008) (0.555555582046509
      0.489795923233032 0.514705836772919 0.880352199077606)) #u32(1 0 2 3
      5))\<gtr\>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (make-typed-array 'f32 1.0 2 2)
    <|unfolded-prog-io>
      #2f32((1.0 1.0) (1.0 1.0))
    </unfolded-prog-io|>

    <\input|Scheme] >
      \;
    </input>
  </program>
</body>

<\initial>
  <\collection>
    <associate|font-base-size|8>
    <associate|page-height|auto>
    <associate|page-medium|automatic>
    <associate|page-type|a5>
    <associate|page-width|auto>
    <associate|prog-scripts|scheme>
  </collection>
</initial>