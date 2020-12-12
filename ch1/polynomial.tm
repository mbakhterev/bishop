<TeXmacs|1.99.14>

<style|<tuple|generic|old-lengths>>

<\body>
  \;

  <\program|scheme|default>
    <\unfolded-prog-io|Scheme] >
      (getcwd)
    <|unfolded-prog-io>
      "/home/mob/wrk/bishop"
    </unfolded-prog-io|>

    \;

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
      (define p2 (plotter-2d #:x-scale (cons 0.0 time-max) #:y-scale (cons
      ax-min ax-max)))
    </input>

    <\input|Scheme] >
      (define degree 19)
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

    <\input|Scheme] >
      (define Tt (matrix-transpose T))
    </input>

    <\input|Scheme] >
      (define TtT (matrix-mul Tt T)))
    </input>

    <\unfolded-prog-io|Scheme] >
      (define TtT-inverse (matrix-inverse TtT))
    <|unfolded-prog-io>
      <errput|Wrong type argument in position 2: #2((850314685 93649517)
      (699223460 707812945))>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (define omega (matrix-vector-mul TtT-inverse (matrix-vector-mul Tt Y)))
    <|unfolded-prog-io>
      <errput|Unbound variable: TtT-inverse>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define raw (apply dots 3 'round (frame:columns frame "time"
      "axRaw_1")))
    </input>

    <\unfolded-prog-io|Scheme] >
      (o2t (p2 (function-graph (polynomial omega) 0.0 time-max) raw))
    <|unfolded-prog-io>
      <errput|Unbound variable: omega>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (load "ch1/polynomial.scm")
    </input>

    <\input|Scheme] >
      (define M (2d-semi-random 2 2 1000000000))
    </input>

    <\input|Scheme] >
      (define U (matrix-mul M (matrix-inverse M)))
    </input>

    <\unfolded-prog-io|Scheme] >
      U
    <|unfolded-prog-io>
      #2((-285043612269265420372190503732515967372577/4172595245894669705070548403057375
      21233314659959317904985991147363445506048/278173016392977980338036560203825)
      (-6938373741092458505846576623162195181568/126442280178626354699107527365375
      2715181199648685128392806447812657/278173016392977980338036560203825))
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      M
    <|unfolded-prog-io>
      #2((722930537 383539830) (580706841 343251682))
    </unfolded-prog-io|>

    <\input|Scheme] >
      (array-index-map! U (lambda (i j) (exact-\<gtr\>inexact (array-ref U i
      j))))
    </input>

    <\unfolded-prog-io|Scheme] >
      U
    <|unfolded-prog-io>
      #2((-68313266.7971364 76331324.0633045) (-54873842.28828
      9.76076412750588))
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      U
    <|unfolded-prog-io>
      <errput|Unbound variable: U>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (matrix-decompose-lup M 1/100000000)
    <|unfolded-prog-io>
      <errput|Wrong type argument in position 2: #2((850314685 93649517)
      (699223460 707812945))>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (gc)
    </input>

    <\input|Scheme] >
      (define L #2((1 0 0) (234 1 0) (18 37 1)))
    </input>

    <\input|Scheme] >
      (define U #2((1 2 3) (0 67 90) (0 0 4))))
    </input>

    <\unfolded-prog-io|Scheme] >
      (matrix-mul L U)
    <|unfolded-prog-io>
      #2((1 2 3) (234 535 792) (18 2515 3388))
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (matrix-decompose-lup (matrix-mul L U) 1/1000000)
    <|unfolded-prog-io>
      <errput|Wrong type argument in position 2: #2((850314685 93649517)
      (699223460 707812945))>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (matrix-inverse (matrix-mul L U))
    <|unfolded-prog-io>
      <errput|Wrong type argument in position 2: #2((850314685 93649517)
      (699223460 707812945))>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define A #2(( 2 -1 -2) (-4 6 3) (-4 -2 8)))
    </input>

    <\unfolded-prog-io|Scheme] >
      (matrix-decompose-lup A 1/1000)
    <|unfolded-prog-io>
      <errput|Wrong type argument in position 2: #2((850314685 93649517)
      (699223460 707812945))>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (array-\<gtr\>list A)
    <|unfolded-prog-io>
      ((2 -1 -2) (-4 6 3) (-4 -2 8))
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define B <code|#2((1 3 5) (2 4 7) (1 1 0))>)
    </input>

    <\unfolded-prog-io|Scheme] >
      (matrix-decompose-lup B 1/1000)
    <|unfolded-prog-io>
      <errput|Wrong type argument in position 2: #2((850314685 93649517)
      (699223460 707812945))>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define C <code|#2((11 9 24 2) (1 5 2 6) (3 17 18 1) (2 5 7 1))>)
    </input>

    <\unfolded-prog-io|Scheme] >
      (matrix-decompose-lup C 1/10000)
    <|unfolded-prog-io>
      <errput|Wrong type argument in position 2: #2((850314685 93649517)
      (699223460 707812945))>
    </unfolded-prog-io|>

    <\input|Scheme] >
      \;
    </input>

    <\input|Scheme] >
      (define X (2d-semi-random 4 4 100000000000))
    </input>

    <\unfolded-prog-io|Scheme] >
      X
    <|unfolded-prog-io>
      #2((57607540132 77052326853 29110005495 59869169748) (45014543922
      9243066289 42115742988 10724902239) (31495883466 2385350629 64039583971
      53407353509) (23256232492 39038245494 70299718646 64125059119))
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (receive (LU P) (matrix-decompose-lup X 1e-15) (matrix-lup-compose LU
      P))
    <|unfolded-prog-io>
      #2((57607540132 77052326853 29110005495 59869169748) (31495883466
      -494755813087408642599525724981/111578325483044591
      669367557535766604754111981/111578325483044591 53407353509)
      (45014543922 -1917144054898191587740338678721/111578325483044591
      42115742988 10724902239) (23256232492 39038245494
      -2122458262086913562/14401885033 1184525480688685127/14401885033))
    </unfolded-prog-io|>

    <\input|Scheme] >
      (load "/home/mob/tmp/texmacs/mmul.scm")
    </input>

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