<TeXmacs|1.99.2>

<style|<tuple|source|english>>

<\body>
  <active*|<\src-title>
    <src-package|tmdoc-markup|1.0>

    <\src-purpose>
      Content markup and other macros for the <TeXmacs> documentation.
    </src-purpose>

    <src-copyright|2001--2004|Joris van der Hoeven>

    <\src-license>
      This software falls under the <hlink|GNU general public license,
      version 3 or later|$TEXMACS_PATH/LICENSE>. It comes WITHOUT ANY
      WARRANTY WHATSOEVER. You should have received a copy of the license
      which the software. If not, see <hlink|http://www.gnu.org/licenses/gpl-3.0.html|http://www.gnu.org/licenses/gpl-3.0.html>.
    </src-license>
  </src-title>>

  <\active*>
    <\src-comment>
      Content markup. Also used for indexing purposes. The <verbatim|markup>
      macro should be replaced by <verbatim|src-macro>.
    </src-comment>
  </active*>

  <assign|indexed|<macro|body|<arg|body><index|<arg|body>>>>

  <assign|markup|<macro|body|<src-macro|<arg|body>>>>

  <assign|tmstyle|<macro|body|<indexed|<with|font-family|tt|color|brown|<arg|body>>>>>

  <assign|tmpackage|<macro|body|<indexed|<with|font-family|tt|color|brown|<arg|body>>>>>

  <assign|tmdtd|<macro|body|<indexed|<with|font-family|tt|color|dark
  magenta|<arg|body>>>>>

  <\active*>
    <\src-comment>
      Documentation of <TeXmacs> macros.
    </src-comment>
  </active*>

  <assign|explain-header|<\macro|what>
    <\with|par-first|0fn|par-par-sep|0fn>
      <\surround|<vspace*|0.5fn>|<no-page-break>>
        <arg|what>
      </surround>
    </with>
  </macro>>

  <assign|explain-body|<\macro|body>
    <\surround||<right-flush><vspace|0.5fn><no-indent*>>
      <\with|par-left|<plus|<value|par-left>|1.5fn>>
        <arg|body>
      </with>
    </surround>
  </macro>>

  <assign|explain|<\macro|what|body>
    <\explain-header>
      <arg|what>
    </explain-header>

    <\explain-body>
      <arg|body>
    </explain-body>
  </macro>>

  <assign|explain-macro-sub|<macro|x|pos|<if|<equal|<arg|pos>|0>|<indexed|<src-macro|<arg|x>>>|<src-arg|<arg|x>>>>>

  <assign|explain-macro|<xmacro|args|<map-args|explain-macro-sub|inline-tag|args>>>

  <drd-props|explain-macro|arity|<tuple|repeat|1|1>|accessible|all>

  <assign|explain-synopsis|<macro|synopsis|<htab|5mm><with|color|dark
  grey|(<arg|synopsis>)><vspace|0.25fn>>>

  <assign|src-value|<macro|body|<with|font-shape|right|color|black|<arg|body>>>>

  <assign|var-val|<macro|var|val|<src-var|<arg|var>><space|0.5spc><active*|<with|mode|math|\<assign\>>><space|0.5spc><with|font-family|tt|<arg|val>>>>

  <\active*>
    <\src-comment>
      Links inside the documentation and special types of links. We are not
      very happy about this yet, so part of these macros will probably be
      modified sometime in the future.
    </src-comment>
  </active*>

  <assign|if-ref|<macro|lab|body|<with|warn-missing|false|<if|<unequal|<get-binding|<arg|lab>>|<uninit>>|<arg|body>>>>>

  <assign|if-ref*|<macro|lab|body|<with|warn-missing|false|<if|<unequal|<get-binding|<arg|lab>>|<uninit>>|<arg|body>|<greyed|<arg|body>>>>>>

  <assign|tmdoc-file|<macro|name|<or|<find-file|<arg|name>>|<find-file-upwards|<merge|<arg|name>|.|<language-suffix>|.tm>|doc|web|texmacs>|<find-file-upwards|<merge|<arg|name>|.en.tm>|doc|web|texmacs>>>>

  <assign|tmdoc-image|<macro|name|<find-file|$TEXMACS_IMAGE_PATH|<arg|name>>>>

  <assign|tmdoc-link|<macro|body|destination|<with|file|<tmdoc-file|<arg|destination>>|<if|<unequal|<value|file>|false>|<hlink|<arg|body>|<value|file>>|<arg|body>>>>>

  <assign|tmdoc-link*|<macro|body|destination|<with|file|<tmdoc-file|<arg|destination>>|<if|<unequal|<value|file>|false>|<hlink|<arg|body>|<value|file>>|<with|color|red|<arg|body>>>>>>

  <assign|simple-link|<macro|destination|<hlink|<with|font-family|tt|<arg|destination>>|<arg|destination>>>>

  <assign|hyper-link*|<macro|body|destination|<hlink|<arg|body>|<arg|destination>>>>

  <assign|concept-link|<macro|body|<with|color|magenta|<arg|body>>>>

  <assign|only-index|<macro|body|<index|<arg|body>>>>

  <assign|def-index|<macro|body|<em|<arg|body>><index|<arg|body>>>>

  <assign|re-index|<macro|body|<arg|body><index|<arg|body>>>>

  <assign|example-plugin-link|<macro|plugin|<style-with|src-compact|none|<hlink|<with|font-family|tt|<arg|plugin>>|<merge|$TEXMACS_PATH/examples/plugins/|<arg|plugin>>>>>>

  <\active*>
    <\src-comment>
      Tabular environments.
    </src-comment>
  </active*>

  <assign|descriptive-table|<macro|body|<tformat|<cwith|1|-1|1|-1|cell-rborder|0.5ln>|<cwith|1|-1|1|-1|cell-bborder|0.5ln>|<cwith|1|-1|1|1|cell-lborder|0.5ln>|<cwith|1|1|1|-1|cell-tborder|0.5ln>|<cwith|1|1|1|-1|cell-background|pastel
  blue>|<twith|table-min-rows|2>|<twith|table-lborder|1ln>|<twith|table-rborder|1ln>|<twith|table-bborder|1ln>|<twith|table-tborder|1ln>|<cwith|1|1|1|-1|cell-bborder|1ln>|<twith|table-min-cols|2>|<arg|body>>>>

  <\active*>
    <\src-comment>
      Miscellaneous markup.
    </src-comment>
  </active*>

  <new-theorem|question|Question>

  <assign|answer|<macro|body|<quotation|<surround|<theorem-name|<localize|Answer><theorem-sep>>||<arg|body>>>>>

  <assign|todo|<macro|body|<block|<tformat|<cwith|1|1|1|1|cell-background|pastel
  red>|<cwith|1|1|1|1|cell-lborder|0.5ln>|<cwith|1|1|1|1|cell-rborder|0.5ln>|<cwith|1|1|1|1|cell-bborder|0.5ln>|<cwith|1|1|1|1|cell-tborder|0.5ln>|<table|<row|<cell|To
  do: <arg|body>>>>>>>>
</body>

<\initial>
  <\collection>
    <associate|preamble|true>
    <associate|sfactor|3>
  </collection>
</initial>