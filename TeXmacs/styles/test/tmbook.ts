<TeXmacs|1.0.4>

<style|source>

<\body>
  <\active*>
    <\src-title>
      <src-style-file|tmbook|1.0>

      <\src-purpose>
        A future style for <TeXmacs> books.
      </src-purpose>

      <\src-copyright|1998--2004>
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

  <use-package|book|vdh>

  <\active*>
    <\src-comment>
      Headers.
    </src-comment>
  </active*>

  <assign|odd-page-text|<macro|s|<assign|page-odd-header|<with|font-size|0.84|<style-with|src-compact|none|<no-indent><tabular|<tformat|<cwith|1|-1|1|-1|cell-bborder|1ln>|<twith|table-width|1par>|<cwith|1|1|2|2|cell-halign|r>|<cwith|1|-1|1|-1|cell-lsep|0spc>|<cwith|1|-1|1|-1|cell-rsep|0spc>|<cwith|1|1|1|1|cell-halign|l>|<table|<row|<cell|<with|font-shape|small-caps|<arg|s>>>|<cell|<quote|<page-the-page>>>>>>>>>>>>

  <assign|even-page-text|<macro|s|<assign|page-even-header|<with|font-size|0.84|<style-with|src-compact|none|<no-indent><tabular|<tformat|<cwith|1|-1|1|-1|cell-bborder|1ln>|<twith|table-width|1par>|<cwith|1|1|2|2|cell-halign|r>|<cwith|1|-1|1|-1|cell-lsep|0spc>|<cwith|1|-1|1|-1|cell-rsep|0spc>|<cwith|1|1|1|1|cell-halign|l>|<table|<row|<cell|<quote|<page-the-page>>>|<cell|<with|font-shape|small-caps|<arg|s>>>>>>>>>>>>

  <\active*>
    <\src-comment>
      Chapters.
    </src-comment>
  </active*>

  <assign|sectional-sep|<macro|.<space|2spc>>>

  <assign|chapter-title|<macro|name|<style-with|src-compact|none|<new-page*><new-line><style-with|src-compact|none|<sectional-centered-bold|<vspace*|2fn><with|font-shape|small-caps|font-size|1.54|<arg|name>><vspace|3fn>>>>>>

  <assign|chapter-long-title|<macro|first-title|second-title|<style-with|src-compact|none|<chapter-title|<style-with|src-compact|none|<with|font-size|1.83|<arg|first-title>><right-flush><vspace|1.5fn><new-line><left-flush><arg|second-title>>>>>>

  <assign|chapter-numbered-title|<macro|title|<style-with|src-compact|none|<chapter-long-title|<chapter-text>
  <the-chapter>|<arg|title>>>>>

  <assign|appendix-numbered-title|<macro|title|<style-with|src-compact|none|<chapter-long-title|<appendix-text>
  <the-appendix>|<arg|title>>>>>

  <\active*>
    <\src-comment>
      Sections, subsections and subsubsections.
    </src-comment>
  </active*>

  <assign|section-title|<macro|name|<style-with|src-compact|none|<sectional-centered-bold|<vspace*|2fn><with|font-shape|small-caps|font-size|1.30|<arg|name>><vspace|1fn>>>>>

  <assign|subsection-title|<macro|name|<style-with|src-compact|none|<sectional-normal-bold|<vspace*|1.5fn><with|font-size|1.19|<arg|name>><vspace|0.5fn>>>>>

  <assign|subsubsection-title|<macro|name|<style-with|src-compact|none|<sectional-normal-bold|<vspace*|1fn><arg|name><vspace|0.5fn>>>>>

  <\active*>
    <\src-comment>
      Other customization.
    </src-comment>
  </active*>

  <assign|theorem-name|<macro|name|<with|font-shape|small-caps|<arg|name>>>>

  <assign|toc-strong-2|<macro|left|right|<style-with|src-compact|none|<vspace*|1fn><with|font-series|bold|math-font-series|bold|font-shape|small-caps|<arg|left>><toc-dots><arg|right><vspace|0.5fn>>>>

  \;
</body>

<\initial>
  <\collection>
    <associate|preamble|true>
  </collection>
</initial>