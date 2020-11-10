<TeXmacs|1.99.12>

<style|generic>

<\body>
  <\session|scheme|default>
    <\folded-io|Scheme] >
      (getcwd)
    <|folded-io>
      "/home/mob/wrk/bishop"
    </folded-io>

    <\unfolded-io|Scheme] >
      (load "ch1/polynomial.scm")
    <|unfolded-io>
      <timing|303 msec>
    </unfolded-io>

    <\unfolded-io|Scheme] >
      (define raw-data (load-csv "data/vpered-7-all.csv"))
    <|unfolded-io>
      <timing|2.904 sec>
    </unfolded-io>

    <\unfolded-io|Scheme] >
      (gc)
    <|unfolded-io>
      <timing|1.424 sec>
    </unfolded-io>

    <\input|Scheme] >
      \;
    </input>
  </session>
</body>

<\initial>
  <\collection>
    <associate|page-medium|automatic>
    <associate|prog-scripts|scheme>
  </collection>
</initial>