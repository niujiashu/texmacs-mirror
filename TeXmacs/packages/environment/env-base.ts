<TeXmacs|1.0.3.8>

<style|source>

<\body>
  <active*|<\src-title>
    <src-package|env-base|1.0>

    <\src-purpose>
      Managing groups of environments.
    </src-purpose>

    <src-copyright|1998--2004|Joris van der Hoeven>

    <\src-license>
      This <TeXmacs> style package falls under the <hlink|GNU general public
      license|$TEXMACS_PATH/LICENSE> and comes WITHOUT ANY WARRANTY
      WHATSOEVER. If you do not have a copy of the license, then write to the
      Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
      02111-1307, USA.
    </src-license>
  </src-title>>

  <\active*>
    <\src-comment>
      Groups and counters for all standard environments.
    </src-comment>
  </active*>

  <new-counter-group|std-env>

  <new-counter-group|theorem-env>

  <add-to-counter-group|theorem-env|std-env>

  <group-common-counter|theorem-env>

  <new-counter-group|exercise-env>

  <add-to-counter-group|exercise-env|std-env>

  <group-individual-counters|exercise-env>

  <new-counter-group|figure-env>

  <add-to-counter-group|figure-env|std-env>

  <group-individual-counters|figure-env>

  <add-to-counter-group|equation|std-env>

  <add-to-counter-group|footnote|std-env>

  <assign|resetstdenv|<macro|<reset-std-env>>>

  <\active*>
    <\src-comment>
      Defining new block environments with one parameter.
    </src-comment>
  </active*>

  <assign|new-env|<macro|env|name|group|render|<quasi|<style-with|src-compact|none|<add-to-counter-group|<unquote|<arg|env>>|<unquote|<arg|group>>><assign|<unquote|<arg|env>>|<\macro|body>
    <surround|<compound|<unquote|<merge|next-|<arg|env>>>>||<style-with|src-compact|none|<compound|<unquote|<arg|render>>|<localize|<unquote|<arg|name>>>
    <compound|<unquote|<merge|the-|<arg|env>>>>|<arg|body>>>>
  </macro>><assign|<unquote|<merge|<arg|env>|*>>|<\macro|body>
    <compound|<unquote|<arg|render>>|<localize|<unquote|<arg|name>>>|<arg|body>>
  </macro>>>>>>

  <assign|new-theorem|<macro|env|name|<new-env|<arg|env>|<arg|name>|theorem-env|render-theorem>>>

  <assign|new-remark|<macro|env|name|<new-env|<arg|env>|<arg|name>|theorem-env|render-remark>>>

  <assign|new-exercise|<macro|env|name|<new-env|<arg|env>|<arg|name>|exercise-env|render-exercise>>>

  <\active*>
    <\src-comment>
      Defining new figure-like environments.
    </src-comment>
  </active*>

  <assign|new-figure|<macro|env|name|<quasi|<style-with|src-compact|none|<add-to-counter-group|<unquote|<arg|env>>|figure-env><assign|<unquote|<merge|small-|<arg|env>>>|<macro|body|caption|<style-with|src-compact|none|<compound|<unquote|<merge|next-|<arg|env>>>><style-with|src-compact|none|<render-small-figure|<unquote|<arg|env>>|<localize|<unquote|<arg|name>>>
  <compound|<unquote|<merge|the-|<arg|env>>>>|<arg|body>|<arg|caption>>>>>><assign|<unquote|<merge|small-|<arg|env>|*>>|<macro|body|caption|<style-with|src-compact|none|<render-small-figure|<unquote|<arg|env>>|<localize|<unquote|<arg|name>>>|<arg|body>|<arg|caption>>>>><assign|<unquote|<merge|big-|<arg|env>>>|<\macro|body|caption>
    <surround|<compound|<unquote|<merge|next-|<arg|env>>>>||<style-with|src-compact|none|<render-big-figure|<unquote|<arg|env>>|<localize|<unquote|<arg|name>>>
    <compound|<unquote|<merge|the-|<arg|env>>>>|<arg|body>|<arg|caption>>>>
  </macro>><assign|<unquote|<merge|big-|<arg|env>|*>>|<\macro|body|caption>
    <style-with|src-compact|none|<render-big-figure|<unquote|<arg|env>>|<localize|<unquote|<arg|name>>>|<arg|body>|<arg|caption>>>
  </macro>>>>>>

  \;
</body>

<\initial>
  <\collection>
    <associate|preamble|true>
  </collection>
</initial>