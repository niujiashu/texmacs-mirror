<TeXmacs|1.0.3.4>

<style|source>

<\body>
  <active*|<\src-title>
    <src-package|session|1.0>

    <\src-purpose>
      Environments for displaying computer algebra, shell, or other sessions.
    </src-purpose>

    <src-copyright|1998--2004|Joris van der Hoeven>

    <\src-license>
      This <TeXmacs> style package falls under the <hlink|GNU general public
      license|$TEXMACS_PATH/LICENSE> and comes WITHOUT ANY WARRANTY
      WHATSOEVER. If you don't have this file, then write to the Free
      Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
      02111-1307, USA.
    </src-license>
  </src-title>>

  <\active*>
    <\src-comment>
      Englobing sessions.
    </src-comment>
  </active*>

  <assign|session|<macro|body|<style-with|src-compact|none|<compound|<if|<provides|<merge|<value|prog-language>|-session>>|<merge|<value|prog-language>|-session>|generic-session>|<arg|name>|<arg|body>>>>>

  <assign|generic-session|<macro|name|body|<style-with|src-compact|none|<surround|<vspace*|0.5fn>|<vspace|0.5fn>|<with|par-first|0fn|par-par-sep|0fn|<arg|body>>>>>>

  <\active*>
    <\src-comment>
      Input fields.
    </src-comment>
  </active*>

  <assign|input|<macro|prompt|body|<with|mode|prog|<style-with|src-compact|none|<compound|<style-with|src-compact|none|<if|<provides|<merge|<value|prog-language>|-input>>|<merge|<value|prog-language>|-input>|generic-input>>|<arg|prompt>|<arg|body>>>>>>

  <assign|id-function|<macro|x|<arg|x>>>

  <assign|generic-input|<\macro|prompt|body>
    <tabular|<tformat|<twith|table-width|1par>|<cwith|1|1|2|2|cell-hpart|1>|<cwith|1|1|1|1|cell-lsep|0fn>|<cwith|1|1|1|1|cell-rsep|0fn>|<cwith|1|1|2|2|cell-lsep|0fn>|<cwith|1|1|2|2|cell-rsep|0fn>|<cwith|1|1|2|2|cell-hyphen|t>|<twith|table-hyphen|y>|<table|<row|<cell|<id-function|<arg|prompt>>>|<\cell>
      <with|color|blue|math-display|true|<arg|body>>
    </cell>>>>>
  </macro>>

  <\active*>
    <\src-comment>
      Output fields and error reporting in output.
    </src-comment>
  </active*>

  <assign|output|<macro|body|<with|mode|prog|<style-with|src-compact|none|<compound|<style-with|src-compact|none|<if|<provides|<merge|<value|prog-language>|-output>>|<merge|<value|prog-language>|-output>|generic-output>>|<arg|body>>>>>>

  <assign|generic-output*|<macro|body|<with|par-mode|left|math-display|true|<arg|body>>>>

  <assign|generic-output|<macro|body|<style-with|src-compact|none|<surround|<vspace*|0.5fn>|<rightflush><vspace|0.5fn>|<with|par-left|<plus|<value|par-left>|1.5fn>|<generic-output*|<arg|body>>>>>>>

  <assign|errput|<macro|body|<style-with|src-compact|none|<compound|<style-with|src-compact|none|<if|<provides|<merge|<value|prog-language>|-errput>>|<merge|<value|prog-language>|-textput>|generic-errput>>|<arg|body>>>>>

  <assign|generic-errput|<macro|body|<surround||<rightflush>|<with|color|red|<arg|body>>>>>

  <\active*>
    <\src-comment>
      Textual fields.
    </src-comment>
  </active*>

  <assign|textput|<macro|body|<style-with|src-compact|none|<compound|<style-with|src-compact|none|<if|<provides|<merge|<value|prog-language>|-textput>>|<merge|<value|prog-language>|-textput>|generic-textput>>|<arg|body>>>>>

  <assign|generic-textput|<macro|body|<surround||<rightflush>|<arg|body>>>>
</body>

<\initial>
  <\collection>
    <associate|page-bot|30mm>
    <associate|page-even|30mm>
    <associate|page-odd|30mm>
    <associate|page-reduce-bot|15mm>
    <associate|page-reduce-left|25mm>
    <associate|page-reduce-right|25mm>
    <associate|page-reduce-top|15mm>
    <associate|page-right|30mm>
    <associate|page-top|30mm>
    <associate|page-type|a4>
    <associate|par-width|150mm>
    <associate|preamble|true>
    <associate|sfactor|4>
  </collection>
</initial>