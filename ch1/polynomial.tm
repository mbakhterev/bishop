<TeXmacs|1.99.12>

<style|generic>

<\body>
  <\program|scheme|default>
    <\unfolded-prog-io|Scheme] >
      (getcwd)
    <|unfolded-prog-io>
      <text|/home/mob/wrk/bishop>
    </unfolded-prog-io|>

    <\input|Scheme] >
      (load "ch1/polynomial.scm")
    </input>

    <\input|Scheme] >
      (define raw-data (load-csv "data/vpered-7-all.csv"))
    </input>

    <\input|Scheme] >
      (gc)
    </input>

    <\input|Scheme] >
      (define frame (reframe raw-data))
    </input>

    <\input|Scheme] >
      (define frame-2 (pick frame "time" "axRaw_1"))
    </input>

    <\input|Scheme] >
      (define shape '(cline (point "-6.08337278210347" "3.79268362048499")
      (point "-3.19652437011566" "3.33295989715251") (point
      "-0.738158172254764" "1.07232209648264") (point "2.74613224073265"
      "2.473811582599"))))
    </input>

    <\unfolded-prog-io|Scheme] >
      `(with "gr-frame" (tuple "x-scale" "0.05gw" "y-scale" "0.05gw" (tuple
      "0.5gw" "0.5gh")) "gr-grid" (tuple "cartesian" (point "0" "0") "1")
      "gr-grid-aspect" (tuple (tuple "axes" "#808080")) (graphics ,shape))
    <|unfolded-prog-io>
      <text|<with|gr-frame|<tuple|x-scale|0.05gw|y-scale|0.05gw|<tuple|0.5gw|0.5gh>>|gr-grid|<tuple|cartesian|<point|0|0>|1>|gr-grid-aspect|<tuple|<tuple|axes|#808080>>|<graphics|<cline|<point|-6.08337278210347|3.79268362048499>|<point|-3.19652437011566|3.33295989715251>|<point|-0.738158172254764|1.07232209648264>|<point|2.74613224073265|2.473811582599>>>>>
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