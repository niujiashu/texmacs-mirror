<TeXmacs|1.0.4>

<style|source>

<\body>
  <active*|<\src-title>
    <src-package-dtd|title-book|1.0|header-title|1.0>

    <\src-purpose>
      Titles for books.
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

  <use-package|title-base>

  <\active*>
    <\src-comment>
      Containers.
    </src-comment>
  </active*>

  <assign|doc-make-title|<\macro|body>
    <no-indent><assign|page-this-header|><assign|page-this-footer|><vspace|0.25pag>

    <font-magnify|1.414|<doc-title-block|<arg|body>>>

    <new-page>

    <assign|page-this-header|><assign|page-this-footer|><vspace|0.15pag>

    <surround||<hflush>|<new-page>>
  </macro>>

  <assign|doc-abstract|<\macro|body>
    <surround|<no-indent>||<chapter*|<abstract-text>>>

    <surround||<hflush>|<arg|body>>
  </macro>>

  <\active*>
    <\src-comment>
      Title elements.
    </src-comment>
  </active*>

  <assign|doc-render-title|<macro|x|<surround||<vspace|0.1pag>|<style-with|src-compact|none|<doc-title-block|<with|math-font-series|bold|font-series|bold|<font-magnify|2|<arg|x>>>>>>>>

  <assign|doc-author|<macro|body|<\surround|<vspace*|0.1pag>|<vspace|0.1pag>>
    <\with|par-par-sep|0fn>
      <doc-title-block|<arg|body>>
    </with>
  </surround>>>

  <assign|doc-date|<macro|x|<surround|<vspace*|0.1pag>||<doc-author-block|<with|font-shape|italic|<arg|x>>>>>>

  <\active*>
    <\src-comment>
      Author elements.
    </src-comment>
  </active*>

  <assign|author-render-name|<macro|x|<surround|<vspace*|1fn>||<doc-author-block|<with|font-shape|small-caps|<font-magnify|1.091|<arg|x>>>>>>>

  <assign|author-address|<\macro|x>
    <surround|<vspace*|2fn>|<vspace|2fn>|<doc-author-block|<arg|x>>>
  </macro>>

  <assign|author-email|<macro|x|<surround|<vspace*|1fn>||<doc-author-block|<style-with|src-compact|none|<with|font-shape|italic|<email-text><localize|:>
  ><with|font-family|tt|<arg|x>>>>>>>

  <assign|author-homepage|<macro|x|<surround||<vspace*|1fn>|<doc-author-block|<style-with|src-compact|none|<with|font-shape|italic|<homepage-text><localize|:>
  ><with|font-family|tt|<arg|x>>>>>>>
</body>

<\initial>
  <\collection>
    <associate|preamble|true>
  </collection>
</initial>