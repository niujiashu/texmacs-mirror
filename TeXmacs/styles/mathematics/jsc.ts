<TeXmacs|1.0.4>

<style|source>

<\body>
  <\active*>
    <\src-title>
      <src-style-file|jsc|1.0>

      <\src-purpose>
        The jsc style.
      </src-purpose>

      <\src-copyright|2002--2004>
        Joris van der Hoeven
      </src-copyright>

      <\src-license>
        This <TeXmacs> style file falls under the <hlink|GNU general public
        license|$TEXMACS_PATH/LICENSE> and comes WITHOUT ANY WARRANTY
        WHATSOEVER. If you do not have a copy of the license, then write to
        the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
        Boston, MA 02111-1307, USA.
      </src-license>
    </src-title>
  </active*>

  <use-package|std|env|title-generic|header-article|section-article>

  <\active*>
    <\src-comment>
      Titles.
    </src-comment>
  </active*>

  <assign|doc-abstract|<\macro|body>
    <\with|par-left|15mm|par-right|15mm>
      <\small>
        <\padded-bothlined|2.5bls|2.5bls|1ln|1ln|0.5bls|0.5bls>
          <surround|<yes-indent>||<arg|body>>
        </padded-bothlined>
      </small>
    </with>
  </macro>>

  <assign|author-by|<macro|body|<arg|body>>>

  <assign|author-render-name|<macro|x|<surround|<vspace*|0.5fn>|<vspace|0.5fn>|<doc-author-block|<arg|x>>>>>

  <\active*>
    <\src-comment>
      Headers.
    </src-comment>
  </active*>

  <assign|odd-page-text|<macro|s|<assign|page-odd-header|<style-with|src-compact|none|<quasiquote|<small|<wide-std-underlined|<htab|0mm><unquote|<arg|s>><space|4spc><page-the-page>>>>>>>>

  <assign|even-page-text|<macro|s|<assign|page-even-header|<style-with|src-compact|none|<quasiquote|<small|<wide-std-underlined|<page-the-page><space|4spc><unquote|<arg|s>>>>>>>>>

  \;

  <assign|header-title|<macro|name|<even-page-text|<arg|name>>>>

  <assign|header-author|<macro|name|<odd-page-text|<arg|name>>>>

  <assign|header-primary|<macro|name|nr|what|>>

  <assign|header-secondary|<macro|name|nr|what|>>

  <\active*>
    <\src-comment>
      Sections, subsections and subsubsections.
    </src-comment>
  </active*>

  <assign|sectional-sep|<macro|.<space|2spc>>>

  <assign|sectional-normal|<macro|name|<no-indent><arg|name><no-page-break>>>

  \;

  <assign|section-title|<macro|name|<style-with|src-compact|none|<sectional-centered-bold|<vspace*|1fn><arg|name><vspace|1fn>>>>>

  <assign|subsection-title|<macro|name|<style-with|src-compact|none|<sectional-centered|<vspace*|1fn><with|font-shape|small-caps|<arg|name>><vspace|1fn>>>>>

  <assign|subsubsection-title|<macro|name|<style-with|src-compact|none|<sectional-normal|<vspace*|1fn><with|font-shape|small-caps|<arg|name>><vspace|1fn>>>>>

  <\active*>
    <\src-comment>
      Paragraphs and subparagraphs.
    </src-comment>
  </active*>

  <assign|paragraph-title|<macro|name|<style-with|src-compact|none|<sectional-short|<vspace*|0.5fn><with|font-shape|small-caps|<arg|name><paragraph-sep>>>>>>

  <assign|subparagraph-title|<macro|name|<style-with|src-compact|none|<sectional-short|<vspace*|0.5fn><with|font-shape|small-caps|<arg|name><subparagraph-sep>>>>>>

  <\active*>
    <\src-comment>
      Other customizations.
    </src-comment>
  </active*>

  <assign|theorem-name|<macro|name|<with|font-shape|small-caps|<arg|name>>>>

  \;
</body>

<\initial>
  <\collection>
    <associate|preamble|true>
  </collection>
</initial>