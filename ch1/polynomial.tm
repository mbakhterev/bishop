<TeXmacs|1.99.14>

<style|<tuple|generic|old-lengths>>

<\body>
  <\program|scheme|default>
    <\unfolded-prog-io|Scheme] >
      (getcwd)
    <|unfolded-prog-io>
      "/home/mob/wrk/bishop"
    </unfolded-prog-io|>

    <\input|Scheme] >
      (load "ch1/polynomial.scm")
    </input>

    <\unfolded-prog-io|Scheme] >
      ((plotter-2d #:cells '(30.0 . 20.0) #:pivot '(0.0 . 5.0)))
    <|unfolded-prog-io>
      <text|<with|gr-geometry|<tuple|geometry|1.0gw|0.666666666666667gw|center>|gr-frame|<tuple|scale|0.0333333333333333gw|<tuple|0.0gw|0.25gh>>|gr-grid|<tuple|cartesian|<point|0|0>|1>|gr-grid-aspect|<tuple|<tuple|axes|#808080>|<tuple|1|#c0c0c0>>|<graphics>>>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define frame (reframe (load-csv "data/vpered-7-all.csv")))
    </input>

    <\unfolded-prog-io|Scheme] >
      (list (frame:width frame) (frame:depth frame))
    <|unfolded-prog-io>
      (97 295)
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define frame-2 (pick frame "time" "axRaw_1"))
    </input>

    <\unfolded-prog-io|Scheme] >
      (tabulate frame-2)<line-break>
    <|unfolded-prog-io>
      <text|<small|<wide-tabular|<table|<row||<cell|time>|<cell|axRaw_1>>|<row|0|<cell|625.925720214844>|<cell|181.0>>|<row|1|<cell|625.925720214844>|<cell|168.0>>|<row|2|<cell|625.92578125>|<cell|159.0>>|<row|3|<cell|625.92578125>|<cell|136.0>>|<row|4|<cell|625.925842285156>|<cell|103.0>>|<row|5|<cell|625.925842285156>|<cell|128.0>>|<row|6|<cell|625.925842285156>|<cell|125.0>>|<row|7|<cell|625.925842285156>|<cell|132.0>>|<row|8|<cell|625.925903320312>|<cell|193.0>>|<row|9|<cell|625.925903320312>|<cell|141.0>>|<row|10|<cell|625.925903320312>|<cell|160.0>>|<row|11|<cell|625.925964355469>|<cell|170.0>>|<row|12|<cell|625.925964355469>|<cell|163.0>>|<row|13|<cell|625.925964355469>|<cell|153.0>>|<row|14|<cell|625.925964355469>|<cell|158.0>>|<row|15|<cell|625.926025390625>|<cell|207.0>>>>>>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define time-min ((frame:get frame-2) 0 0))
    </input>

    <\input|Scheme] >
      (define time-max ((frame:get frame-2) (- (frame:depth frame-2) 1) 0))
    </input>

    <\unfolded-prog-io|Scheme] >
      (list time-min time-max)
    <|unfolded-prog-io>
      (625.925720214844 626.78515625)
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define ax-min (frame-fold min +inf.0 frame-2 "axRaw_1"))
    </input>

    <\input|Scheme] >
      (define ax-max (frame-fold max -inf.0 frame-2 "axRaw_1"))
    </input>

    <\unfolded-prog-io|Scheme] >
      (list ax-min ax-max)
    <|unfolded-prog-io>
      (-2076.0 3992.0)
    </unfolded-prog-io|>

    <\input|Scheme] >
      (frame-map! (lambda (t) (- t time-min)) frame-2 "time")
    </input>

    <\unfolded-prog-io|Scheme] >
      (tabulate frame-2)
    <|unfolded-prog-io>
      <text|<small|<wide-tabular|<tformat|<table|<row||<cell|time>|<cell|axRaw_1>>|<row|0|<cell|0.0>|<cell|181.0>>|<row|1|<cell|0.0>|<cell|168.0>>|<row|2|<cell|0.00006103515625>|<cell|159.0>>|<row|3|<cell|0.00006103515625>|<cell|136.0>>|<row|4|<cell|0.0001220703125>|<cell|103.0>>|<row|5|<cell|0.0001220703125>|<cell|128.0>>|<row|6|<cell|0.0001220703125>|<cell|125.0>>|<row|7|<cell|0.0001220703125>|<cell|132.0>>|<row|8|<cell|0.00018310546875>|<cell|193.0>>|<row|9|<cell|0.00018310546875>|<cell|141.0>>|<row|10|<cell|0.00018310546875>|<cell|160.0>>|<row|11|<cell|0.000244140625>|<cell|170.0>>|<row|12|<cell|0.000244140625>|<cell|163.0>>|<row|13|<cell|0.000244140625>|<cell|153.0>>|<row|14|<cell|0.000244140625>|<cell|158.0>>|<row|15|<cell|0.00030517578125>|<cell|207.0>>>>>>>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (define shape '(cspline (point "-6.08337278210347" "3.79268362048499")
      (point "-3.19652437011566" "3.33295989715251") (point
      "-0.738158172254764" "1.07232209648264") (point "2.74613224073265"
      "2.473811582599"))))
    </input>

    <\input|Scheme] >
      (define shape-1 '(cline (point "-6.08337278210347" "3.79268362048499")
      (point "-3.19652437011566" "3.33295989715251") (point
      "-0.738158172254764" "1.07232209648264") (point "2.74613224073265"
      "2.473811582599"))))
    </input>

    <\unfolded-prog-io|Scheme] >
      (object-\<gtr\>tree `(with \ "gr-geometry" (tuple "geometry" "1gw"
      "0.5gw" "center") "gr-frame" (tuple "scale" "0.05gw" (tuple "0.5gw"
      "0.5gh")) "gr-grid" (tuple "cartesian" (point "0" "0") "1")
      "gr-grid-aspect" (tuple (tuple "axes" "#808080") (tuple "1"
      "#c0c0c0")<with|font-series|bold|>) (graphics ,shape ,shape-1)))
    <|unfolded-prog-io>
      <text|<with|gr-geometry|<tuple|geometry|1gw|0.5gw|center>|gr-frame|<tuple|scale|0.05gw|<tuple|0.5gw|0.5gh>>|gr-grid|<tuple|cartesian|<point|0|0>|1>|gr-grid-aspect|<tuple|<tuple|axes|#808080>|<tuple|1|#c0c0c0>>|<graphics|<cspline|<point|-6.08337278210347|3.79268362048499>|<point|-3.19652437011566|3.33295989715251>|<point|-0.738158172254764|1.07232209648264>|<point|2.74613224073265|2.473811582599>>|<cline|<point|-6.08337278210347|3.79268362048499>|<point|-3.19652437011566|3.33295989715251>|<point|-0.738158172254764|1.07232209648264>|<point|2.74613224073265|2.473811582599>>>>>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      ((plotter-2d))
    <|unfolded-prog-io>
      <errput|Wrong number of arguments to 20.0>
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