<?xml version="1.0" encoding="UTF-8"?>
<!--        -->
<!-- MEILER -->
<!-- mei2ly -->
<!-- v0.8.6 -->
<!--        -->
<!-- programmed by Klaus Rettinghaus -->
<!--        -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="saxon">
  <xsl:strip-space elements="*"/>
  <xsl:output method="text" indent="no" encoding="UTF-8"/>
  <xsl:template match="/">
    <xsl:text>\version "2.18.2"&#10;</xsl:text>
    <xsl:text>#(ly:set-option 'point-and-click #f)&#10;</xsl:text>
    <xsl:text>% automatically converted by mei2ly.xsl&#10;&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI.header -->
  <!-- MEI header -->
  <xsl:template match="mei:meiHead">
    <xsl:text>\header {&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#10;&#10;</xsl:text>
  </xsl:template>
  <!-- MEI file description -->
  <xsl:template match="mei:fileDesc">
    <xsl:apply-templates select="mei:editionStmt|mei:pubStmt"/>
  </xsl:template>
  <!-- MEI edition statement -->
  <xsl:template match="mei:editionStmt">
    <xsl:value-of select="concat('  edition = \markup { ',normalize-space(.),' }&#10;')"/>
  </xsl:template>
  <!-- MEI publication statement -->
  <xsl:template match="mei:pubStmt">
    <xsl:if test="mei:respStmt/mei:persName[@role='editor']">
      <xsl:value-of select="concat('  editor = \markup { ',normalize-space(mei:respStmt/mei:persName[@role='editor'][1]),' }&#10;')"/>
    </xsl:if>
    <xsl:if test="mei:publisher">
      <xsl:text>  publisher = \markup { </xsl:text>
      <xsl:apply-templates select="mei:publisher"/>
      <xsl:text>&#32;}&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="mei:pubPlace">
      <xsl:text>  place = \markup { </xsl:text>
      <xsl:apply-templates select="mei:pubPlace[1]"/>
      <xsl:text>&#32;}&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="mei:date">
      <xsl:text>  date = \markup { </xsl:text>
      <xsl:apply-templates select="mei:date[1]"/>
      <xsl:text>&#32;}&#10;</xsl:text>
    </xsl:if>
    <!-- filling standard lilypond header -->
    <xsl:text>  copyright = \markup { </xsl:text>
    <xsl:text>©&#32;</xsl:text>
    <xsl:apply-templates select="mei:respStmt"/>
    <xsl:text>,&#32;</xsl:text>
    <xsl:apply-templates select="mei:pubPlace"/>
    <xsl:text>&#32;</xsl:text>
    <xsl:apply-templates select="mei:date"/>
    <xsl:text>&#32;}&#10;</xsl:text>
    <xsl:text>  tagline = "automatically converted from MEI with mei2ly.xsl and engraved with Lilypond"&#10;</xsl:text>
  </xsl:template>
  <!-- MEI work description -->
  <xsl:template match="mei:workDesc">
    <xsl:value-of select="concat('  title = &quot;',normalize-space(descendant::mei:title[not(@type) or @type='main'][1]),'&quot;&#10;')"/>
    <xsl:if test="descendant::mei:title[@type='subordinate']">
      <xsl:value-of select="concat('  subtitle = &quot;',normalize-space(descendant::mei:title[@type='subordinate'][1]),'&quot;&#10;')"/>
      <xsl:value-of select="concat('  subsubtitle = &quot;',normalize-space(descendant::mei:title[@type='subordinate'][2]),'&quot;&#10;')"/>
    </xsl:if>
    <xsl:for-each select="descendant::mei:persName[@role]">
      <xsl:value-of select="concat('  ',@role,' = &quot;',normalize-space(.),'&quot;&#10;')"/>
    </xsl:for-each>
  </xsl:template>
  <!-- MEI revision description -->
  <xsl:template match="mei:revisionDesc">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI change -->
  <xsl:template match="mei:change">
    <xsl:text>&#32;&#32;%&#32;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <!-- MEI change description -->
  <xsl:template match="mei:changeDesc">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI availability -->
  <xsl:template match="mei:availability">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI distributor -->
  <xsl:template match="mei:distributor">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI access restriction -->
  <xsl:template match="mei:accessRestrict">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI usage restrictions-->
  <xsl:template match="mei:useRestrict">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI music element -->
  <xsl:template match="mei:music">
    <xsl:if test="descendant::mei:scoreDef[1]/@*[starts-with(name(),'page')] and not(ancestor::mei:music)">
      <xsl:apply-templates select="descendant::mei:scoreDef[1]" mode="makePageLayout"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI group element -->
  <xsl:template match="mei:group">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI body element -->
  <xsl:template match="mei:body">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI musical division -->
  <xsl:template match="mei:mdiv">
    <xsl:variable name="mdivNumber" select="@n"/>
    <xsl:if test="@label">
      <xsl:value-of select="concat('% Division ',@n,' &quot;',@label,'&quot;&#10;&#10;')"/>
    </xsl:if>
    <!-- extracting musical content from staves -->
    <xsl:for-each select="descendant::mei:scoreDef[1]/descendant::mei:staffDef">
      <xsl:variable name="staffNumber" select="@n"/>
      <xsl:variable name="layerNumber" select="max(ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]/mei:layer/@n)"/>
      <xsl:value-of select="concat('mdiv',codepoints-to-string(xs:integer(64 + $mdivNumber)),'_staff',codepoints-to-string(xs:integer(64 + $staffNumber)),' = {&#10;')"/>
      <xsl:for-each select="ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]">
        <xsl:text>&#32;&#32;</xsl:text>
        <!-- add volta brackets -->
        <xsl:if test="ancestor::mei:ending and not(ancestor::mei:measure/preceding-sibling::mei:measure)">
          <xsl:text>\set Score.repeatCommands = #'((volta "</xsl:text>
          <xsl:value-of select="concat(ancestor::mei:ending/@n[1],'.')"/>
          <xsl:text>"))&#10;&#32;&#32;</xsl:text>
        </xsl:if>
        <xsl:if test="ancestor::mei:measure/preceding-sibling::mei:scoreDef/preceding::mei:measure[1]/@n = ancestor::mei:measure/preceding::mei:measure[1]/@n">
          <xsl:if test="preceding::mei:scoreDef[1]/@meter.showchange">
            <xsl:variable name="showchangeVal" select="substring(preceding::mei:scoreDef[1]/@meter.showchange,1,1)"/>
            <xsl:text>\override Staff.TimeSignature.break-visibility = #'#</xsl:text>
            <xsl:value-of select="concat('(#',$showchangeVal,' #',$showchangeVal,' #',$showchangeVal,')&#10;&#32;&#32;')"/>
          </xsl:if>
        </xsl:if>
        <!-- set bar number -->
        <xsl:if test="(ancestor::mei:measure[@n and not(@metcon='false')]/@n != preceding::mei:measure[@n and not(@metcon='false')][1]/@n + 1)">
          <xsl:call-template name="setBarNumber"/>
        </xsl:if>
        <!-- add clef change -->
        <xsl:if test="ancestor::mei:measure/preceding-sibling::mei:staffDef[@n = $staffNumber][@clef.shape]/following-sibling::mei:measure[1]/@n = ancestor::mei:measure/@n">
          <xsl:call-template name="setClef">
            <xsl:with-param name="clefColor" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.color"/>
            <xsl:with-param name="clefDis" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.dis"/>
            <xsl:with-param name="clefDisPlace" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.dis.place"/>
            <xsl:with-param name="clefLine" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.line"/>
            <xsl:with-param name="clefShape" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.shape"/>
          </xsl:call-template>
          <xsl:text>&#10;&#32;&#32;</xsl:text>
        </xsl:if>
        <!-- add key signature change -->
        <xsl:if test="ancestor::mei:measure/preceding-sibling::*[contains(name(),'Def')][@*[starts-with(name(),'key')]][1]/following-sibling::mei:measure[1]/@n = ancestor::mei:measure/@n">
          <xsl:call-template name="setKey">
            <xsl:with-param name="keyTonic" select="ancestor::mei:measure/preceding-sibling::*/@key.pname[1]"/>
            <xsl:with-param name="keyAccid" select="ancestor::mei:measure/preceding-sibling::*/@key.accid[1]"/>
            <xsl:with-param name="keyMode" select="ancestor::mei:measure/preceding-sibling::*/@key.mode[1]"/>
            <xsl:with-param name="keySig" select="ancestor::mei:measure/preceding-sibling::*/@key.sig[1]"/>
            <xsl:with-param name="keySigMixed" select="ancestor::mei:measure/preceding-sibling::*/@key.sig.mixed[1]"/>
          </xsl:call-template>
          <xsl:text>&#32;&#32;</xsl:text>
        </xsl:if>
        <!-- add time signature change -->
        <xsl:if test="ancestor::mei:measure/preceding-sibling::*[contains(name(),'Def')][@*[starts-with(name(),'meter')]][1]/following-sibling::mei:measure[1]/@n = ancestor::mei:measure/@n">
          <xsl:call-template name="meterSig">
            <xsl:with-param name="meterSymbol" select="ancestor::mei:measure/preceding-sibling::*[@meter.sym][1]/@meter.sym"/>
            <xsl:with-param name="meterCount" select="ancestor::mei:measure/preceding-sibling::*[@meter.count][1]/@meter.count"/>
            <xsl:with-param name="meterUnit" select="ancestor::mei:measure/preceding-sibling::*[@meter.unit][1]/@meter.unit"/>
            <xsl:with-param name="meterRend" select="ancestor::mei:measure/preceding-sibling::*[@meter.rend][1]/@meter.rend"/>
          </xsl:call-template>
          <xsl:text>&#10;&#32;&#32;</xsl:text>
        </xsl:if>
        <xsl:if test="ancestor::mei:measure/preceding::mei:meterSig[1]/preceding::mei:measure[1]/@n = ancestor::mei:measure/preceding-sibling::mei:measure[1]/@n">
          <xsl:choose>
            <xsl:when test="ancestor::mei:measure/preceding::mei:meterSig[1]/parent::mei:meterSigGrp">
              <xsl:apply-templates select="ancestor::mei:measure/preceding::mei:meterSigGrp[1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="ancestor::mei:measure/preceding::mei:meterSig[1]"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>&#10;&#32;&#32;</xsl:text>
        </xsl:if>
        <!-- print bar line -->
        <xsl:if test="ancestor::mei:measure/@left">
          <xsl:call-template name="setBarLine">
            <xsl:with-param name="barLineStyle" select="ancestor::mei:measure/@left"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="ancestor::mei:measure/mei:tempo[contains(concat(' ',@staff,' '),concat(' ',$staffNumber,' '))][@tstamp = 1]" mode="pre"/>
        <xsl:if test="ancestor::mei:measure/@metcon='false'">
          <xsl:value-of select="concat('\partial ',min(ancestor::mei:measure/descendant::*/@dur),'&#32;')"/>
        </xsl:if>
        <xsl:text>&lt;&lt;&#32;</xsl:text>
        <xsl:choose>
          <xsl:when test="@copyof">
            <xsl:apply-templates select="ancestor::mei:mdiv[1]//mei:staff[@xml:id = substring-after(current()/@copyof,'#')]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&gt;&gt;&#32;</xsl:text>
        <!-- print bar line -->
        <xsl:if test="ancestor::mei:measure/@right">
          <xsl:call-template name="setBarLine">
            <xsl:with-param name="barLineStyle" select="ancestor::mei:measure/@right"/>
          </xsl:call-template>
        </xsl:if>
        <!-- print bar number -->
        <xsl:value-of select="concat('%',ancestor::mei:measure/@n,'&#10;')"/>
        <!-- close volta brackets -->
        <xsl:if test="ancestor::mei:ending and not(ancestor::mei:ending/following-sibling::*[1][self::mei:ending])">
          <xsl:text>&#32;&#32;\set Score.repeatCommands = #'((volta #f))&#10;</xsl:text>
        </xsl:if>
        <!-- add breaks -->
        <xsl:apply-templates select="following::mei:sb[following::mei:measure[1]/@n = current()/ancestor::mei:measure/@n + 1]"/>
        <xsl:apply-templates select="following::mei:pb[following::mei:measure[1]/@n = current()/ancestor::mei:measure/@n + 1]"/>
      </xsl:for-each>
      <xsl:text>}&#10;&#10;</xsl:text>
      <!-- lilypond figured bass -->
      <xsl:if test="ancestor::mei:mdiv[1]//mei:harm[descendant-or-self::*/@staff=$staffNumber]">
        <xsl:value-of select="concat('mdiv',codepoints-to-string(xs:integer(64 + $mdivNumber)),'_staff',codepoints-to-string(xs:integer(64 + $staffNumber)),'_harm = \figuremode {&#10;')"/>
        <xsl:text>&#32;&#32;\set Staff.figuredBassAlterationDirection = #RIGHT&#10;</xsl:text>
        <xsl:for-each select="ancestor::mei:mdiv[1]//mei:measure">
          <xsl:text>&#32;&#32;</xsl:text>
          <xsl:if test="not(descendant::mei:harm[@staff=$staffNumber])">
            <xsl:call-template name="setMeasureSpace"/>
          </xsl:if>
          <xsl:apply-templates select="mei:harm[@staff=$staffNumber]"/>
          <xsl:value-of select="concat('%',@n,'&#10;')"/>
        </xsl:for-each>
        <xsl:text>}&#10;&#10;</xsl:text>
      </xsl:if>
      <!-- lilypond lyrics -->
      <xsl:if test="ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]//mei:syl">
        <xsl:for-each select="ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]//mei:verse/@n[not(.= preceding::mei:verse[ancestor::mei:staff/@n=$staffNumber]/@n)]">
          <xsl:variable name="verseNumber" select="."/>
          <xsl:value-of select="concat('mdiv',codepoints-to-string(xs:integer(64 + $mdivNumber)),'_staff',codepoints-to-string(xs:integer(64 + $staffNumber)),'_verse',codepoints-to-string(xs:integer(64 + $verseNumber)),' = \lyricmode {&#10;')"/>
          <xsl:if test="ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.name">
            <xsl:value-of select="concat('\override Lyrics.LyricText.font-name = #&quot;',ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.name,'&quot; ')"/>
          </xsl:if>
          <xsl:if test="ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.fam">
            <xsl:text>\override Lyrics.LyricText.font-family = #&apos;</xsl:text>
            <xsl:value-of select="concat(ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.fam,' ')"/>
          </xsl:if>
          <xsl:if test="ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.size">
          </xsl:if>
          <xsl:if test="ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.style">
            <xsl:text>\override Lyrics.LyricText.font-shape = #&apos;</xsl:text>
            <xsl:value-of select="concat(ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.style,' ')"/>
          </xsl:if>
          <xsl:if test="ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.weight">
            <xsl:text>\override Lyrics.LyricText.font-series = #&apos;</xsl:text>
            <xsl:value-of select="concat(ancestor::mei:mdiv[1]//mei:staffDef[@n=$staffNumber][1]/@lyric.weight,' ')"/>
          </xsl:if>
          <xsl:for-each select="ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]/mei:layer[1]">
            <xsl:for-each select="descendant::*[name()='note' or name()='rest' or name()='mRest']">
              <xsl:if test="not(@grace)">
                <xsl:choose>
                  <xsl:when test="descendant::mei:syl">
                    <xsl:apply-templates select="mei:verse[@n=$verseNumber]|mei:syl"/>
                  </xsl:when>
                  <xsl:when test="@syl">
                    <xsl:value-of select="concat(' ',@syl)"/>
                  </xsl:when>
                  <xsl:when test="name()='note' or max(ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]/mei:layer/@n) &gt; 1">
                    <xsl:value-of select="'_'"/>
                  </xsl:when>
                </xsl:choose>
                <xsl:if test="$layerNumber != 1">
                  <xsl:call-template name="setDuration"/>
                  <xsl:if test="not(@dur)">
                    <xsl:value-of select="concat(preceding::mei:scoreDef[@meter.unit][1]//@meter.unit[1],'*',preceding::mei:scoreDef[@meter.count][1]//@meter.count)"/>
                  </xsl:if>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="mei:verse[@n=$verseNumber]/mei:syl[position()=last()]/@con='d'">
                    <xsl:value-of select="' -- '"/>
                  </xsl:when>
                  <xsl:when test="mei:verse[@n=$verseNumber]/mei:syl[position()=last()]/@con='u'">
                    <xsl:value-of select="' __ '"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="' '"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:for-each>
          </xsl:for-each>
          <xsl:text>&#10;}&#10;&#10;</xsl:text>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI musical division -->
  <xsl:template match="mei:parts">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI score element -->
  <xsl:template match="mei:score">
    <xsl:apply-templates select="descendant::mei:scoreDef[1]"/>
  </xsl:template>
  <!-- MEI score definition -->
  <xsl:template match="mei:scoreDef">
    <!-- lilypond score block -->
    <xsl:text>\score { &lt;&lt;&#10;</xsl:text>
    <xsl:if test="ancestor::mei:mdiv[1]//@source">
      <xsl:text>\removeWithTag #'( </xsl:text>
      <xsl:for-each select="distinct-values(ancestor::mei:mdiv[1]//@source)">
        <xsl:value-of select="translate(.,'#','')"/>
        <xsl:text>&#32;</xsl:text>
      </xsl:for-each>
      <xsl:text>)&#10;</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="mei:staffGrp|mei:staffDef"/>
    <xsl:text>&gt;&gt;&#10;</xsl:text>
    <!-- lilypond layout block -->
    <xsl:text>\layout {&#10;</xsl:text>
    <xsl:if test="contains(@music.size,'pt')">
      <xsl:value-of select="concat('  #(layout-set-staff-size ',substring-before(@music.size,'pt'),')&#10;')"/>
    </xsl:if>
    <xsl:if test="@mnum.visible or @clef.color">
      <xsl:text>  \context { \Score </xsl:text>
      <xsl:if test="@mnum.visible = 'false'">
        <xsl:text>\remove "Bar_number_engraver" </xsl:text>
      </xsl:if>
      <xsl:if test="@clef.color">
        <xsl:text>\override Clef.color = #</xsl:text>
        <xsl:call-template name="setColor">
          <xsl:with-param name="color" select="@clef.color"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:text>}&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="@*[starts-with(name(),'lyric')]">
      <xsl:text>  \context { \Score </xsl:text>
      <xsl:if test="@lyric.name">
        <xsl:value-of select="concat('\override LyricText.font-name = #&quot;',ancestor-or-self::*/@lyric.name[1],'&quot; ')"/>
      </xsl:if>
      <xsl:if test="@lyric.fam">
        <xsl:text>\override LyricText.font-family = #&apos;</xsl:text>
        <xsl:value-of select="concat(@lyric.fam,' ')"/>
      </xsl:if>
      <xsl:if test="@lyric.size">
      </xsl:if>
      <xsl:if test="@lyric.style">
        <xsl:text>\override LyricText.font-shape = #&apos;</xsl:text>
        <xsl:value-of select="concat(@lyric.style,' ')"/>
      </xsl:if>
      <xsl:if test="@lyric.weight">
        <xsl:text>\override LyricText.font-series = #&apos;</xsl:text>
        <xsl:value-of select="concat(@lyric.weight,' ')"/>
      </xsl:if>
      <xsl:text>}&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="@optimize = 'false'">
      <xsl:text>  \context { \Staff \RemoveEmptyStaves \override VerticalAxisGroup.remove-first = ##t }&#10;</xsl:text>
    </xsl:if>
    <xsl:text>}&#10;</xsl:text>
    <xsl:if test="//mei:midi or //@*[contains(name(),'midi')]">
      <xsl:text>\midi { </xsl:text>
      <xsl:if test="@midi.bpm">
        <xsl:value-of select="concat('\tempo 4 = ',@midi.bpm,' ')"/>
      </xsl:if>
      <xsl:text>}&#10;</xsl:text>
    </xsl:if>
    <xsl:text>}&#10;&#10;</xsl:text>
    <xsl:if test="contains(@music.size,'pt')">
      <xsl:value-of select="concat('&#10;#(set-global-staff-size ',substring-before(@music.size,'pt'),')&#10;')"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI staff group -->
  <xsl:template match="mei:staffGrp">
    <xsl:text>\new StaffGroup </xsl:text>
    <xsl:if test="@label or @label.abbr or child::mei:label">
      <xsl:text>\with { </xsl:text>
      <xsl:call-template name="setInstrumentName"/>
      <xsl:text>} </xsl:text>
    </xsl:if>
    <xsl:text>&lt;&lt;&#10;</xsl:text>
    <xsl:call-template name="setStaffGrpStyle"/>
    <xsl:apply-templates select="mei:staffGrp|mei:staffDef"/>
    <xsl:text>&gt;&gt;&#10;</xsl:text>
  </xsl:template>
  <!-- MEI staff definitons -->
  <xsl:template match="mei:staffDef">
    <xsl:variable name="mdivNumber" select="ancestor::mei:mdiv/@n"/>
    <xsl:variable name="staffNumber" select="@n"/>
    <xsl:text>  \new </xsl:text>
    <xsl:if test="@notationtype">
      <xsl:call-template name="setNotationtype"/>
    </xsl:if>
    <xsl:value-of select="concat('Staff = &quot;staff ',$staffNumber,'&quot;&#32;')"/>
    <xsl:if test="@scale or @label or @label.abbr or child::mei:label or ((position() = 1) and (count(ancestor::mei:staffGrp) &gt; 1) and ancestor::mei:scoreDef/@ending.rend = 'grouped')">
      <xsl:text>\with { </xsl:text>
      <xsl:call-template name="setInstrumentName"/>
      <xsl:if test="(position() = 1) and (count(ancestor::mei:staffGrp) &gt; 1) and ancestor::mei:scoreDef/@ending.rend = 'grouped'">
        <xsl:text>\consists "Volta_engraver" </xsl:text>
      </xsl:if>
      <xsl:if test="@scale">
        <xsl:value-of select="concat('\magnifyStaff #',substring-before(@scale,'%'),'/100 ')"/>
      </xsl:if>
      <xsl:text>} </xsl:text>
    </xsl:if>
    <!-- add figured bass context -->
    <xsl:if test="ancestor::mei:mdiv[1]//mei:harm[descendant::mei:fb]/@staff = $staffNumber">
      <xsl:value-of select="concat('&#10;  \mdiv',codepoints-to-string(xs:integer(64 + $mdivNumber)),'_staff',codepoints-to-string(xs:integer(64 + $staffNumber)),'_harm')"/>
      <xsl:value-of select="concat('&#10;  \context Staff = &quot;staff ',$staffNumber,'&quot;&#32;')"/>
    </xsl:if>
    <xsl:text>{&#10;    </xsl:text>
    <xsl:apply-templates select="mei:instrDef"/>
    <xsl:if test="@lines and @lines != '5'">
      <xsl:value-of select="concat('\override Staff.StaffSymbol.line-count = #',@lines,'&#10;    ')"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@lines.visible = 'true'">
        <xsl:value-of select="'\override Staff.StaffSymbol.transparent = ##f&#10;    '"/>
      </xsl:when>
      <xsl:when test="@lines.visible = 'false'">
        <xsl:value-of select="'\override Staff.StaffSymbol.transparent = ##t&#10;    '"/>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="ancestor-or-self::*/@pedal.style">
      <xsl:choose>
        <xsl:when test="ancestor-or-self::*/@pedal.style = 'line'">
          <xsl:text>\set Staff.pedalSustainStyle = #'bracket&#10;    </xsl:text>
        </xsl:when>
        <xsl:when test="ancestor-or-self::*/@pedal.style = 'pedstar'">
          <xsl:text>\set Staff.pedalSustainStyle = #'text&#10;    </xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@slur.lform">
      <xsl:value-of select="concat('\slur',translate(substring(@lform,1,1),'ds','DS'),substring(@lform,2),' ')"/>
    </xsl:if>
    <xsl:if test="@slur.lwidth">
      <xsl:text>\override Slur.thickness = #</xsl:text>
      <xsl:call-template name="setLineWidth">
        <xsl:with-param name="thickness" select="@slur.lwidth"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="@tie.lwidth">
      <xsl:text>\override Tie.thickness = #</xsl:text>
      <xsl:call-template name="setLineWidth">
        <xsl:with-param name="thickness" select="@tie.lwidth"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="@*[starts-with(name(),'trans')]">
      <xsl:call-template name="setTransposition"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*/@beam.group">
        <xsl:call-template name="setBeaming"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'\autoBeamOff '"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>\set tieWaitForNote = ##t&#10;    </xsl:text>
    <xsl:if test="ancestor-or-self::*/@*[starts-with(name(),'clef.')]">
      <xsl:call-template name="setClef">
        <xsl:with-param name="clefColor" select="@clef.color"/>
        <xsl:with-param name="clefDis" select="@clef.dis"/>
        <xsl:with-param name="clefDisPlace" select="@clef.dis.place"/>
        <xsl:with-param name="clefLine" select="@clef.line"/>
        <xsl:with-param name="clefShape" select="@clef.shape"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="mei:clef"/>
    <xsl:call-template name="setKey">
      <xsl:with-param name="keyTonic" select="ancestor-or-self::*/@key.pname"/>
      <xsl:with-param name="keyAccid" select="ancestor-or-self::*/@key.accid"/>
      <xsl:with-param name="keyMode" select="ancestor-or-self::*/@key.mode"/>
      <xsl:with-param name="keySig" select="ancestor-or-self::*/@key.sig"/>
      <xsl:with-param name="keySigMixed" select="ancestor-or-self::*/@key.sig.mixed"/>
    </xsl:call-template>
    <xsl:apply-templates select="mei:keySig"/>
    <xsl:if test="ancestor-or-self::*/@*[starts-with(name(),'mensur.')]">
      <xsl:if test="ancestor-or-self::*/@mensur.color">
        <xsl:value-of select="'\override Staff.TimeSignature.color = #'"/>
        <xsl:call-template name="setColor">
          <xsl:with-param name="color" select="ancestor-or-self::*[@mensur.color][1]/@mensur.color"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="setMensur">
        <xsl:with-param name="mensurDot" select="ancestor-or-self::*[@mensur.dot][1]/@mensur.dot"/>
        <xsl:with-param name="mensurSign" select="ancestor-or-self::*[@mensur.sign][1]/@mensur.sign"/>
        <xsl:with-param name="mensurSlash" select="ancestor-or-self::*[@mensur.slash][1]/@mensur.slash"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="ancestor-or-self::*/@*[starts-with(name(),'meter.')]">
      <xsl:call-template name="meterSig">
        <xsl:with-param name="meterSymbol" select="ancestor-or-self::*[@meter.sym][1]/@meter.sym"/>
        <xsl:with-param name="meterCount" select="ancestor-or-self::*[@meter.count][1]/@meter.count"/>
        <xsl:with-param name="meterUnit" select="ancestor-or-self::*[@meter.unit][1]/@meter.unit"/>
        <xsl:with-param name="meterRend" select="ancestor-or-self::*[@meter.rend][1]/@meter.rend"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="mei:meterSigGrp|mei:meterSig"/>
    <xsl:if test="ancestor::mei:scoreDef/@meter.showchange = 'false'">
      <xsl:text>\override Staff.TimeSignature.break-visibility = #'#(#f #f #f)&#32;</xsl:text>
    </xsl:if>
    <xsl:if test="(position() = last()) and ancestor::mei:staffGrp[2]/@barthru = 'false'">
      <xsl:value-of select="'\override Staff.BarLine.allow-span-bar = ##f&#32;'"/>
    </xsl:if>
    <xsl:if test="ancestor::mei:mdiv/descendant::mei:measure[1]/@n &gt; 1">
      <xsl:value-of select="concat('\set Score.currentBarNumber = #',ancestor::mei:mdiv/descendant::mei:measure[1]/@n,' ')"/>
    </xsl:if>
    <xsl:value-of select="concat('\mdiv',codepoints-to-string(xs:integer(64 + $mdivNumber)),'_staff',codepoints-to-string(xs:integer(64 + $staffNumber)))"/>
    <xsl:text>&#32;}&#10;</xsl:text>
    <!-- put lyrics under staff -->
    <xsl:for-each select="ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]//mei:verse/@n[not(.= preceding::mei:verse[ancestor::mei:staff/@n=$staffNumber]/@n)]">
      <xsl:choose>
        <xsl:when test="ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]/mei:layer/@n and (max(ancestor::mei:mdiv[1]//mei:staff[@n=$staffNumber]/mei:layer/@n) != 1)">
          <xsl:value-of select="'  \new Lyrics { '"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'  \addlyrics { '"/>
          <xsl:text>\set ignoreMelismata = ##t </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="concat('\mdiv',codepoints-to-string(xs:integer(64 + $mdivNumber)),'_staff',codepoints-to-string(xs:integer(64 + $staffNumber)),'_verse',codepoints-to-string(xs:integer(64 + .)),' }&#10;')"/>
    </xsl:for-each>
  </xsl:template>
  <!-- MEI instrument definition -->
  <xsl:template match="mei:instrDef">
    <xsl:call-template name="setMidiInstruments"/>
  </xsl:template>
  <!-- MEI section -->
  <xsl:template match="mei:section">
    <xsl:text>{&#32;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI ending -->
  <xsl:template match="mei:ending">
    <xsl:text>{&#32;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI measure -->
  <xsl:template name="measure" match="mei:measure">
    <xsl:value-of select="'  '"/>
    <xsl:if test="(ancestor::mei:measure[@n and not(@metcon='false')]/@n != preceding::mei:measure[@n and not(@metcon='false')][1]/@n + 1)">
      <xsl:call-template name="setBarNumber"/>
    </xsl:if>
    <xsl:if test="@left">
      <xsl:call-template name="setBarLine">
        <xsl:with-param name="barLineStyle" select="@left"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="@metcon='false'">
      <xsl:value-of select="concat('\partial ',min(ancestor::mei:measure/descendant::*/@dur),'&#32;')"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="@right">
      <xsl:call-template name="setBarLine">
        <xsl:with-param name="barLineStyle" select="@right"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="@n">
      <xsl:value-of select="concat('%',@n)"/>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <!-- MEI layers -->
  <xsl:template match="mei:layer">
    <xml:text>{ </xml:text>
    <xsl:if test="@beam.group">
      <xsl:call-template name="setBeaming"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xml:text>} </xml:text>
    <xsl:if test="following-sibling::mei:layer">
      <xml:text>\\ </xml:text>
    </xsl:if>
  </xsl:template>
  <!-- MEI clefs -->
  <xsl:template name="setClef" match="mei:clef">
    <xsl:param name="clefColor" select="@color"/>
    <xsl:param name="clefDis" select="@dis"/>
    <xsl:param name="clefDisPlace" select="@dis.place"/>
    <xsl:param name="clefLine" select="@line"/>
    <xsl:param name="clefShape" select="@shape"/>
    <xsl:variable name="clefTrans">
      <xsl:choose>
        <xsl:when test="$clefDisPlace='above'">
          <xsl:value-of select="number($clefDis) - 1"/>
        </xsl:when>
        <xsl:when test="$clefDisPlace='below'">
          <xsl:value-of select="-1 * number($clefDis) + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="clefPos" select="2 * number($clefLine) - 6"/>
    <xsl:variable name="cOffset">
      <xsl:choose>
        <xsl:when test="$clefShape='F'">
          <xsl:value-of select="4"/>
        </xsl:when>
        <xsl:when test="contains($clefShape,'G')">
          <xsl:value-of select="-4"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$clefColor">
      <xsl:if test="name()='clef'">
        <xsl:value-of select="'\once '"/>
      </xsl:if>
      <xsl:value-of select="'\override Staff.Clef.color = #'"/>
      <xsl:call-template name="setColor">
        <xsl:with-param name="color" select="$clefColor"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:value-of select="concat('\set Staff.clefGlyph = #','&quot;clefs.',$clefShape,'&quot; ')"/>
    <xsl:value-of select="concat('\set Staff.clefPosition = #',$clefPos,' ')"/>
    <xsl:value-of select="concat('\set Staff.clefTransposition = #',$clefTrans,' ')"/>
    <xsl:value-of select="concat('\set Staff.middleCPosition = #',$clefPos + $cOffset - $clefTrans,' ')"/>
    <xsl:value-of select="concat('\set Staff.middleCClefPosition = #',$clefPos + $cOffset - $clefTrans,' ')"/>
  </xsl:template>
  <!-- MEI notes -->
  <xsl:template match="mei:note[@pname]">
    <xsl:variable name="noteKey" select="concat('#',./@xml:id)"/>
    <xsl:apply-templates select="ancestor::mei:measure/descendant::*[@startid = $noteKey]" mode="pre"/>
    <xsl:if test="@staff and @staff != ancestor::mei:staff/@n">
      <xsl:value-of select="concat('\change Staff = &quot;staff ',@staff,'&quot;&#32;')"/>
    </xsl:if>
    <xsl:if test="@visible='false'">
      <xml:text>\once \hideNotes </xml:text>
    </xsl:if>
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override NoteHead.color = #'"/>
      <xsl:call-template name="setColor"/>
      <xsl:value-of select="'\once \override Stem.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@head.color">
      <xsl:value-of select="'\once \override NoteHead.color = #'"/>
      <xsl:call-template name="setColor">
        <xsl:with-param name="color" select="@head.color"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="setStemDir"/>
    <xsl:if test="@grace and not(preceding::mei:note[1]/@grace)">
      <xsl:call-template name="setGraceNote"/>
      <xsl:if test="ancestor::mei:beam and position()=1">
        <xml:text>{</xml:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="(starts-with(@tuplet,'i') or (ancestor::mei:measure/mei:tupletSpan/@startid = $noteKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="concat('\tuplet ',ancestor::mei:measure/mei:tupletSpan[@startid = $noteKey]/@num,'/',ancestor::mei:measure/mei:tupletSpan[@startid = $noteKey]/@numbase,' { ')"/>
    </xsl:if>
    <xsl:if test="@head.shape = 'x'">
      <xml:text>\xNote </xml:text>
    </xsl:if>
    <xsl:if test="@head.mod">
      <xsl:call-template name="modifyNotehead"/>
    </xsl:if>
    <xsl:apply-templates select="mei:accid" mode="pre"/>
    <xsl:value-of select="@pname"/>
    <xsl:if test="@accid or @accid.ges or child::mei:accid">
      <xsl:choose>
        <xsl:when test="not(@accid.ges)">
          <xsl:call-template name="setAccidental">
            <xsl:with-param name="accidental" select="descendant-or-self::*/@accid"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="setAccidental">
            <xsl:with-param name="accidental" select="descendant-or-self::*/@accid.ges"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:call-template name="setOctave"/>
    <xsl:if test="descendant-or-self::*/@accid or child::mei:accid/@func='caution'">
      <xml:text>!</xml:text>
    </xsl:if>
    <xsl:if test="not(parent::mei:chord) and not(parent::mei:fTrem[@measperf])">
      <xsl:call-template name="setDuration"/>
    </xsl:if>
    <xsl:if test="parent::mei:fTrem/@measperf">
      <xsl:value-of select="parent::mei:fTrem/@measperf"/>
    </xsl:if>
    <xsl:if test="parent::mei:bTrem and not(@grace) and contains(@stem.mod,'slash')">
      <xsl:choose>
        <xsl:when test="parent::mei:bTrem[@measperf]">
          <xsl:value-of select="concat(':',parent::mei:bTrem/@measperf)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(':',8 * number(substring(@stem.mod,1,1)))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="contains(@tie,'i') or contains(@tie,'m') or (ancestor::mei:measure/mei:tie/@startid = $noteKey)">
      <xsl:if test="ancestor::mei:measure/mei:tie/@startid = $noteKey">
        <xsl:call-template name="setMarkupDirection">
          <xsl:with-param name="direction" select="ancestor::mei:measure/mei:tie[@startid = $noteKey]/@curvedir"/>
        </xsl:call-template>
      </xsl:if>
      <xml:text>~</xml:text>
    </xsl:if>
    <xsl:if test="contains(@beam,'i') or (ancestor::mei:beam and position()=1) or (ancestor::mei:measure/mei:beamSpan[not(@beam.with)]/@startid = $noteKey)">
      <xml:text>[</xml:text>
    </xsl:if>
    <xsl:if test="contains(@beam,'t') or (ancestor::mei:beam and position()=last()) or (ancestor::mei:mdiv[1]//mei:beamSpan[not(@beam.with)]/@endid = $noteKey)">
      <xml:text>]</xml:text>
    </xsl:if>
    <xsl:if test="contains(@slur,'t') or (ancestor::mei:mdiv[1]//mei:slur/@endid = $noteKey)">
      <xml:text>)</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:phrase/@endid = $noteKey">
      <xml:text>\)</xml:text>
    </xsl:if>
    <xsl:if test="contains(@slur,'i') or (ancestor::mei:measure/mei:slur/@startid = $noteKey)">
      <xsl:if test="ancestor::mei:measure/mei:slur/@startid = $noteKey">
        <xsl:call-template name="setMarkupDirection">
          <xsl:with-param name="direction" select="ancestor::mei:measure/mei:slur[@startid = $noteKey]/@curvedir"/>
        </xsl:call-template>
      </xsl:if>
      <xml:text>(</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:measure/mei:phrase/@startid = $noteKey">
      <xml:text>\(</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:hairpin/@endid = $noteKey or ancestor::mei:mdiv[1]//mei:dynam/@endid = $noteKey">
      <xml:text>\!</xml:text>
    </xsl:if>
    <xsl:if test="@artic">
      <xsl:call-template name="artic"/>
    </xsl:if>
    <xsl:apply-templates select="mei:artic"/>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:trill/@endid = $noteKey">
      <xml:text>\stopTrillSpan</xml:text>
    </xsl:if>
    <xsl:if test="@ornam">
      <xsl:call-template name="setOrnament"/>
    </xsl:if>
    <xsl:if test="@fermata and not(ancestor::mei:measure/mei:fermata/@startid = $noteKey)">
      <xsl:call-template name="fermata"/>
    </xsl:if>
    <xsl:if test="contains(@gliss,'i') or (ancestor::mei:measure/mei:gliss/@startid = $noteKey)">
      <xsl:text>\glissando</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/*[@startid = $noteKey]"/>
    <xsl:if test="(starts-with(@tuplet,'t') or (ancestor::mei:mdiv[1]//mei:tupletSpan/@endid = $noteKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="' }'"/>
    </xsl:if>
    <xsl:if test="@grace and ancestor::mei:beam and position()=last()">
      <xml:text>}</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:octave/@endid = $noteKey">
      <xsl:value-of select="'\ottava #0 '"/>
    </xsl:if>
    <xsl:value-of select="' '"/>
    <xsl:if test="@staff and @staff != ancestor::mei:staff/@n">
      <xsl:value-of select="concat('\change Staff = &quot;staff ',ancestor::mei:staff/@n,'&quot;&#32;')"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI chords -->
  <xsl:template match="mei:chord[@copyof]">
    <xsl:apply-templates select="ancestor::mei:mdiv[1]//mei:chord[@xml:id = substring-after(current()/@copyof,'#')]"/>
  </xsl:template>
  <xsl:template match="mei:chord">
    <xsl:variable name="chordKey" select="concat('#',./@xml:id)"/>
    <xsl:variable name="subChordKeys" select="descendant-or-self::*/concat('#',./@xml:id)"/>
    <xsl:apply-templates select="ancestor::mei:measure/descendant::*[@startid = $chordKey or tokenize(@plist,' ') = $subChordKeys]" mode="pre"/>
    <xsl:if test="@visible='false'">
      <xml:text>\once \hideNotes </xml:text>
    </xsl:if>
    <xsl:call-template name="setStemDir"/>
    <xsl:if test="(starts-with(@tuplet,'i') or (ancestor::mei:measure/mei:tupletSpan/@startid = $chordKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="concat('\tuplet ',ancestor::mei:measure/mei:tupletSpan[@startid = $chordKey]/@num,'/',ancestor::mei:measure/mei:tupletSpan[@startid = $chordKey]/@numbase,' { ')"/>
    </xsl:if>
    <xml:text>&lt; </xml:text>
    <xsl:apply-templates select="mei:note"/>
    <xml:text>&gt;</xml:text>
    <xsl:call-template name="setDuration"/>
    <xsl:if test="parent::mei:bTrem and not(@grace) and contains(@stem.mod,'slash')">
      <xsl:choose>
        <xsl:when test="parent::mei:bTrem[@measperf]">
          <xsl:value-of select="concat(':',parent::mei:bTrem/@measperf)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(':',8 * number(substring(@stem.mod,1,1)))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="contains(@tie,'i') or contains(@tie,'m') or (ancestor::mei:measure/mei:tie/@startid = $chordKey)">
      <xsl:if test="ancestor::mei:measure/mei:tie/@startid = $chordKey">
        <xsl:call-template name="setMarkupDirection">
          <xsl:with-param name="direction" select="ancestor::mei:measure/mei:tie[@startid = $chordKey]/@curvedir"/>
        </xsl:call-template>
      </xsl:if>
      <xml:text>~</xml:text>
    </xsl:if>
    <xsl:if test="contains(@beam,'i') or (ancestor::mei:beam and position()=1) or (ancestor::mei:measure/mei:beamSpan[not(@beam.with)]/@startid = $chordKey)">
      <xml:text>[</xml:text>
    </xsl:if>
    <xsl:if test="contains(@beam,'t') or (ancestor::mei:beam and position()=last()) or (ancestor::mei:mdiv[1]//mei:beamSpan[not(@beam.with)]/@endid = $chordKey)">
      <xml:text>]</xml:text>
    </xsl:if>
    <xsl:if test="contains(@slur,'t') or (ancestor::mei:mdiv[1]//mei:slur/@endid = $chordKey)">
      <xml:text>)</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:phrase/@endid = $chordKey">
      <xml:text>\)</xml:text>
    </xsl:if>
    <xsl:if test="contains(@slur,'i') or (//mei:slur/@startid = $chordKey)">
      <xsl:if test="ancestor::mei:measure/mei:slur/@startid = $chordKey">
        <xsl:call-template name="setMarkupDirection">
          <xsl:with-param name="direction" select="ancestor::mei:measure/mei:slur[@startid = $chordKey]/@curvedir"/>
        </xsl:call-template>
      </xsl:if>
      <xml:text>(</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:measure/mei:phrase/@startid = $chordKey">
      <xml:text>\(</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:measure/mei:arpeg[@startid = $chordKey or tokenize(@plist,' ') = $subChordKeys]">
      <xml:text>\arpeggio</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:hairpin/@endid = $chordKey or ancestor::mei:mdiv[1]//mei:dynam/@endid = $chordKey">
      <xml:text>\!</xml:text>
    </xsl:if>
    <xsl:if test="@artic">
      <xsl:call-template name="artic"/>
    </xsl:if>
    <xsl:apply-templates select="mei:artic"/>
    <xsl:apply-templates select="ancestor::mei:measure/mei:dynam[@startid = $chordKey]"/>
    <xsl:apply-templates select="ancestor::mei:measure/mei:hairpin[@startid = $chordKey]"/>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:trill/@endid = $chordKey">
      <xml:text>\stopTrillSpan</xml:text>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/mei:mordent[@startid = $chordKey]"/>
    <xsl:apply-templates select="ancestor::mei:measure/mei:trill[@startid = $chordKey]"/>
    <xsl:apply-templates select="ancestor::mei:measure/mei:turn[@startid = $chordKey]"/>
    <xsl:if test="@ornam">
      <xsl:call-template name="setOrnament"/>
    </xsl:if>
    <xsl:if test="ancestor::mei:measure/mei:gliss/@startid = $chordKey">
      <xsl:text>\glissando</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/mei:dir[@startid = $chordKey]"/>
    <xsl:if test="@fermata and not(ancestor::mei:measure/mei:fermata/@startid = $chordKey)">
      <xsl:call-template name="fermata"/>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/mei:fermata[@startid = $chordKey]"/>
    <xsl:apply-templates select="ancestor::mei:measure/mei:pedal[@startid = $chordKey]"/>
    <xsl:if test="(starts-with(@tuplet,'t') or (ancestor::mei:mdiv[1]//mei:tupletSpan/@endid = $chordKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="' }'"/>
    </xsl:if>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:octave/@endid = $chordKey">
      <xsl:value-of select="'\ottava #0'"/>
    </xsl:if>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI rests -->
  <xsl:template match="mei:rest[@copyof]">
    <xsl:apply-templates select="ancestor::mei:mdiv[1]//mei:rest[@xml:id = substring-after(current()/@copyof,'#')]"/>
  </xsl:template>
  <xsl:template match="mei:rest">
    <xsl:variable name="restKey" select="concat('#',./@xml:id)"/>
    <xsl:if test="@staff and @staff != ancestor::mei:staff/@n">
      <xsl:value-of select="concat('\change Staff = &quot;staff ',@staff,'&quot;&#32;')"/>
    </xsl:if>
    <xsl:if test="@visible='false'">
      <xml:text>\once \hideNotes </xml:text>
    </xsl:if>
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Rest.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@ho or @vo">
      <xsl:text>\once \override Rest.extra-offset = #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:if test="@loc">
      <xsl:value-of select="concat('\once \override Rest.staff-position = #',@loc - 4,' ')"/>
    </xsl:if>
    <xsl:if test="(starts-with(@tuplet,'i') or (ancestor::mei:measure/mei:tupletSpan/@startid = $restKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="concat('\tuplet ',ancestor::mei:measure/mei:tupletSpan[@startid = $restKey]/@num,'/',ancestor::mei:measure/mei:tupletSpan[@startid = $restKey]/@numbase,' { ')"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@ploc and @oloc">
        <xsl:value-of select="@ploc"/>
        <xsl:call-template name="setOctave">
          <xsl:with-param name="oct" select="@oloc - 3"/>
        </xsl:call-template>
        <xsl:call-template name="setDuration"/>
        <xsl:value-of select="'\rest'"/>
      </xsl:when>
      <xsl:otherwise>
        <xml:text>r</xml:text>
        <xsl:call-template name="setDuration"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="contains(@beam,'i') or (ancestor::mei:beam and position()=1)">
      <xml:text>[</xml:text>
    </xsl:if>
    <xsl:if test="contains(@beam,'t') or (ancestor::mei:beam and position()=last())">
      <xml:text>]</xml:text>
    </xsl:if>
    <xsl:if test="ancestor::mei:mdiv[1]//mei:hairpin/@endid = $restKey or ancestor::mei:mdiv[1]//mei:dynam/@endid = $restKey">
      <xml:text>\!</xml:text>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/mei:*[@startid = $restKey]"/>
    <xsl:if test="@fermata and not(ancestor::mei:measure/mei:fermata/@startid = $restKey)">
      <xsl:call-template name="fermata"/>
    </xsl:if>
    <xsl:if test="starts-with(@tuplet,'t') or (ancestor::mei:mdiv[1]//mei:tupletSpan/@endid = $restKey)">
      <xsl:value-of select="' }'"/>
    </xsl:if>
    <xsl:value-of select="' '"/>
    <xsl:if test="@staff and @staff != ancestor::mei:staff/@n">
      <xsl:value-of select="concat('\change Staff = &quot;staff ',ancestor::mei:staff/@n,'&quot;&#32;')"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI measure rest -->
  <xsl:template match="mei:mRest[@copyof]">
    <xsl:apply-templates select="ancestor::mei:mdiv[1]//mei:mRest[@xml:id = substring-after(current()/@copyof,'#')]"/>
  </xsl:template>
  <xsl:template name="setMeasureRest" match="mei:mRest">
    <xsl:if test="@visible='false'">
      <xml:text>\once \omit MultiMeasureRest </xml:text>
    </xsl:if>
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override MultiMeasureRest.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@ho or @vo">
      <xsl:text>\once \override MultiMeasureRest.extra-offset = #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:if test="@loc">
      <xsl:value-of select="concat('\once \override MultiMeasureRest.staff-position = #',@loc - 4,' ')"/>
    </xsl:if>
    <xml:text>R</xml:text>
    <xsl:choose>
      <xsl:when test="@dur">
        <xsl:call-template name="setDuration"/>
      </xsl:when>
      <xsl:when test="preceding::*/@meter.unit">
        <xsl:value-of select="concat(preceding::*[@meter.unit][1]/@meter.unit,'*',preceding::*[@meter.count][1]/@meter.count)"/>
      </xsl:when>
      <xsl:when test="preceding::mei:meterSig/@unit">
        <xsl:value-of select="concat(preceding::mei:meterSig[@unit][1]/@unit,'*',preceding::mei:meterSig[@count][1]/@count)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@fermata or (ancestor::mei:measure/mei:fermata/@startid = concat('#',@xml:id))">
      <xsl:call-template name="fermata"/>
      <xsl:value-of select="'Markup'"/>
    </xsl:if>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI multiple rest -->
  <xsl:template match="mei:multiRest[@num]">
    <xsl:if test="@loc">
      <xsl:value-of select="concat('\once \override MultiMeasureRest.staff-position = #',@loc - 4,' ')"/>
    </xsl:if>
    <xml:text>\once \compressFullBarRests </xml:text>
    <xml:text>R1*</xml:text>
    <xsl:choose>
      <xsl:when test="preceding::mei:meterSig">
        <xsl:call-template name="durationMultiplier">
          <xsl:with-param name="decimalnum" select="@num * preceding::mei:meterSig[@count][1]/@count div preceding::mei:meterSig[@unit][1]/@unit"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="durationMultiplier">
          <xsl:with-param name="decimalnum" select="@num * preceding::*[@meter.count][1]/@meter.count div preceding::*[@meter.unit][1]/@meter.unit"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="ancestor::mei:measure/mei:fermata/@startid = concat('#',@xml:id)">
      <xsl:call-template name="fermata"/>
      <xsl:value-of select="'Markup'"/>
    </xsl:if>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI spaces -->
  <xsl:template match="mei:space">
    <xml:text>s</xml:text>
    <xsl:call-template name="setDuration"/>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI measure space -->
  <xsl:template name="setMeasureSpace" match="mei:mSpace">
    <xml:text>s</xml:text>
    <xsl:choose>
      <xsl:when test="@dur">
        <xsl:call-template name="setDuration"/>
      </xsl:when>
      <xsl:when test="preceding::*/@meter.unit">
        <xsl:value-of select="concat(preceding::mei:scoreDef[@meter.unit][1]//@meter.unit,'*',preceding::mei:scoreDef[@meter.count][1]//@meter.count)"/>
      </xsl:when>
      <xsl:when test="preceding::mei:meterSig/@unit">
        <xsl:value-of select="concat(preceding::mei:meterSig[@unit][1]/@unit,'*',preceding::mei:meterSig[@count][1]/@count)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI accidental -->
  <xsl:template match="mei:accid" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Accidental.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@place='above'">
      <xml:text>\once \set suggestAccidentals = ##t </xml:text>
    </xsl:if>
    <xsl:if test="@ho or @vo">
      <xsl:text>\once \override Accidental.extra-offset = #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI beam -->
  <xsl:template match="mei:beam">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Beam.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@form = 'acc'">
        <xsl:text>\once \override Beam.grow-direction = #LEFT </xsl:text>
      </xsl:when>
      <xsl:when test="@form = 'rit'">
        <xsl:text>\once \override Beam.grow-direction = #RIGHT </xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI beam -->
  <xsl:template match="mei:beamSpan" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Beam.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI bowed tremolo -->
  <xsl:template match="mei:bTrem">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI fingered tremolo -->
  <xsl:template match="mei:fTrem[@measperf]">
    <xsl:value-of select="concat('\repeat tremolo ',@measperf div child::*[1]/@dur,' {')"/>
    <xsl:apply-templates/>
    <xsl:value-of select="'} '"/>
  </xsl:template>
  <!-- MEI tuplet -->
  <xsl:template match="mei:tuplet[@copyof]">
    <xsl:apply-templates select="ancestor::mei:mdiv[1]//mei:tuplet[@xml:id = substring-after(current()/@copyof,'#')]"/>
  </xsl:template>
  <xsl:template match="mei:tuplet">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override TupletBracket.color = #'"/>
      <xsl:call-template name="setColor"/>
      <xsl:value-of select="'\once \override TupletNumber.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@bracket.visible">
      <xsl:value-of select="concat('\once \override TupletBracket.bracket-visibility = ##',substring(@bracket.visible,1,1),' ')"/>
    </xsl:if>
    <xsl:if test="@num.visible='false'">
      <xsl:value-of select="'\once \omit TupletNumber '"/>
    </xsl:if>
    <xsl:if test="@num.format='ratio'">
      <xsl:value-of select="'\once \override TupletNumber.text = #tuplet-number::calc-fraction-text '"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@bracket.place='above' or @num.place='above'">
        <xsl:value-of select="'\once \tupletUp '"/>
      </xsl:when>
      <xsl:when test="@bracket.place='below' or @num.place='below'">
        <xsl:value-of select="'\once \tupletDown '"/>
      </xsl:when>
    </xsl:choose>
    <xsl:value-of select="concat('\tuplet ',@num,'/',@numbase,' { ')"/>
    <xsl:apply-templates/>
    <xsl:text>} </xsl:text>
  </xsl:template>
  <!-- MEI tuplet span -->
  <xsl:template match="mei:tupletSpan" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override TupletBracket.color = #'"/>
      <xsl:call-template name="setColor"/>
      <xsl:value-of select="'\once \override TupletNumber.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@bracket.visible">
      <xsl:value-of select="concat('\once \override TupletBracket.bracket-visibility = ##',substring(@bracket.visible,1,1),' ')"/>
    </xsl:if>
    <xsl:if test="@num.visible='false'">
      <xsl:value-of select="'\once \omit TupletNumber '"/>
    </xsl:if>
    <xsl:if test="@num.format='ratio'">
      <xsl:value-of select="'\once \override TupletNumber.text = #tuplet-number::calc-fraction-text '"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@bracket.place='above' or @num.place='above'">
        <xsl:value-of select="'\once \tupletUp '"/>
      </xsl:when>
      <xsl:when test="@bracket.place='below' or @num.place='below'">
        <xsl:value-of select="'\once \tupletDown '"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- MEI articulation -->
  <xsl:template name="artic" match="mei:artic">
    <xsl:param name="articList" select="@artic"/>
    <xsl:if test="self::mei:artic">
      <xsl:if test="@color">
        <xsl:value-of select="'-\tweak Script.color #'"/>
        <xsl:call-template name="setColor"/>
      </xsl:if>
      <xsl:if test="@ho or @vo">
        <xsl:text>-\tweak Script.extra-offset #&apos;</xsl:text>
        <xsl:call-template name="setOffset"/>
      </xsl:if>
      <xsl:call-template name="setMarkupDirection"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="contains($articList,' ')">
        <xsl:call-template name="setArticulation">
          <xsl:with-param name="articulation" select="substring-before($articList,' ')"/>
        </xsl:call-template>
        <xsl:call-template name="artic">
          <xsl:with-param name="articList" select="substring-after($articList,' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="setArticulation">
          <xsl:with-param name="articulation" select="$articList"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI dot -->
  <xsl:template match="mei:dot">
    <xsl:text>.</xsl:text>
  </xsl:template>
  <!-- MEI fermata -->
  <xsl:template name="fermata" match="mei:fermata">
    <xsl:choose>
      <xsl:when test="self::mei:fermata">
        <xsl:if test="@color">
          <xsl:value-of select="'-\tweak Script.color #'"/>
          <xsl:call-template name="setColor"/>
        </xsl:if>
        <xsl:if test="@ho or @vo">
          <xsl:text>-\tweak Script.extra-offset #&apos;</xsl:text>
          <xsl:call-template name="setOffset"/>
        </xsl:if>
        <xsl:call-template name="setMarkupDirection"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@fermata='above'">
          <xsl:text>^</xsl:text>
        </xsl:if>
        <xsl:if test="@fermata='below'">
          <xsl:text>_</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="not(@glyphnum)">
        <xsl:choose>
          <xsl:when test="@shape = 'square'">
            <xsl:text>\longfermata</xsl:text>
          </xsl:when>
          <xsl:when test="@shape = 'angular'">
            <xsl:text>\shortfermata</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\fermata</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="setSmuflGlyph"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI mordent -->
  <xsl:template name="mordent" match="mei:mordent">
    <xsl:if test="@color">
      <xsl:value-of select="'-\tweak Script.color #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@ho or @vo">
      <xsl:text>-\tweak Script.extra-offset #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:call-template name="setMarkupDirection"/>
    <xsl:choose>
      <xsl:when test="not(@glyphnum)">
        <xsl:choose>
          <xsl:when test="@form = 'inv'">
            <xsl:text>\prall</xsl:text>
          </xsl:when>
          <xsl:when test="@long = 'yes'">
            <xsl:text>\prallprall</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\mordent</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="setSmuflGlyph"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI ornament -->
  <xsl:template name="ornam" match="mei:ornam">
    <!-- Not yet implemented -->
  </xsl:template>
  <!-- MEI trill -->
  <xsl:template name="trill" match="mei:trill">
    <xsl:choose>
      <xsl:when test="@endid and @endid != @startid">
        <xsl:if test="@color">
          <xsl:value-of select="'-\tweak TrillSpanner.color #'"/>
          <xsl:call-template name="setColor"/>
        </xsl:if>
        <xsl:if test="@lform">
          <xsl:text>-\tweak TrillSpanner.style #'</xsl:text>
          <xsl:call-template name="setLineForm"/>
        </xsl:if>
        <xsl:if test="@lwidth">
          <xsl:text>-\tweak TrillSpanner.thickness #</xsl:text>
          <xsl:call-template name="setLineWidth"/>
        </xsl:if>
        <xsl:if test="@place and @place='below'">
          <xsl:text>-\tweak TrillSpanner.direction #</xsl:text>
          <xsl:call-template name="setDirection"/>
        </xsl:if>
        <xsl:if test="@ho or @vo">
          <xsl:text>-\tweak TrillSpanner.extra-offset #&apos;</xsl:text>
          <xsl:call-template name="setOffset"/>
        </xsl:if>
        <xsl:call-template name="setMarkupDirection"/>
        <xml:text>\startTrillSpan</xml:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@color">
          <xsl:value-of select="'-\tweak Script.color #'"/>
          <xsl:call-template name="setColor"/>
        </xsl:if>
        <xsl:if test="@ho or @vo">
          <xsl:text>-\tweak Script.extra-offset #&apos;</xsl:text>
          <xsl:call-template name="setOffset"/>
        </xsl:if>
        <xsl:call-template name="setMarkupDirection"/>
        <xsl:choose>
          <xsl:when test="not(@glyphnum)">
            <xml:text>\trill</xml:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="setSmuflGlyph"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI symbol -->
  <xsl:template name="symbol" match="mei:symbol">
    <xsl:call-template name="setSmuflGlyph"/>
  </xsl:template>
  <!-- MEI turn -->
  <xsl:template name="turn" match="mei:turn">
    <xsl:if test="@color">
      <xsl:value-of select="'-\tweak Script.color #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@ho or @vo">
      <xsl:text>-\tweak Script.extra-offset #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:call-template name="setMarkupDirection"/>
    <xsl:choose>
      <xsl:when test="not(@glyphnum)">
        <xsl:choose>
          <xsl:when test="@form = 'inv'">
            <xsl:text>\reverseturn</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\turn</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="setSmuflGlyph"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI breath -->
  <xsl:template match="mei:breath" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override BreathingSign.color = '"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@ho or @vo">
      <xsl:text>\once \override BreathingSign.extra-offset #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:breath">
    <xsl:text>\breathe</xsl:text>
  </xsl:template>
  <!-- MEI octave -->
  <xsl:template match="mei:octave" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Staff.OttavaBracket.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@ho or @vo">
      <xsl:text>\once \override Staff.OttavaBracket.extra-offset = #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:if test="@lform">
      <xsl:text>\once \override Staff.OttavaBracket.style = #'</xsl:text>
      <xsl:call-template name="setLineForm"/>
    </xsl:if>
    <xsl:if test="@lwidth">
      <xsl:text>\once \override Staff.OttavaBracket.thickness = #</xsl:text>
      <xsl:call-template name="setLineWidth"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@dis.place = 'above'">
        <xsl:value-of select="concat('\ottava #',round(number(@dis) div 8),' ')"/>
        <xml:text>\unset Staff.middleCPosition </xml:text>
      </xsl:when>
      <xsl:when test="@dis.place = 'below'">
        <xsl:value-of select="concat('\ottava #-',round(number(@dis) div 8),' ')"/>
        <xml:text>\unset Staff.middleCPosition </xml:text>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI phrase -->
  <xsl:template match="mei:phrase" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override PhrasingSlur.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="(@startvo or @endvo or @startho or @endho)">
      <xsl:text>\once \override PhrasingSlur.positions = #&apos;</xsl:text>
      <xsl:call-template name="setOffset2"/>
    </xsl:if>
    <xsl:if test="@lform">
      <xsl:value-of select="concat('\once \phrasingSlur',translate(substring(@lform,1,1),'ds','DS'),substring(@lform,2),' ')"/>
    </xsl:if>
    <xsl:if test="@lwidth">
      <xsl:text>\once \override PhrasingSlur.thickness = #</xsl:text>
      <xsl:call-template name="setLineWidth"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI slur -->
  <xsl:template match="mei:slur" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Slur.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="(@startvo or @endvo or @startho or @endho)">
      <xsl:text>\once \override Slur.positions = #&apos;</xsl:text>
      <xsl:call-template name="setOffset2"/>
    </xsl:if>
    <xsl:if test="@lform">
      <xsl:value-of select="concat('\once \slur',translate(substring(@lform,1,1),'ds','DS'),substring(@lform,2),' ')"/>
    </xsl:if>
    <xsl:if test="@lwidth">
      <xsl:text>\once \override Slur.thickness = #</xsl:text>
      <xsl:call-template name="setLineWidth"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI tie -->
  <xsl:template match="mei:tie" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Tie.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="(@startvo or @endvo or @startho or @endho)">
      <xsl:text>\once \override Tie.positions = #&apos;</xsl:text>
      <xsl:call-template name="setOffset2"/>
    </xsl:if>
    <xsl:if test="@lwidth">
      <xsl:text>\once \override Tie.thickness = #</xsl:text>
      <xsl:call-template name="setLineWidth"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI arpeggio -->
  <xsl:template match="mei:arpeg" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Arpeggio.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@order = 'up'">
        <xml:text>\once \arpeggioArrowUp </xml:text>
      </xsl:when>
      <xsl:when test="@order = 'down'">
        <xml:text>\once \arpeggioArrowDown </xml:text>
      </xsl:when>
      <xsl:when test="@order = 'nonarp'">
        <xml:text>\once \arpeggioBracket </xml:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- MEI glissando -->
  <xsl:template match="mei:gliss" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Glissando.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@lform">
      <xsl:text>\once \override Glissando.style = #'</xsl:text>
      <xsl:call-template name="setLineForm"/>
    </xsl:if>
    <xsl:if test="@lwidth">
      <xsl:text>\once \override Glissando.thickness = #</xsl:text>
      <xsl:call-template name="setLineWidth"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI dynamic -->
  <xsl:template match="mei:dynam" mode="pre"/>
  <xsl:template match="mei:dynam">
    <xsl:if test="@ho or @vo">
      <xsl:text>-\tweak DynamicText.extra-offset #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:call-template name="setMarkupDirection"/>
    <xsl:value-of select="concat('\',translate(.,'.',''))"/>
  </xsl:template>
  <!-- MEI hairpin -->
  <xsl:template match="mei:hairpin">
    <xsl:if test="@color">
      <xsl:value-of select="'-\tweak Hairpin.color #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@lform">
      <xsl:text>-\tweak Hairpin.style #'</xsl:text>
      <xsl:call-template name="setLineForm"/>
    </xsl:if>
    <xsl:if test="@lwidth">
      <xsl:text>-\tweak Hairpin.thickness #</xsl:text>
      <xsl:call-template name="setLineWidth"/>
    </xsl:if>
    <xsl:call-template name="setMarkupDirection"/>
    <xsl:choose>
      <xsl:when test="@form = 'cres'">
        <xml:text>\&lt;</xml:text>
      </xsl:when>
      <xsl:when test="@form = 'dim'">
        <xml:text>\&gt;</xml:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- MEI pedal -->
  <xsl:template match="mei:pedal" mode="pre">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Staff.SustainPedal.color = #'"/>
      <xsl:call-template name="setColor"/>
      <xsl:value-of select="'\once \override Staff.PianoPedalBracket.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@lform">
      <xsl:text>\once \override Staff.PianoPedalBracket.style = #'</xsl:text>
      <xsl:call-template name="setLineForm"/>
    </xsl:if>
    <xsl:if test="@lwidth">
      <xsl:text>\once \override Staff.PianoPedalBracket.thickness = #</xsl:text>
      <xsl:call-template name="setLineWidth"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@form = 'line'">
        <xsl:text>\once \set Staff.pedalSustainStyle = #'bracket </xsl:text>
      </xsl:when>
      <xsl:when test="@form = 'pedstar'">
        <xsl:text>\once \set Staff.pedalSustainStyle = #'text </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="mei:pedal">
    <xsl:choose>
      <xsl:when test="@dir = 'down'">
        <xml:text>\sustainOn</xml:text>
      </xsl:when>
      <xsl:when test="@dir = 'up'">
        <xml:text>\sustainOff</xml:text>
      </xsl:when>
      <xsl:when test="@dir = 'half'">
      </xsl:when>
      <xsl:when test="@dir = 'bounce'">
        <xml:text>\sustainOff\sustainOn</xml:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- MEI harmony -->
  <xsl:template match="mei:harm[mei:fb]">
    <xsl:param name="meterCount">
      <xsl:choose>
        <xsl:when test="preceding::*/@meter.count">
          <xsl:value-of select="preceding::*[@meter.count][1]/@meter.count"/>
        </xsl:when>
        <xsl:when test="preceding::mei:meterSig[ancestor::mei:scoreDef or (ancestor::mei:staffDef/@n = current()/ancestor::mei:staff/@n)]/@count">
          <xsl:value-of select="preceding::mei:meterSig[ancestor::mei:scoreDef or (ancestor::mei:staffDef/@n = current()/ancestor::mei:staff/@n)][1]/@count"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>1</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="meterUnit">
      <xsl:choose>
        <xsl:when test="preceding::*/@meter.unit">
          <xsl:value-of select="preceding::*[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <xsl:when test="preceding::mei:meterSig[ancestor::mei:scoreDef or (ancestor::mei:staffDef/@n = current()/ancestor::mei:staff/@n)]/@unit">
          <xsl:value-of select="preceding::mei:meterSig[ancestor::mei:scoreDef or (ancestor::mei:staffDef/@n = current()/ancestor::mei:staff/@n)][1]/@unit"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>1</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:if test="(descendant-or-self::*/@place = 'above') and not(preceding::mei:harm[ancestor::mei:music][@staff = current()/@staff][1]/descendant-or-self::*/@place = 'above')">
      <xsl:text>\bassFigureStaffAlignmentUp&#10;&#32;&#32;</xsl:text>
    </xsl:if>
    <xsl:if test="(descendant-or-self::*/@place = 'below') and not(preceding::mei:harm[ancestor::mei:music][@staff = current()/@staff][1]/descendant-or-self::*/@place = 'below')">
      <xsl:text>\bassFigureStaffAlignmentDown&#10;&#32;&#32;</xsl:text>
    </xsl:if>
    <xsl:if test="not(preceding-sibling::mei:harm[@staff = current()/@staff]) and @tstamp &gt; 1">
      <xsl:value-of select="concat('s',$meterUnit)"/>
      <xsl:if test="@tstamp != 2">
        <xsl:text>*</xsl:text>
        <xsl:call-template name="durationMultiplier">
          <xsl:with-param name="decimalnum" select="@tstamp - 1"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="mei:fb"/>
    <xsl:value-of select="$meterUnit"/>
    <xsl:choose>
      <xsl:when test="not(following-sibling::mei:harm[@staff = current()/@staff][mei:fb]) and @tstamp != $meterCount">
        <xsl:variable name="meterFactor">
          <xsl:call-template name="durationMultiplier">
            <xsl:with-param name="decimalnum" select="$meterCount - @tstamp + 1"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat('*',$meterFactor)"/>
      </xsl:when>
      <xsl:when test="following-sibling::mei:harm[@staff = current()/@staff]/mei:fb and (following-sibling::mei:harm[@staff = current()/@staff][mei:fb][1]/@tstamp - @tstamp != 1)">
        <xsl:variable name="meterFactor">
          <xsl:call-template name="durationMultiplier">
            <xsl:with-param name="decimalnum" select="following-sibling::mei:harm[@staff = current()/@staff][mei:fb][1]/@tstamp - @tstamp"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat('*',$meterFactor)"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <!-- MEI finger group -->
  <xsl:template match="mei:fingGrp">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI finger -->
  <xsl:template match="mei:fing" mode="pre"/>
  <xsl:template match="mei:fing">
    <xsl:if test="@ho or @vo">
      <xsl:text>-\tweak Fingering.extra-offset #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:call-template name="setMarkupDirection"/>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI figured bass -->
  <xsl:template match="mei:fb">
    <xsl:text>&lt;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>
  <!-- MEI figure from figured bass -->
  <xsl:template match="mei:f">
    <xsl:if test="string-length() = string-length(translate(.,'123456789',''))">
      <xsl:text>_</xsl:text>
    </xsl:if>
    <xsl:value-of select="translate(.,'♭♮♯&lt;&gt;','-!+')"/>
    <xsl:if test="contains(.,'\')">
      <xsl:text>\</xsl:text>
    </xsl:if>
    <xsl:if test="following-sibling::mei:f">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- MEI lyrics -->
  <xsl:template match="mei:lyrics">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Lyrics.LyricText.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@fontweight">
      <xsl:value-of select="concat('\once \override Lyrics.LyricText.font-series = #',@fontweight,' ')"/>
    </xsl:if>
    <xsl:if test="@fontstyle">
      <xsl:value-of select="concat('\once \override Lyrics.LyricText.font-shape = #',@fontstyle,' ')"/>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <!-- MEI ligature -->
  <xsl:template match="mei:ligature">
    <xsl:text>\[&#32;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#32;\]&#32;</xsl:text>
  </xsl:template>
  <!-- MEI tempo -->
  <xsl:template match="mei:tempo" mode="pre">
    <xsl:if test="@place = 'below'">
      <xsl:value-of select="'\once \override Score.MetronomeMark.direction = #DOWN '"/>
    </xsl:if>
    <xsl:if test="@ho or @vo">
      <xsl:text>\once \override Score.MetronomeMark.extra-offset = #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:value-of select="'\tempo '"/>
    <xsl:if test="string(.)">
      <xsl:value-of select="'\markup {'"/>
      <xsl:apply-templates/>
      <xsl:value-of select="'} '"/>
    </xsl:if>
    <xsl:if test="@mm.unit and @mm">
      <xsl:value-of select="@mm.unit"/>
      <xsl:call-template name="setDots">
        <xsl:with-param name="dots" select="@mm.dots"/>
      </xsl:call-template>
      <xsl:value-of select="concat(' = ',@mm)"/>
    </xsl:if>
    <xsl:value-of select="'&#10;  '"/>
    <xsl:if test="@midi.bpm and not(@mm)">
      <xsl:text>\once \set Score.tempoHideNote = ##t&#32;</xsl:text>
      <xsl:value-of select="concat('\tempo 4 = ',@midi.bpm,'&#10;  ')"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI directive -->
  <xsl:template match="mei:dir" mode="pre"/>
  <xsl:template match="mei:dir">
    <xsl:if test="@ho or @vo">
      <xsl:text>-\tweak TextScript.extra-offset #&apos;</xsl:text>
      <xsl:call-template name="setOffset"/>
    </xsl:if>
    <xsl:call-template name="setMarkupDirection"/>
    <xsl:text>\markup {</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI line -->
  <xsl:template match="mei:l">
    <xsl:text>\line {</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI line group -->
  <xsl:template match="mei:lg">
    <xsl:text>\column {</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI label -->
  <xsl:template match="mei:label">
    <xsl:text>\markup {</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI paragraph -->
  <xsl:template match="mei:p">
    <xsl:choose>
      <xsl:when test="not(child::*)">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI ref -->
  <xsl:template match="mei:ref">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI rend -->
  <xsl:template match="mei:rend">
    <xsl:if test="@color">
      <xsl:value-of select="'\with-color #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@fontname">
      <xsl:text>\override #'(font-name . </xsl:text>
      <xsl:value-of select="concat('&quot;',@fontname,'&quot;')"/>
      <xsl:text>) </xsl:text>
    </xsl:if>
    <xsl:if test="@fontsize and not(contains(@fontsize,'%'))">
      <xsl:choose>
        <xsl:when test="number(@fontsize)">
          <xsl:value-of select="concat('\abs-fontsize #',@fontsize,' ')"/>
        </xsl:when>
        <xsl:when test="contains(@fontsize,'pt')">
          <xsl:value-of select="concat('\abs-fontsize #',substring-before(@fontsize,'pt'),' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="setRelFontsize"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@fontweight='normal' or @fontstyle='normal'">
      <xsl:value-of select="'\normal-text '"/>
    </xsl:if>
    <xsl:if test="@fontweight != 'normal'">
      <xsl:value-of select="concat('\',@fontweight,' ')"/>
    </xsl:if>
    <xsl:if test="@fontstyle != 'normal'">
      <xsl:value-of select="concat('\',@fontstyle,' ')"/>
    </xsl:if>
    <xsl:if test="@fontfam">
      <xsl:value-of select="concat('\',@fontfam,' ')"/>
    </xsl:if>
    <xsl:if test="@halign">
      <xsl:call-template name="setHalign"/>
    </xsl:if>
    <xsl:if test="@rotation">
      <xsl:value-of select="concat('\rotate #',@rotation,' ')"/>
    </xsl:if>
    <xsl:if test="contains(@rend,'italic')">
      <xsl:value-of select="'\italic '"/>
    </xsl:if>
    <xsl:if test="contains(@rend,'box')">
      <xsl:value-of select="'\box '"/>
    </xsl:if>
    <xsl:if test="contains(@rend,'circle')">
      <xsl:value-of select="'\circle '"/>
    </xsl:if>
    <xsl:if test="contains(@rend,'sub')">
      <xsl:value-of select="'\sub '"/>
    </xsl:if>
    <xsl:if test="contains(@rend,'sup')">
      <xsl:value-of select="'\super '"/>
    </xsl:if>
    <xsl:if test="contains(@rend,'underline')">
      <xsl:value-of select="'\underline '"/>
    </xsl:if>
    <xsl:if test="contains(@rend,'smcaps')">
      <xsl:value-of select="'\smallCaps '"/>
    </xsl:if>
    <xsl:text>{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>
  <!-- MEI key signature -->
  <xsl:template match="mei:keySig[@copyof]">
    <xsl:apply-templates select="ancestor::mei:mdiv[1]//mei:keySig[@xml:id = substring-after(current()/@copyof,'#')]"/>
  </xsl:template>
  <xsl:template name="setKey" match="mei:keySig">
    <xsl:param name="keyTonic" select="@pname"/>
    <xsl:param name="keyAccid" select="@accid"/>
    <xsl:param name="keyMode" select="@mode"/>
    <xsl:param name="keySig" select="@sig"/>
    <xsl:param name="keySigMixed" select="@sig.mixed"/>
    <xsl:choose>
      <xsl:when test="$keyTonic and $keyMode">
        <xsl:value-of select="concat('\key ',$keyTonic)"/>
        <xsl:if test="$keyAccid">
          <xsl:call-template name="setAccidental">
            <xsl:with-param name="accidental" select="$keyAccid"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:value-of select="concat(' \',$keyMode,' ')"/>
      </xsl:when>
      <xsl:when test="$keySig != 'mixed'">
        <xsl:call-template name="transformKey">
          <xsl:with-param name="accidentals" select="$keySig"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Not yet implemented -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="setMensur">
    <xsl:param name="mensurDot" select="@dot"/>
    <xsl:param name="mensurSign" select="@sign"/>
    <xsl:param name="mensurSlash" select="@slash"/>
    <xsl:text>\once \override Staff.TimeSignature.style = #'mensural </xsl:text>
    <!-- att.mensural.log -->
    <xsl:choose>
      <xsl:when test="$mensurSign = 'C'">
        <xsl:choose>
          <xsl:when test="($mensurDot = 'true') and ($mensurSlash = 1)">
            <xsl:value-of select="'\time 6/8 '"/>
          </xsl:when>
          <xsl:when test="($mensurDot = 'true')">
            <xsl:value-of select="'\time 6/4 '"/>
          </xsl:when>
          <xsl:when test="($mensurSlash = 1)">
            <xsl:value-of select="'\time 2/2 '"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'\time 4/4 '"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$mensurSign = 'O'">
        <xsl:choose>
          <xsl:when test="($mensurDot = 'true') and ($mensurSlash = 1)">
            <xsl:value-of select="'\time 9/8 '"/>
          </xsl:when>
          <xsl:when test="($mensurDot = 'true')">
            <xsl:value-of select="'\time 9/4 '"/>
          </xsl:when>
          <xsl:when test="($mensurSlash = 1)">
            <xsl:value-of select="'\time 3/4 '"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'\time 3/2 '"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI meter signature -->
  <xsl:template match="mei:meterSig[@copyof]">
    <xsl:apply-templates select="ancestor::mei:mdiv[1]//mei:meterSig[@xml:id = substring-after(current()/@copyof,'#')]"/>
  </xsl:template>
  <xsl:template name="meterSig" match="mei:meterSig">
    <xsl:param name="meterSymbol" select="@sym"/>
    <xsl:param name="meterCount" select="@count"/>
    <xsl:param name="meterUnit" select="@unit"/>
    <xsl:param name="meterRend" select="@form"/>
    <xsl:if test="@fontfam">
      <xsl:text>\once \override Staff.TimeSignature.font-family = #&apos;</xsl:text>
      <xsl:value-of select="concat(@fontfam,' ')"/>
    </xsl:if>
    <xsl:if test="@fontname">
      <xsl:value-of select="concat('\once \override Staff.TimeSignature.font-name = #&quot;',@fontname,'&quot; ')"/>
    </xsl:if>
    <xsl:if test="@fontstyle">
      <xsl:text>\once \override Staff.TimeSignature.font-shape = #&apos;</xsl:text>
      <xsl:value-of select="concat(@fontstyle,' ')"/>
    </xsl:if>
    <xsl:if test="@fontweight">
      <xsl:text>\once \override Staff.TimeSignature.font-series = #&apos;</xsl:text>
      <xsl:value-of select="concat(@fontweight,' ')"/>
    </xsl:if>
    <xsl:if test="$meterRend">
      <xsl:choose>
        <xsl:when test="$meterRend = 'num'">
          <xsl:text>\once \override Staff.TimeSignature.style = #'single-digit </xsl:text>
        </xsl:when>
        <xsl:when test="$meterRend = 'denomsym'">
        </xsl:when>
        <xsl:when test="$meterRend = 'norm'">
        </xsl:when>
        <xsl:when test="$meterRend = 'invis'">
          <xsl:text>\once \override Staff.TimeSignature.transparent = ##t </xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$meterSymbol">
        <xsl:choose>
          <xsl:when test="$meterSymbol = 'common'">
            <xsl:value-of select="'\time 4/4 '"/>
          </xsl:when>
          <xsl:when test="$meterSymbol = 'cut'">
            <xsl:value-of select="'\time 2/2 '"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains($meterCount,'+')">
        <xsl:text>\compoundMeter #'</xsl:text>
        <xsl:value-of select="concat('(',translate($meterCount,'+',' '),' ',$meterUnit,') ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="($meterCount = $meterUnit) and not($meterSymbol)">
          <xsl:text>\once \numericTimeSignature </xsl:text>
        </xsl:if>
        <xsl:value-of select="concat('\time ',$meterCount,'/',$meterUnit,' ')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- MEI meter signature group -->
  <xsl:template name="meterSigGrp" match="mei:meterSigGrp">
    <xsl:choose>
      <xsl:when test="@func = 'alternating'">
      </xsl:when>
      <xsl:when test="@func = 'interchanging'">
      </xsl:when>
      <xsl:when test="@func = 'mixed'">
        <xsl:text>\compoundMeter #'(</xsl:text>
        <xsl:for-each select="mei:meterSig">
          <xsl:value-of select="concat('(',translate(@count,'+',' '),' ',@unit,')')"/>
          <xsl:if test="following-sibling::mei:meterSig">
            <xsl:text>&#32;</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>)&#32;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- MEI system break -->
  <xsl:template match="mei:sb">
    <xsl:text>&#32;&#32;</xsl:text>
    <xsl:call-template name="tag"/>
    <xsl:text>{ \break }</xsl:text>
    <xsl:if test="@n">
      <xsl:value-of select="concat(' %',@n)"/>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <!-- MEI page break -->
  <xsl:template match="mei:pb">
    <xsl:text>&#32;&#32;</xsl:text>
    <xsl:call-template name="tag"/>
    <xsl:text>{ \pageBreak }</xsl:text>
    <xsl:if test="@n">
      <xsl:value-of select="concat(' %',@n)"/>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <!-- MEI verse -->
  <xsl:template match="mei:verse">
    <xsl:if test="@color">
      <xsl:value-of select="'\once \override Lyrics.LyricText.color = #'"/>
      <xsl:call-template name="setColor"/>
    </xsl:if>
    <xsl:if test="@fontstyle">
      <xsl:text>\once \override Lyrics.LyricText.font-shape = #&apos;</xsl:text>
      <xsl:value-of select="concat(@fontstyle,' ')"/>
    </xsl:if>
    <xsl:if test="@fontweight">
      <xsl:text>\once \override Lyrics.LyricText.font-series = #&apos;</xsl:text>
      <xsl:value-of select="concat(@fontweight,' ')"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI syllable -->
  <xsl:template match="mei:syl">
    <xsl:if test="contains(text(),' ')">
      <xsl:text>&quot;</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="contains(text(),' ')">
      <xsl:text>&quot;</xsl:text>
    </xsl:if>
    <xsl:if test="not(text())">
      <xsl:text>_</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@con='s'">
        <xsl:value-of select="'_'"/>
      </xsl:when>
      <xsl:when test="@con='c'">
        <xsl:value-of select="'^'"/>
      </xsl:when>
      <xsl:when test="@con='v'">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:when test="@con='i'">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:when test="@con='b'">
        <xsl:value-of select="'~'"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- MEI.edittrans -->
  <!-- MEI abbreviation -->
  <xsl:template match="mei:abbr">
    <xsl:call-template name="tag"/>
    <xsl:text>{&#32;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI apparatus -->
  <xsl:template match="mei:app">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI choose -->
  <xsl:template match="mei:choice">
    <xsl:apply-templates select="mei:reg"/>
  </xsl:template>
  <!-- MEI correction -->
  <xsl:template match="mei:corr">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI expansion -->
  <xsl:template match="mei:expan">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI lemma -->
  <xsl:template match="mei:lem">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI reading -->
  <xsl:template match="mei:rdg">
    <xsl:call-template name="tag"/>
    <xsl:call-template name="tag">
      <xsl:with-param name="tagList" select="@resp"/>
    </xsl:call-template>
    <xsl:text>{&#32;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI original -->
  <xsl:template match="mei:orig">
    <xsl:call-template name="tag"/>
    <xsl:text>{&#32;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#32;</xsl:text>
  </xsl:template>
  <!-- MEI regularization -->
  <xsl:template match="mei:reg">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- excluded elements -->
  <xsl:template match="mei:back"/>
  <xsl:template match="mei:encodingDesc"/>
  <xsl:template match="mei:expansion"/>
  <xsl:template match="mei:extMeta"/>
  <xsl:template match="mei:front"/>
  <xsl:template match="mei:incip"/>
  <xsl:template match="mei:midi"/>
  <xsl:template match="mei:orig"/>
  <xsl:template match="mei:part"/>
  <xsl:template match="mei:pgHead"/>
  <xsl:template match="mei:pgFoot"/>
  <xsl:template match="mei:sourceDesc"/>
  <xsl:template match="mei:symbol"/>
  <xsl:template match="mei:vel"/>
  <!-- helper templates -->
  <!-- tag contents-->
  <xsl:template name="tag">
    <xsl:param name="tagList" select="@source"/>
    <xsl:choose>
      <xsl:when test="contains($tagList,' ')">
        <xsl:text>\tag #'</xsl:text>
        <xsl:value-of select="concat(substring-after(substring-before($tagList,' '),'#'),' ')"/>
        <xsl:call-template name="tag">
          <xsl:with-param name="tagList" select="substring-after($tagList,' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="string($tagList)">
        <xsl:text>\tag #'</xsl:text>
        <xsl:value-of select="concat(substring-after($tagList,'#'),' ')"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  <!-- set octave -->
  <xsl:template name="setOctave">
    <xsl:param name="oct" select="@oct - 3"/>
    <xsl:choose>
      <xsl:when test="$oct &lt; 0">
        <xsl:text>,</xsl:text>
        <xsl:call-template name="setOctave">
          <xsl:with-param name="oct" select="$oct + 1"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$oct &gt; 0">
        <xsl:text>'</xsl:text>
        <xsl:call-template name="setOctave">
          <xsl:with-param name="oct" select="$oct - 1"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- set stem direction -->
  <xsl:template name="setStemDir">
    <xsl:variable name="staffPos" select="ancestor::mei:staff/@n"/>
    <xsl:variable name="measurePos" select="ancestor::mei:measure/@n"/>
    <xsl:variable name="layerPos" select="ancestor::mei:layer/@n"/>
    <xsl:if test="not(preceding::*[@stem.dir][1][ancestor::mei:music][ancestor::mei:layer/@n = $layerPos][ancestor::mei:staff/@n = $staffPos][ancestor::mei:measure/@n = $measurePos]) or (@stem.dir != preceding::*[@stem.dir][ancestor::mei:music][ancestor::mei:layer/@n = $layerPos][ancestor::mei:staff/@n = $staffPos][ancestor::mei:measure/@n = $measurePos][1]/@stem.dir)" >
      <xsl:choose>
        <xsl:when test="@stem.dir='up'">
          <xsl:text>\stemUp </xsl:text>
        </xsl:when>
        <xsl:when test="@stem.dir='down'">
          <xsl:text>\stemDown </xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="not(parent::mei:chord) and not(@stem.dir) and (preceding::mei:chord[1][@stem.dir] or preceding::mei:note[1][not(parent::mei:chord)][@stem.dir])" >
      <xsl:text>\stemNeutral </xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- set duration -->
  <xsl:template name="setDuration">
    <xsl:choose>
      <!-- data.DURATION.cmn -->
      <xsl:when test="@dur='long'">
        <xsl:text>\longa</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='breve'">
        <xsl:text>\breve</xsl:text>
      </xsl:when>
      <xsl:when test="number(@dur)">
        <xsl:value-of select="number(@dur)"/>
      </xsl:when>
      <!-- data.DURATION.mensural -->
      <xsl:when test="@dur='maxima'">
        <xsl:text>\maxima</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='longa'">
        <xsl:text>\longa</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='brevis'">
        <xsl:text>\breve</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='semibrevis'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='minima'">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='semiminima'">
        <xsl:text>4</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='fusa'">
        <xsl:text>8</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='semifusa'">
        <xsl:text>16</xsl:text>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="setDots"/>
    <xsl:if test="@num and @numbase">
      <xsl:value-of select="concat('*',@num,'/',@numbase)"/>
    </xsl:if>
  </xsl:template>
  <!-- set dots -->
  <xsl:template name="setDots">
    <xsl:param name="dots" select="@dots"/>
    <xsl:if test="$dots &gt; 0">
      <xsl:text>.</xsl:text>
      <xsl:call-template name="setDots">
        <xsl:with-param name="dots" select="$dots - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <!-- set accidental -->
  <xsl:template name="setAccidental">
    <xsl:param name="accidental" />
    <xsl:if test="$accidental = 's'">
      <xsl:text>is</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'f'">
      <xsl:text>es</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'ss'">
      <xsl:text>isis</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'x'">
      <xsl:text>isis</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'ff'">
      <xsl:text>eses</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'su'">
      <xsl:text>isih</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'sd'">
      <xsl:text>ih</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'fu'">
      <xsl:text>eh</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = 'fd'">
      <xsl:text>eseh</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = '1qf'">
      <xsl:text>eh</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = '3qf'">
      <xsl:text>eseh</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = '1qs'">
      <xsl:text>ih</xsl:text>
    </xsl:if>
    <xsl:if test="$accidental = '3qs'">
      <xsl:text>isih</xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- set grace notes -->
  <xsl:template name="setGraceNote">
    <xsl:if test="@stem.mod = '1slash'">
      <xsl:text>\once \override Flag.stroke-style = #"grace" </xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@grace = 'acc'">
        <xsl:text>\appoggiatura </xsl:text>
      </xsl:when>
      <xsl:when test="@grace = 'unacc'">
        <xsl:text>\acciaccatura </xsl:text>
      </xsl:when>
      <xsl:when test="@grace = 'unknown'">
        <xsl:text>\grace </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- set articulation -->
  <xsl:template name="setArticulation">
    <xsl:param name="articulation"/>
    <xsl:choose>
      <!-- ly:Articulation scripts -->
      <xsl:when test="$articulation = 'acc'">
        <xsl:text>\accent</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'stacc'">
        <xsl:text>\staccato</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'ten'">
        <xsl:text>\tenuto</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'stacciss'">
        <xsl:text>\staccatissimo</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'marc'">
        <xsl:text>\marcato</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'marc-stacc'">
        <xsl:text>\marcato</xsl:text>
        <xsl:call-template name="artic">
          <xsl:with-param name="articList" select="'stacc'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$articulation = 'spiccato'">
        <xsl:text>\staccato</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'ten-stacc'">
        <xsl:text>\portato</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'dot'">
        <xsl:text>\staccato</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'stroke'">
        <xsl:text>\staccatissimo</xsl:text>
      </xsl:when>
      <!-- ly:Instrument-specific scripts -->
      <xsl:when test="$articulation = 'dnbow'">
        <xsl:text>\downbow</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'upbow'">
        <xsl:text>\upbow</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'harm'">
        <xsl:text>\flageolet</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'snap'">
        <xsl:text>\snappizzicato</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'open'">
        <xsl:text>\open</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'stop'">
        <xsl:text>\stopped</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'heel'">
        <xsl:text>\lheel</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'toe'">
        <xsl:text>\rtoe</xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'lhpizz'">
        <xsl:text>\stopped</xsl:text>
      </xsl:when>
      <!-- replace missing scripts -->
      <xsl:when test="$articulation = 'doit'">
        <xsl:text>\bendAfter #2 </xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'fall'">
        <xsl:text>\bendAfter #-2 </xsl:text>
      </xsl:when>
      <xsl:when test="$articulation = 'longfall'">
        <xsl:text>\bendAfter #-4 </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- unsupported values 'scoop' 'rip' 'plop' 'bend' 'flip' 'smear' 'shake' 'fingernail' 'damp' 'dampall' 'dbltongue' 'trpltongue' 'tap' -->
        <xsl:text>\stopped</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- set ornaments -->
  <xsl:template name="setOrnament">
    <!-- ly:Ornament scripts -->
    <xsl:if test="contains(@ornam,'M')">
      <xsl:text>\prall</xsl:text>
    </xsl:if>
    <xsl:if test="contains(@ornam,'m')">
      <xsl:text>\mordent</xsl:text>
    </xsl:if>
    <xsl:if test="contains(@ornam,'S')">
      <xsl:text>\turn</xsl:text>
    </xsl:if>
    <xsl:if test="contains(@ornam,'s')">
      <xsl:text>\reverseturn</xsl:text>
    </xsl:if>
    <xsl:if test="contains(@ornam,'T')">
      <xsl:text>\trill</xsl:text>
    </xsl:if>
    <xsl:if test="contains(@ornam,'t')">
      <xsl:text>\trill</xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- set instrument names -->
  <xsl:template name="setInstrumentName">
    <xsl:if test="@label">
      <xsl:value-of select="concat('instrumentName = #&quot;',@label,'&quot; ')"/>
    </xsl:if>
    <xsl:if test="@label.abbr">
      <xsl:value-of select="concat('shortInstrumentName = #&quot;',@label.abbr,'&quot; ')"/>
    </xsl:if>
    <xsl:if test="child::mei:label">
      <xsl:value-of select="'instrumentName = '"/>
      <xsl:apply-templates select="mei:label"/>
    </xsl:if>
  </xsl:template>
  <!-- set key -->
  <xsl:template name="transformKey">
    <xsl:param name="accidentals"/>
    <xsl:text>\key </xsl:text>
    <xsl:choose>
      <xsl:when test="$accidentals='1s'">
        <xsl:text>g \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='2s'">
        <xsl:text>d \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='3s'">
        <xsl:text>a \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='4s'">
        <xsl:text>e \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='5s'">
        <xsl:text>b \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='6s'">
        <xsl:text>fis \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='7s'">
        <xsl:text>cis \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='8s'">
        <xsl:text>gis \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='1f'">
        <xsl:text>f \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='2f'">
        <xsl:text>bes \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='3f'">
        <xsl:text>ees \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='4f'">
        <xsl:text>aes \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='5f'">
        <xsl:text>des \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='6f'">
        <xsl:text>ges \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='7f'">
        <xsl:text>ces \major</xsl:text>
      </xsl:when>
      <xsl:when test="$accidentals='8f'">
        <xsl:text>fes \major</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>c \major</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <!-- set staff group style -->
  <xsl:template name="setStaffGrpStyle">
    <xsl:text>  \set StaffGroup.systemStartDelimiter = </xsl:text>
    <xsl:choose>
      <xsl:when test="@symbol='brace'">
        <xsl:text>#'SystemStartBrace</xsl:text>
      </xsl:when>
      <xsl:when test="@symbol='bracket'">
        <xsl:text>#'SystemStartBracket</xsl:text>
      </xsl:when>
      <xsl:when test="@symbol='bracketsq'">
        <xsl:text>#'SystemStartSquare</xsl:text>
      </xsl:when>
      <xsl:when test="@symbol='line'">
        <xsl:text>#'SystemStartBar</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>#'SystemStartBar</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="@barthru">
      <xsl:value-of select="concat('  \override StaffGroup.BarLine.allow-span-bar = ##',substring(@barthru,1,1),'&#10;')"/>
    </xsl:if>
  </xsl:template>
  <!-- set bar lines -->
  <xsl:template name="setBarLine">
    <xsl:param name="barLineStyle" />
    <xsl:text>\bar "</xsl:text>
    <xsl:choose>
      <xsl:when test="$barLineStyle='dashed'">
        <xsl:text>!</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='dotted'">
        <xsl:text>;</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='dbl'">
        <xsl:text>||</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='dbldashed'">
        <xsl:text>!!</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='dbldotted'">
        <xsl:text>;;</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='end'">
        <xsl:text>|.</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='invis'">
      </xsl:when>
      <xsl:when test="$barLineStyle='rptstart'">
        <xsl:text>.|:</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='rptboth'">
        <xsl:text>:..:</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='rptend'">
        <xsl:text>:|.</xsl:text>
      </xsl:when>
      <xsl:when test="$barLineStyle='single'">
        <xsl:text>|</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>|</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>" </xsl:text>
  </xsl:template>
  <!-- set simple markup diections -->
  <xsl:template name="setMarkupDirection">
    <xsl:param name="direction" select="@place"/>
    <xsl:choose>
      <xsl:when test="$direction='above'">
        <xsl:text>^</xsl:text>
      </xsl:when>
      <xsl:when test="$direction='below'">
        <xsl:text>_</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>-</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- set diections -->
  <xsl:template name="setDirection">
    <xsl:param name="direction" select="@place"/>
    <!-- data.STAFFREL -->
    <xsl:choose>
      <xsl:when test="$direction = 'above'">
        <xsl:value-of select="1"/>
      </xsl:when>
      <xsl:when test="$direction = 'below'">
        <xsl:value-of select="-1"/>
      </xsl:when>
      <xsl:when test="$direction = 'within'">
        <xsl:value-of select="0"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <!-- set offset -->
  <xsl:template name="setOffset">
    <xsl:choose>
      <xsl:when test="@ho">
        <xsl:value-of select="concat('(',@ho div 2)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'(0'"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="' . '"/>
    <xsl:choose>
      <xsl:when test="@vo">
        <xsl:value-of select="concat(@vo div 2,') ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0) '"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- set offset -->
  <xsl:template name="setOffset2">
    <xsl:choose>
      <xsl:when test="@startvo">
        <xsl:value-of select="concat('(',@startvo div 2)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'(0'"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="' . '"/>
    <xsl:choose>
      <xsl:when test="@endvo">
        <xsl:value-of select="concat(@endvo div 2,') ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0) '"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- shape curve -->
  <xsl:template name="shapeCurve">
    <xsl:param name="a" select="0"/>
    <xsl:param name="b" select="0"/>
    <xsl:param name="c" select="0"/>
    <xsl:param name="d" select="0"/>
    <xsl:choose>
      <xsl:when test="@startvo">
        <xsl:value-of select="concat('(',@startvo div 2)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'(0'"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="' . '"/>
    <xsl:choose>
      <xsl:when test="@endvo">
        <xsl:value-of select="concat(@endvo div 2,') ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0) '"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- set color -->
  <xsl:template name="setColor">
    <xsl:param name="color" select="@color"/>
    <xsl:choose>
      <xsl:when test="starts-with($color,'rgb')">
        <xsl:variable name="redValue" select="substring-before(substring-after($color,'('),',')"/>
        <xsl:variable name="greenValue" select="substring-before(substring-after($color,','),',')"/>
        <xsl:variable name="blueValue" select="substring-after(substring-after(substring-before($color,')'),','),',')"/>
        <xsl:value-of select="concat('(rgb-color ',number($redValue) div 255,' ',number($greenValue) div 255,' ',number($blueValue) div 255,') ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('(x11-color &quot;',$color,'&quot;) ')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- set line width -->
  <xsl:template name="setLineWidth">
    <xsl:param name="thickness" select="@lwidth"/>
    <xsl:param name="default">
      <xsl:choose>
        <xsl:when test="self::mei:phrase or self::mei:slur or self::mei:tie or self::mei:staffDef">
          <xsl:value-of select="1.2"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="1.0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <!-- data.LINEWIDTHTERM -->
    <xsl:choose>
      <xsl:when test="$thickness = 'medium'">
        <xsl:value-of select="2 * $default"/>
      </xsl:when>
      <xsl:when test="$thickness = 'wide'">
        <xsl:value-of select="4 * $default"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <!-- set beaming -->
  <xsl:template name="setTransposition">
    <xsl:text>\transposition </xsl:text>
    <!-- att.transposition -->
    <xsl:choose>
      <xsl:when test="contains(',-21,-14,-7,0,7,14,21,',concat(',',@trans.diat,','))">
        <xsl:text>c</xsl:text>
        <xsl:choose>
          <xsl:when test="contains(',-25,-13,-1,11,23,',concat(',',@trans.semi,','))">
            <xsl:text>es</xsl:text>
          </xsl:when>
          <xsl:when test="contains(',-23,-11,1,13,25,',concat(',',@trans.semi,','))">
            <xsl:text>is</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(',-20,-13,-6,1,8,15,22,',concat(',',@trans.diat,','))">
        <xsl:text>d</xsl:text>
        <xsl:choose>
          <xsl:when test="contains(',-23,-11,1,13,25,',concat(',',@trans.semi,','))">
            <xsl:text>es</xsl:text>
          </xsl:when>
          <xsl:when test="contains(',-21,-9,3,15,27,',concat(',',@trans.semi,','))">
            <xsl:text>is</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(',-19,-12,-5,2,9,16,23,',concat(',',@trans.diat,','))">
        <xsl:text>e</xsl:text>
        <xsl:choose>
          <xsl:when test="contains(',-21,-9,3,15,27,',concat(',',@trans.semi,','))">
            <xsl:text>es</xsl:text>
          </xsl:when>
          <xsl:when test="contains(',-19,-7,5,17,29,',concat(',',@trans.semi,','))">
            <xsl:text>is</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(',-18,-11,-4,3,10,17,24,',concat(',',@trans.diat,','))">
        <xsl:text>f</xsl:text>
        <xsl:choose>
          <xsl:when test="contains(',-20,-8,4,16,28,',concat(',',@trans.semi,','))">
            <xsl:text>es</xsl:text>
          </xsl:when>
          <xsl:when test="contains(',-18,-6,6,18,30,',concat(',',@trans.semi,','))">
            <xsl:text>is</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(',-17,-10,-3,4,11,18,25,',concat(',',@trans.diat,','))">
        <xsl:text>g</xsl:text>
        <xsl:choose>
          <xsl:when test="contains(',-18,-6,6,18,30,',concat(',',@trans.semi,','))">
            <xsl:text>es</xsl:text>
          </xsl:when>
          <xsl:when test="contains(',-16,-4,8,20,32,',concat(',',@trans.semi,','))">
            <xsl:text>is</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(',-16,-9,-2,12,19,26,',concat(',',@trans.diat,','))">
        <xsl:text>a</xsl:text>
        <xsl:choose>
          <xsl:when test="contains(',-16,-4,8,20,32,',concat(',',@trans.semi,','))">
            <xsl:text>es</xsl:text>
          </xsl:when>
          <xsl:when test="contains(',-14,-2,10,22,34,',concat(',',@trans.semi,','))">
            <xsl:text>is</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="contains(',-15,-8,-1,5,13,20,27,',concat(',',@trans.diat,','))">
        <xsl:text>b</xsl:text>
        <xsl:choose>
          <xsl:when test="contains(',-14,-2,10,22,34,',concat(',',@trans.semi,','))">
            <xsl:text>es</xsl:text>
          </xsl:when>
          <xsl:when test="contains(',-24,-12,0,12,24,',concat(',',@trans.semi,','))">
            <xsl:text>is</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>c'</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="setOctave">
      <xsl:with-param name="oct" select="floor(@trans.diat div 8) + 1"/>
    </xsl:call-template>
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <!-- set beaming -->
  <xsl:template name="setBeaming">
    <xsl:text>\set Timing.beamExceptions = #'() </xsl:text>
    <xsl:value-of select="concat('% ',ancestor-or-self::*/@beam.group)"/>
    <xsl:text>&#10;&#32;&#32;&#32;&#32;</xsl:text>
  </xsl:template>
  <!-- set bar number -->
  <xsl:template name="setBarNumber">
    <xsl:value-of select="concat('\set Score.currentBarNumber = #',ancestor-or-self::mei:measure/@n)"/>
    <xsl:text>&#10;&#32;&#32;</xsl:text>
  </xsl:template>
  <!-- set bar number -->
  <xsl:template name="setNotationtype">
    <!-- data.NOTATIONTYPE -->
    <xsl:choose>
      <xsl:when test="@notationtype = 'cmn'">
      </xsl:when>
      <xsl:when test="@notationtype = 'mensural'">
        <xsl:text>Mensural</xsl:text>
      </xsl:when>
      <xsl:when test="@notationtype = 'mensural.black'">
        <xsl:text>Mensural</xsl:text>
      </xsl:when>
      <xsl:when test="@notationtype = 'mensural.white'">
        <xsl:text>Mensural</xsl:text>
      </xsl:when>
      <xsl:when test="@notationtype = 'neume'">
        <xsl:text>Vaticana</xsl:text>
      </xsl:when>
      <xsl:when test="@notationtype = 'tab'">
        <xsl:text>Tab</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- set horizontal alignment -->
  <xsl:template name="setHalign">
    <!-- data.HORIZONTALALIGNMENT -->
    <xsl:value-of select="concat('\',@halign)"/>
    <xsl:if test="@halign != 'justify'">
      <xsl:value-of select="'-align'"/>
    </xsl:if>
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <!-- set relative fontsize -->
  <xsl:template name="setRelFontsize">
    <!-- data.FONTSIZETERM -->
    <xsl:choose>
      <xsl:when test="@fontsize ='xx-small'">
        <xsl:value-of select="'\teeny '"/>
      </xsl:when>
      <xsl:when test="@fontsize ='x-small'">
        <xsl:value-of select="'\tiny '"/>
      </xsl:when>
      <xsl:when test="@fontsize ='small'">
        <xsl:value-of select="'\small '"/>
      </xsl:when>
      <xsl:when test="@fontsize ='medium'">
        <xsl:value-of select="'\normalsize '"/>
      </xsl:when>
      <xsl:when test="@fontsize ='large'">
        <xsl:value-of select="'\large '"/>
      </xsl:when>
      <xsl:when test="@fontsize ='x-large'">
        <xsl:value-of select="'\huge '"/>
      </xsl:when>
      <xsl:when test="@fontsize ='xx-large'">
        <xsl:value-of select="'\huge '"/>
      </xsl:when>
      <xsl:when test="@fontsize ='smaller'">
        <xsl:value-of select="'\smaller '"/>
      </xsl:when>
      <xsl:when test="@fontsize ='larger'">
        <xsl:value-of select="'\larger '"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  <!-- set relative fontsize -->
  <xsl:template name="setLineForm">
    <xsl:param name="form" select="@lform"/>
    <!-- data.LINEFORM -->
    <xsl:choose>
      <xsl:when test="$form = 'dashed'">
        <xsl:value-of select="'dashed-line'"/>
      </xsl:when>
      <xsl:when test="$form = 'dotted'">
        <xsl:value-of select="'dotted-line'"/>
      </xsl:when>
      <xsl:when test="$form = 'solid'">
        <xsl:value-of select="'solid-line'"/>
      </xsl:when>
      <xsl:when test="$form = 'wavy'">
        <xsl:value-of select="'trill'"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:text>&#32;</xsl:text>
  </xsl:template>
  <!-- modify note head -->
  <xsl:template name="modifyNotehead">
    <!-- data.NOTEHEADMODIFIER -->
    <xsl:choose>
      <xsl:when test="@head.mod ='slash'">
      </xsl:when>
      <xsl:when test="@head.mod ='backslash'">
      </xsl:when>
      <xsl:when test="@head.mod ='vline'">
      </xsl:when>
      <xsl:when test="@head.mod ='hline'">
      </xsl:when>
      <xsl:when test="@head.mod ='centerdot'">
      </xsl:when>
      <xsl:when test="@head.mod ='paren'">
        <xsl:value-of select="'\parenthesize '"/>
      </xsl:when>
      <xsl:when test="@head.mod ='brack'">
      </xsl:when>
      <xsl:when test="@head.mod ='box'">
        <xsl:text>\once \override NoteHead.stencil = #(lambda (grob) (let* ((note (ly:note-head::print grob)) (combo-stencil (ly:stencil-add note (box-stencil note 0 0.5)))) (ly:make-stencil (ly:stencil-expr combo-stencil) (ly:stencil-extent note X) (ly:stencil-extent note Y))))</xsl:text>
      </xsl:when>
      <xsl:when test="@head.mod ='circle'">
        <xsl:text>\once \override NoteHead.stencil = #(lambda (grob) (let* ((note (ly:note-head::print grob)) (combo-stencil (ly:stencil-add note (circle-stencil note 0 0.5)))) (ly:make-stencil (ly:stencil-expr combo-stencil) (ly:stencil-extent note X) (ly:stencil-extent note Y))))</xsl:text>
      </xsl:when>
      <xsl:when test="@head.mod ='dblwhole'">
      </xsl:when>
      <xsl:when test="contains('ABCDEFG',@head.mod)">
        <xsl:text>\once \easyHeadsOn </xsl:text>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- set midi instrument -->
  <xsl:template name="setMidiInstruments">
    <xsl:choose>
      <xsl:when test="parent::mei:staffDef">
        <xsl:value-of select="'\set Staff.midiInstrument = #&quot;'"/>
      </xsl:when>
      <xsl:when test="parent::mei:staffGrp">
        <xsl:value-of select="'  \set StaffGroup.midiInstrument = #&quot;'"/>
      </xsl:when>
    </xsl:choose>
    <!-- data.MIDINAMES -->
    <xsl:choose>
      <!-- Piano -->
      <xsl:when test="@midi.instrname = 'Acoustic_Grand_Piano' or @midi.instrnum = '0'">
        <xsl:text>acoustic grand</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Bright_Acoustic_Piano' or @midi.instrnum = '1'">
        <xsl:text>bright acoustic</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Grand_Piano' or @midi.instrnum = '2'">
        <xsl:text>electric grand</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Honky-tonk_Piano' or @midi.instrnum = '3'">
        <xsl:text>honky-tonk</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Piano_1' or @midi.instrnum = '4'">
        <xsl:text>electric piano 1</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Piano_2' or @midi.instrnum = '5'">
        <xsl:text>electric piano 2</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Harpsichord' or @midi.instrnum = '6'">
        <xsl:text>harpsichord</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Clavi' or @midi.instrnum = '7'">
        <xsl:text>clav</xsl:text>
      </xsl:when>
      <!-- Chromatic Percussion -->
      <xsl:when test="@midi.instrname = 'Celesta' or @midi.instrnum = '8'">
        <xsl:text>celesta</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Glockenspiel' or @midi.instrnum = '9'">
        <xsl:text>glockenspiel</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Music_Box' or @midi.instrnum = '10'">
        <xsl:text>music box</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Vibraphone' or @midi.instrnum = '11'">
        <xsl:text>vibraphone</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Marimba' or @midi.instrnum = '12'">
        <xsl:text>marimba</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Xylophone' or @midi.instrnum = '13'">
        <xsl:text>xylophone</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Tubular_Bells' or @midi.instrnum = '14'">
        <xsl:text>tubular bells</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Dulcimer' or @midi.instrnum = '15'">
        <xsl:text>dulcimer</xsl:text>
      </xsl:when>
      <!-- Organ -->
      <xsl:when test="@midi.instrname = 'Drawbar_Organ' or @midi.instrnum = '16'">
        <xsl:text>drawbar organ</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Percussive_Organ' or @midi.instrnum = '17'">
        <xsl:text>percussive organ</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Rock_Organ' or @midi.instrnum = '18'">
        <xsl:text>rock organ</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Church_Organ' or @midi.instrnum = '19'">
        <xsl:text>church organ</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Reed_Organ' or @midi.instrnum = '20'">
        <xsl:text>reed organ</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Accordion' or @midi.instrnum = '21'">
        <xsl:text>accordion</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Harmonica' or @midi.instrnum = '22'">
        <xsl:text>harmonica</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Tango_Accordion' or @midi.instrnum = '23'">
        <xsl:text>concertina</xsl:text>
      </xsl:when>
      <!-- Guitar -->
      <xsl:when test="@midi.instrname = 'Acoustic_Guitar_nylon' or @midi.instrnum = '24'">
        <xsl:text>acoustic guitar (nylon)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Acoustic_Guitar_steel' or @midi.instrnum = '25'">
        <xsl:text>acoustic guitar (steel)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Guitar_jazz' or @midi.instrnum = '26'">
        <xsl:text>electric guitar (jazz)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Guitar_clean' or @midi.instrnum = '27'">
        <xsl:text>electric guitar (clean)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Guitar_muted' or @midi.instrnum = '28'">
        <xsl:text>electric guitar (muted)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Overdriven_Guitar' or @midi.instrnum = '29'">
        <xsl:text>overdriven guitar</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Distortion_Guitar' or @midi.instrnum = '30'">
        <xsl:text>distorted guitar</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Guitar_harmonics' or @midi.instrnum = '31'">
        <xsl:text>guitar harmonics</xsl:text>
      </xsl:when>
      <!-- Bass -->
      <xsl:when test="@midi.instrname = 'Acoustic_Bass' or @midi.instrnum = '32'">
        <xsl:text>acoustic bass</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Bass_finger' or @midi.instrnum = '33'">
        <xsl:text>electric bass (finger)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Bass_pick' or @midi.instrnum = '34'">
        <xsl:text>electric bass (pick)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Fretless_Bass' or @midi.instrnum = '35'">
        <xsl:text>fretless bass</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Slap_Bass_1' or @midi.instrnum = '36'">
        <xsl:text>slap bass 1</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Slap_Bass_2' or @midi.instrnum = '37'">
        <xsl:text>slap bass 2</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Synth_Bass_1' or @midi.instrnum = '38'">
        <xsl:text>synth bass 1</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Synth_Bass_2' or @midi.instrnum = '39'">
        <xsl:text>synth bass 2</xsl:text>
      </xsl:when>
      <!-- Strings -->
      <xsl:when test="@midi.instrname = 'Violin' or @midi.instrnum = '40'">
        <xsl:text>violin</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Viola' or @midi.instrnum = '41'">
        <xsl:text>viola</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Cello' or @midi.instrnum = '42'">
        <xsl:text>cello</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Contrabass' or @midi.instrnum = '43'">
        <xsl:text>contrabass</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Tremolo_Strings' or @midi.instrnum = '44'">
        <xsl:text>tremolo strings</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pizzicato_Strings' or @midi.instrnum = '45'">
        <xsl:text>pizzicato strings</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Orchestral_Harp' or @midi.instrnum = '46'">
        <xsl:text>orchestral harp</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Timpani' or @midi.instrnum = '47'">
        <xsl:text>timpani</xsl:text>
      </xsl:when>
      <!-- Ensemble -->
      <xsl:when test="@midi.instrname = 'String_Ensemble_1' or @midi.instrnum = '48'">
        <xsl:text>string ensemble 1</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'String_Ensemble_2' or @midi.instrnum = '49'">
        <xsl:text>string ensemble 2</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'SynthStrings_1' or @midi.instrnum = '50'">
        <xsl:text>synthstrings 1</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'SynthStrings_2' or @midi.instrnum = '51'">
        <xsl:text>synthstrings 2</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Choir_Aahs' or @midi.instrnum = '52'">
        <xsl:text>choir aahs</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Voice_Oohs' or @midi.instrnum = '53'">
        <xsl:text>voice oohs</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Synth_Voice' or @midi.instrnum = '54'">
        <xsl:text>synth voice</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Orchestra_Hit' or @midi.instrnum = '55'">
        <xsl:text>orchestra hit</xsl:text>
      </xsl:when>
      <!-- Brass -->
      <xsl:when test="@midi.instrname = 'Trumpet' or @midi.instrnum = '56'">
        <xsl:text>trumpet</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Trombone' or @midi.instrnum = '57'">
        <xsl:text>trombone</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Tuba' or @midi.instrnum = '58'">
        <xsl:text>tuba</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Muted_Trumpet' or @midi.instrnum = '59'">
        <xsl:text>muted trumpet</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'French_Horn' or @midi.instrnum = '60'">
        <xsl:text>french horn</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Brass_Section' or @midi.instrnum = '61'">
        <xsl:text>brass section</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'SynthBrass_1' or @midi.instrnum = '62'">
        <xsl:text>synthbrass 1</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'SynthBrass_2' or @midi.instrnum = '63'">
        <xsl:text>synthbrass 2</xsl:text>
      </xsl:when>
      <!-- Reed -->
      <xsl:when test="@midi.instrname = 'Soprano_Sax' or @midi.instrnum = '64'">
        <xsl:text>soprano sax</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Alto_Sax' or @midi.instrnum = '65'">
        <xsl:text>alto sax</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Tenor_Sax' or @midi.instrnum = '66'">
        <xsl:text>tenor sax</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Baritone_Sax' or @midi.instrnum = '67'">
        <xsl:text>baritone sax</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Oboe' or @midi.instrnum = '68'">
        <xsl:text>oboe</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'English_Horn' or @midi.instrnum = '69'">
        <xsl:text>english horn</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Bassoon' or @midi.instrnum = '70'">
        <xsl:text>bassoon</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Clarinet' or @midi.instrnum = '71'">
        <xsl:text>clarinet</xsl:text>
      </xsl:when>
      <!-- Pipe -->
      <xsl:when test="@midi.instrname = 'Piccolo' or @midi.instrnum = '72'">
        <xsl:text>piccolo</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Flute' or @midi.instrnum = '73'">
        <xsl:text>flute</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Recorder' or @midi.instrnum = '74'">
        <xsl:text>recorder</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pan_Flute' or @midi.instrnum = '75'">
        <xsl:text>pan flute</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Blown_Bottle' or @midi.instrnum = '76'">
        <xsl:text>blown bottle</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Shakuhachi' or @midi.instrnum = '77'">
        <xsl:text>shakuhachi</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Whistle' or @midi.instrnum = '78'">
        <xsl:text>whistle</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Ocarina' or @midi.instrnum = '79'">
        <xsl:text>ocarina</xsl:text>
      </xsl:when>
      <!-- Synth Lead -->
      <xsl:when test="@midi.instrname = 'Lead_1_square' or @midi.instrnum = '80'">
        <xsl:text>lead 1 (square)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Lead_2_sawtooth' or @midi.instrnum = '81'">
        <xsl:text>lead 2 (sawtooth)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Lead_3_calliope' or @midi.instrnum = '82'">
        <xsl:text>lead 3 (calliope)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Lead_4_chiff' or @midi.instrnum = '83'">
        <xsl:text>lead 4 (chiff)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Lead_5_charang' or @midi.instrnum = '84'">
        <xsl:text>lead 5 (charang)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Lead_6_voice' or @midi.instrnum = '85'">
        <xsl:text>lead 6 (voice)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Lead_7_fifths' or @midi.instrnum = '86'">
        <xsl:text>lead 7 (fifths)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Lead_8_bass_and_lead' or @midi.instrnum = '87'">
        <xsl:text>lead 8 (bass+lead)</xsl:text>
      </xsl:when>
      <!-- Synth Pad -->
      <xsl:when test="@midi.instrname = 'Pad_1_new_age' or @midi.instrnum = '88'">
        <xsl:text>pad 1 (new age)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pad_2_warm' or @midi.instrnum = '89'">
        <xsl:text>pad 2 (warm)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pad_3_polysynth' or @midi.instrnum = '90'">
        <xsl:text>pad 3 (polysynth)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pad_4_choir' or @midi.instrnum = '91'">
        <xsl:text>pad 4 (choir)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pad_5_bowed' or @midi.instrnum = '92'">
        <xsl:text>pad 5 (bowed)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pad_6_metallic' or @midi.instrnum = '93'">
        <xsl:text>pad 6 (metallic)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pad_7_halo' or @midi.instrnum = '94'">
        <xsl:text>pad 7 (halo)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pad_8_sweep' or @midi.instrnum = '95'">
        <xsl:text>pad 8 (sweep)</xsl:text>
      </xsl:when>
      <!-- Synth Effects -->
      <xsl:when test="@midi.instrname = 'FX_1_rain' or @midi.instrnum = '96'">
        <xsl:text>fx 1 (rain)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'FX_2_soundtrack' or @midi.instrnum = '97'">
        <xsl:text>fx 2 (soundtrack)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'FX_3_crystal' or @midi.instrnum = '98'">
        <xsl:text>fx 3 (crystal)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'FX_4_atmosphere' or @midi.instrnum = '99'">
        <xsl:text>fx 4 (atmosphere)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'FX_5_brightness' or @midi.instrnum = '100'">
        <xsl:text>fx 5 (brightness)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'FX_6_goblins' or @midi.instrnum = '101'">
        <xsl:text>fx 6 (goblins)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'FX_7_echoes' or @midi.instrnum = '102'">
        <xsl:text>fx 7 (echoes)</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'FX_8_sci-fi' or @midi.instrnum = '103'">
        <xsl:text>fx 8 (sci-fi)</xsl:text>
      </xsl:when>
      <!-- Ethnic -->
      <xsl:when test="@midi.instrname = 'Sitar' or @midi.instrnum = '104'">
        <xsl:text>sitar</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Banjo' or @midi.instrnum = '105'">
        <xsl:text>banjo</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Shamisen' or @midi.instrnum = '106'">
        <xsl:text>shamisen</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Koto' or @midi.instrnum = '107'">
        <xsl:text>koto</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Kalimba' or @midi.instrnum = '108'">
        <xsl:text>kalimba</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Bagpipe' or @midi.instrnum = '109'">
        <xsl:text>bagpipe</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Fiddle' or @midi.instrnum = '110'">
        <xsl:text>fiddle</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Shanai' or @midi.instrnum = '111'">
        <xsl:text>shanai</xsl:text>
      </xsl:when>
      <!-- Percussive -->
      <xsl:when test="@midi.instrname = 'Tinkle_Bell' or @midi.instrnum = '112'">
        <xsl:text>tinkle bell</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Agogo' or @midi.instrnum = '113'">
        <xsl:text>agogo</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Steel_Drums' or @midi.instrnum = '114'">
        <xsl:text>steel drums</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Woodblock' or @midi.instrnum = '115'">
        <xsl:text>woodblock</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Taiko_Drum' or @midi.instrnum = '116'">
        <xsl:text>taiko drum</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Melodic_Tom' or @midi.instrnum = '117'">
        <xsl:text>melodic tom</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Synth_Drum' or @midi.instrnum = '118'">
        <xsl:text>synth drum</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Reverse_Cymbal' or @midi.instrnum = '119'">
        <xsl:text>reverse cymbal</xsl:text>
      </xsl:when>
      <!-- Sound Effects -->
      <xsl:when test="@midi.instrname = 'Guitar_Fret_Noise' or @midi.instrnum = '120'">
        <xsl:text>guitar fret noise</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Breath_Noise' or @midi.instrnum = '121'">
        <xsl:text>breath noise</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Seashore' or @midi.instrnum = '122'">
        <xsl:text>seashore</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Bird_Tweet' or @midi.instrnum = '123'">
        <xsl:text>bird tweet</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Telephone_Ring' or @midi.instrnum = '124'">
        <xsl:text>telephone ring</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Helicopter' or @midi.instrnum = '125'">
        <xsl:text>helicopter</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Applause' or @midi.instrnum = '126'">
        <xsl:text>applause</xsl:text>
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Gunshot' or @midi.instrnum = '127'">
        <xsl:text>gunshot</xsl:text>
      </xsl:when>
      <!-- the following percussion sounds are available when channel is set to 10 -->
      <xsl:when test="@midi.instrname = 'Acoustic_Bass_Drum'">
        <!-- Key #35. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Bass_Drum_1'">
        <!-- Key #36. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Side_Stick'">
        <!-- Key #37. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Acoustic_Snare'">
        <!-- Key #38. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Hand_Clap'">
        <!-- Key #39. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Electric_Snare'">
        <!-- Key #40. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Low_Floor_Tom'">
        <!-- Key #41. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Closed_Hi_Hat'">
        <!-- Key #42. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'High_Floor_Tom'">
        <!-- Key #43. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Pedal_Hi-Hat'">
        <!-- Key #44. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Low_Tom'">
        <!-- Key #45. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Open_Hi-Hat'">
        <!-- Key #46. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Low-Mid_Tom'">
        <!-- Key #47. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Hi-Mid_Tom'">
        <!-- Key #48. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Crash_Cymbal_1'">
        <!-- Key #49. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'High_Tom'">
        <!-- Key #50. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Ride_Cymbal_1'">
        <!-- Key #51. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Chinese_Cymbal'">
        <!-- Key #52. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Ride_Bell'">
        <!-- Key #53. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Tambourine'">
        <!-- Key #54. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Splash_Cymbal'">
        <!-- Key #55. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Cowbell'">
        <!-- Key #56. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Crash_Cymbal_2'">
        <!-- Key #57. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Vibraslap'">
        <!-- Key #58. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Ride_Cymbal_2'">
        <!-- Key #59. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Hi_Bongo'">
        <!-- Key #60. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Low_Bongo'">
        <!-- Key #61. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Mute_Hi_Conga'">
        <!-- Key #62. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Open_Hi_Conga'">
        <!-- Key #63. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Low_Conga'">
        <!-- Key #64. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'High_Timbale'">
        <!-- Key #65. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Low_Timbale'">
        <!-- Key #66. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'High_Agogo'">
        <!-- Key #67. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Low_Agogo'">
        <!-- Key #68. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Cabasa'">
        <!-- Key #69. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Maracas'">
        <!-- Key #70. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Short_Whistle'">
        <!-- Key #71. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Long_Whistle'">
        <!-- Key #72. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Short_Guiro'">
        <!-- Key #73. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Long_Guiro'">
        <!-- Key #74. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Claves'">
        <!-- Key #75. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Hi_Wood_Block'">
        <!-- Key #76. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Low_Wood_Block'">
        <!-- Key #77. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Mute_Cuica'">
        <!-- Key #78. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Open_Cuica'">
        <!-- Key #79. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Mute_Triangle'">
        <!-- Key #80. -->
      </xsl:when>
      <xsl:when test="@midi.instrname = 'Open_Triangle'">
        <!-- Key #81. -->
      </xsl:when>
    </xsl:choose>
    <xsl:text>&quot;&#10;</xsl:text>
  </xsl:template>
  <!-- modify note head -->
  <xsl:template name="setSmuflGlyph">
    <!-- SMuFL glyphs -->
    <xsl:choose>
      <!-- Repeats (U+E040 – U+E04F) -->
      <xsl:when test="contains(@glyphnum,'E045')">
        <xsl:text>\markup {\bold "D.S."}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E046')">
        <xsl:text>\markup {\bold "D.C."}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E047')">
        <xsl:text>\markup {\musicglyph #"scripts.segno"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E048')">
        <xsl:text>\markup {\musicglyph #"scripts.coda"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E049')">
        <xsl:text>\markup {\musicglyph #"scripts.varcoda"}</xsl:text>
      </xsl:when>
      <!-- Holds and pauses (U+E4C0 – U+E4DF) -->
      <xsl:when test="contains(@glyphnum,'E4C0')">
        <xsl:text>\markup {\musicglyph #"scripts.ufermata"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E4C1')">
        <xsl:text>\markup {\musicglyph #"scripts.dfermata"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E4C4')">
        <xsl:text>\markup {\musicglyph #"scripts.ushortfermata"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E4C5')">
        <xsl:text>\markup {\musicglyph #"scripts.dshortfermata"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E4C6')">
        <xsl:text>\markup {\musicglyph #"scripts.ulongfermata"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E4C7')">
        <xsl:text>\markup {\musicglyph #"scripts.dlongfermata"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E4C8')">
        <xsl:text>\markup {\musicglyph #"scripts.uverylongfermata"}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E4C9')">
        <xsl:text>\markup {\musicglyph #"scripts.dverylongfermata"}</xsl:text>
      </xsl:when>
      <!-- Common ornaments (U+E560 – U+E56F) -->
      <xsl:when test="contains(@glyphnum,'E566')">
        <xsl:text>\trill</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E567')">
        <xsl:text>\turn</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E568')">
        <xsl:text>\reverseturn</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E56C')">
        <xsl:text>\prall</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E56D')">
        <xsl:text>\mordent</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E56E')">
        <xsl:text>\prallprall</xsl:text>
      </xsl:when>
      <!-- Precomposed trills and mordents (U+E5B0 – U+E5CF) -->
      <xsl:when test="contains(@glyphnum,'E5B2')">
        <xsl:text>\lineprall</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E5B5')">
        <xsl:text>\upprall</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E5B8')">
        <xsl:text>\upmordent</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E5BB')">
        <xsl:text>\prallup</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E5BD')">
        <xsl:text>\prallmordent</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E5C6')">
        <xsl:text>\downprall</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E5C7')">
        <xsl:text>\downmordent</xsl:text>
      </xsl:when>
      <xsl:when test="contains(@glyphnum,'E5C8')">
        <xsl:text>\pralldown</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- page layout -->
  <xsl:template match="mei:scoreDef" mode="makePageLayout">
    <xsl:text>\paper {&#10;</xsl:text>
    <xsl:if test="not(number(@page.height)) and not(contains(@page.height,'vu'))">
      <xsl:value-of select="concat('  paper-height = ',substring(@page.height,1,string-length(@page.height)-2),'\',substring(@page.height,string-length(@page.height)-1),'&#10;')"/>
    </xsl:if>
    <xsl:if test="not(number(@page.width)) and not(contains(@page.width,'vu'))">
      <xsl:value-of select="concat('  paper-width = ',substring(@page.width,1,string-length(@page.width)-2),'\',substring(@page.width,string-length(@page.width)-1),'&#10;')"/>
    </xsl:if>
    <xsl:if test="not(number(@page.topmar)) and not(contains(@page.topmar,'vu'))">
      <xsl:value-of select="concat('  top-margin = ',substring(@page.topmar,1,string-length(@page.topmar)-2),'\',substring(@page.topmar,string-length(@page.topmar)-1),'&#10;')"/>
    </xsl:if>
    <xsl:if test="not(number(@page.rightmar)) and not(contains(@page.rightmar,'vu'))">
      <xsl:value-of select="concat('  right-margin = ',substring(@page.rightmar,1,string-length(@page.rightmar)-2),'\',substring(@page.rightmar,string-length(@page.rightmar)-1),'&#10;')"/>
    </xsl:if>
    <xsl:if test="not(number(@page.leftmar)) and not(contains(@page.leftmar,'vu'))">
      <xsl:value-of select="concat('  left-margin = ',substring(@page.leftmar,1,string-length(@page.leftmar)-2),'\',substring(@page.leftmar,string-length(@page.leftmar)-1),'&#10;')"/>
    </xsl:if>
    <xsl:if test="not(number(@page.botmar)) and not(contains(@page.botmar,'vu'))">
      <xsl:value-of select="concat('  bottom-margin = ',substring(@page.botmar,1,string-length(@page.botmar)-2),'\',substring(@page.botmar,string-length(@page.botmar)-1),'&#10;')"/>
    </xsl:if>
    <!-- <xsl:value-of select="@page.panels"/>
    <xsl:value-of select="@page.scale"/> -->
    <xsl:text>}&#10;&#10;</xsl:text>
  </xsl:template>
  <!--               -->
  <!-- Make fraction -->
  <!--               -->
  <xsl:template name="durationMultiplier">
    <xsl:param name="decimalnum"/>
    <xsl:param name="num" select="round($decimalnum * 1000)"/>
    <!-- numerator -->
    <xsl:param name="dom" select="round(1000)"/>
    <!-- denominator -->
    <xsl:param name="gcd">
      <!-- greatest common divisor aka highest common factor -->
      <xsl:call-template name="greatest-common-divisor">
        <xsl:with-param name="num" select="$num"/>
        <xsl:with-param name="dom" select="$dom"/>
      </xsl:call-template>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$decimalnum = floor($decimalnum)">
        <xsl:value-of select="$decimalnum"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($num div $gcd,'/',$dom div $gcd)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="greatest-common-divisor">
    <xsl:param name="num"/>
    <xsl:param name="dom"/>
    <xsl:choose>
      <xsl:when test="$num &lt; 0">
        <!-- Call GCD with positive num -->
        <xsl:call-template name="greatest-common-divisor">
          <xsl:with-param name="num" select="-$num"/>
          <xsl:with-param name="dom" select="$dom"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$dom &lt; 0">
        <!-- Call GCD with positive dom -->
        <xsl:call-template name="greatest-common-divisor">
          <xsl:with-param name="num" select="$num"/>
          <xsl:with-param name="dom" select="-$dom"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$num + $dom &gt; 0">
        <!-- Valid input, call GCD-helper -->
        <xsl:call-template name="greatest-common-divisor-helper">
          <xsl:with-param name="gcd" select="$dom"/>
          <xsl:with-param name="num" select="$num"/>
          <xsl:with-param name="dom" select="$dom"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="greatest-common-divisor-helper">
    <!-- Recursive template. Call until $num = 0. -->
    <xsl:param name="gcd"/>
    <xsl:param name="num"/>
    <xsl:param name="dom"/>
    <xsl:choose>
      <xsl:when test="$num &gt; 0">
        <!-- Recursive call -->
        <xsl:call-template name="greatest-common-divisor-helper">
          <xsl:with-param name="gcd" select="$num"/>
          <xsl:with-param name="num" select="$dom mod $num"/>
          <xsl:with-param name="dom" select="$num"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$gcd"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
