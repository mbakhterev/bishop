<TeXmacs|1.99.14>

<style|<tuple|generic|old-lengths>>

<\body>
  <\program|scheme|default>
    <\unfolded-prog-io|Scheme] >
      (getcwd)
    <|unfolded-prog-io>
      <text|/home/mob>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (load "ch1/polynomial.scm")
    <|unfolded-prog-io>
      <text|<errput|No such file or directory: "ch1/polynomial.scm">>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (define raw-data (load-csv "data/vpered-7-all.csv"))
    <|unfolded-prog-io>
      <timing|4.355 sec>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (gc)
    <|unfolded-prog-io>
      <timing|1.153 sec>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (define frame (reframe raw-data))
    <|unfolded-prog-io>
      <timing|938 msec>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (define frame-2 (pick frame "time" "axRaw_11111"))
    <|unfolded-prog-io>
      <script-busy>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (define shape '(cspline (point "-6.08337278210347" "3.79268362048499")
      (point "-3.19652437011566" "3.33295989715251") (point
      "-0.738158172254764" "1.07232209648264") (point "2.74613224073265"
      "2.473811582599"))))\<#43E\>
    <|unfolded-prog-io>
      <timing|459 msec>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      `(with "gr-frame" (tuple "scale" "0.05gw" (tuple "0.5gw" "0.5gh"))
      "gr-geometry" (tuple "geometry" "1gw" "0.5gw" "center") "gr-grid"
      (tuple "cartesian" (point "0" "0") "1") "gr-grid-aspect" (tuple (tuple
      "axes" "#808080") (tuple "1" "#c0c0c0")<with|font-series|bold|>)
      (graphics ,shape))
    <|unfolded-prog-io>
      <text|<with|gr-frame|<tuple|scale|0.05gw|<tuple|0.5gw|0.5gh>>|gr-geometry|<tuple|geometry|1gw|0.5gw|center>|gr-grid|<tuple|cartesian|<point|0|0>|1>|gr-grid-aspect|<tuple|<tuple|axes|#808080>|<tuple|1|#c0c0c0>>|<graphics|<cspline|<point|-6.08337278210347|3.79268362048499>|<point|-3.19652437011566|3.33295989715251>|<point|-0.738158172254764|1.07232209648264>|<point|2.74613224073265|2.473811582599>>>>>

      <timing|605 msec>
    </unfolded-prog-io|>

    <\unfolded-prog-io|Scheme] >
      (tabulate frame-2 'small 0 10)
    <|unfolded-prog-io>
      <text|<small|<wide-tabular|<table|<row|<cell|time>|<cell|axRaw_1>>|<row|<cell|625.925720214844>|<cell|181.0>>|<row|<cell|625.925720214844>|<cell|168.0>>|<row|<cell|625.92578125>|<cell|159.0>>|<row|<cell|625.92578125>|<cell|136.0>>|<row|<cell|625.925842285156>|<cell|103.0>>|<row|<cell|625.925842285156>|<cell|128.0>>|<row|<cell|625.925842285156>|<cell|125.0>>|<row|<cell|625.925842285156>|<cell|132.0>>|<row|<cell|625.925903320312>|<cell|193.0>>|<row|<cell|625.925903320312>|<cell|141.0>>>>>>

      <timing|455 msec>
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