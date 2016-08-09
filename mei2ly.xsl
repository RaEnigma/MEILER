<?xml version="1.0" encoding="UTF-8"?>
<!--        -->
<!-- MEILER -->
<!-- mei2ly -->
<!-- v0.5.2 -->
<!-- programmed by Klaus Rettinghaus -->
<!--        -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:m="http://www.bach-digital.de/m" xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="saxon">
  <xsl:strip-space elements="*"/>
  <xsl:output method="text" indent="no" encoding="UTF-8"/>
  <xsl:template match="/">
    <xsl:text>\version "2.18.2"&#10;</xsl:text>
    <xsl:text>% automatically converted by mei2ly.xsl&#10;&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI header -->
  <xsl:template match="mei:meiHead">
    <xsl:text>\header {&#10;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}&#10;&#10;</xsl:text>
  </xsl:template>
  <!-- MEI fileDesc -->
  <xsl:template match="mei:fileDesc">
    <xsl:value-of select="concat('  copyright = &quot;',normalize-space(descendant::mei:pubStmt[1]/mei:respStmt[1]),'&quot;&#10;')"/>
  </xsl:template>
  <!-- MEI workDesc -->
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
  <!-- MEI body element -->
  <xsl:template match="mei:body">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI score element -->
  <xsl:template match="mei:score">
    <xsl:for-each select="descendant::mei:scoreDef[1]/descendant::mei:staffDef">
      <xsl:variable name="staffNumber" select="@n"/>
      <xsl:value-of select="concat('Staff',codepoints-to-string(xs:integer(64 + $staffNumber)),' = {&#10;')"/>
      <xsl:for-each select="/mei:mei/mei:music//mei:staff[@n=$staffNumber]">
        <xsl:text>&#32;&#32;</xsl:text>
        <xsl:if test="ancestor::mei:measure/preceding-sibling::mei:staffDef[@n = $staffNumber][@clef.shape]/preceding-sibling::mei:measure[1]/@n = ancestor::mei:measure/preceding-sibling::mei:measure[1]/@n">
          <xsl:call-template name="setClef">
            <xsl:with-param name="clefShape" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.shape"/>
            <xsl:with-param name="clefLine" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.line"/>
            <xsl:with-param name="clefDis" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.dis"/>
            <xsl:with-param name="clefDisPlace" select="preceding::mei:staffDef[@n = $staffNumber][@clef.shape][1]/@clef.dis.place"/>
          </xsl:call-template>
          <xsl:text>&#10;&#32;&#32;</xsl:text>
        </xsl:if>
        <xsl:if test="ancestor::mei:measure/preceding-sibling::*[1]/@key.sig">
          <xsl:call-template name="setKeySignature">
            <xsl:with-param name="accidentals" select="ancestor::mei:measure/preceding-sibling::*[1]/@key.sig"/>
          </xsl:call-template>
          <xsl:text>&#32;&#32;</xsl:text>
        </xsl:if>
        <xsl:for-each select="ancestor::mei:measure/mei:tempo">
          <xsl:call-template name="setTempo"/>
        </xsl:for-each>
        <xsl:if test="ancestor::mei:measure/@metcon='false'">
          <xsl:value-of select="concat('\partial ',descendant::*[@dur][1]/@dur,'&#32;')"/>
        </xsl:if>
        <xsl:text>&lt;&lt;&#32;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;&gt;&#32;</xsl:text>
        <!-- print bar line -->
        <xsl:if test="ancestor::mei:measure/@right">
          <xsl:call-template name="setBarLine">
            <xsl:with-param name="barLineStyle" select="ancestor::mei:measure/@right"/>
          </xsl:call-template>
        </xsl:if>
        <!-- print bar number -->
        <xsl:value-of select="concat('%',ancestor::mei:measure/@n,'&#10;')"/>
        <!-- add breaks -->
        <xsl:if test="following::mei:sb[1][following::mei:measure[1]/@n = current()/ancestor::mei:measure/@n + 1]">
          <xsl:text>&#32;&#32;\break&#10;</xsl:text>
        </xsl:if>
        <xsl:if test="following::mei:pb[1][following::mei:measure[1]/@n = current()/ancestor::mei:measure/@n + 1]">
          <xsl:text>&#32;&#32;\pageBreak</xsl:text>
          <xsl:if test="following::mei:pb[1]/@n">
            <xsl:value-of select="concat(' %',following::mei:pb[1]/@n)"/>
          </xsl:if>
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>}&#10;&#10;</xsl:text>
      <!-- lilypond figured bass -->
      <xsl:if test="/mei:mei/mei:music//mei:harm[descendant-or-self::*/@staff=$staffNumber]">
        <xsl:value-of select="concat('Staff',codepoints-to-string(xs:integer(64 + $staffNumber)),'_fb = \figuremode {&#10;')"/>
        <xsl:for-each select="/mei:mei/mei:music//mei:measure">
          <xsl:text>&#32;&#32;</xsl:text>
          <xsl:variable name="meterCount" select="preceding::*[@meter.count][1]/@meter.count"/>
          <xsl:variable name="meterUnit" select="preceding::*[@meter.unit][1]/@meter.unit"/>
          <xsl:if test="not(descendant::mei:harm[@staff=$staffNumber])">
            <xsl:call-template name="setMeasureSpace"/>
          </xsl:if>
          <xsl:apply-templates select="mei:harm[@staff=$staffNumber]"/>
          <xsl:value-of select="concat('%',@n,'&#10;')"/>
        </xsl:for-each>
        <xsl:text>}&#10;&#10;</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <!-- lilypond lyrics -->
    <xsl:for-each select="descendant::mei:scoreDef[1]/descendant::mei:staffDef">
      <xsl:variable name="staffNumber" select="@n"/>
      <xsl:if test="/mei:mei/mei:music//mei:staff[@n=$staffNumber]//mei:syl">
        <xsl:value-of select="concat('Lyrics',codepoints-to-string(xs:integer(64 + $staffNumber)),' = \lyricmode {&#10; ')"/>
        <xsl:for-each select="/mei:mei/mei:music//mei:staff[@n=$staffNumber]">
          <xsl:for-each select="descendant::*[name()='note' or name()='rest' or name()='mRest']">
            <xsl:if test="not(@grace)">
              <xsl:choose>
                <xsl:when test="descendant::mei:syl">
                  <xsl:value-of select="concat(' ',descendant::mei:syl[1])"/>
                  <xsl:call-template name="setDuration"/>
                  <xsl:if test="descendant::mei:syl[1]/@wordpos='i' or descendant::mei:syl[1]/@wordpos='m'">
                    <xsl:value-of select="'--'"/>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="@syl">
                  <xsl:value-of select="concat(' ',@syl)"/>
                  <xsl:call-template name="setDuration"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="' _'"/>
                  <xsl:call-template name="setDuration"/>
                  <xsl:if test="not(@dur)">
                    <xsl:value-of select="concat(preceding::mei:scoreDef[@meter.unit][1]//@meter.unit[1],'*',preceding::mei:scoreDef[@meter.count][1]//@meter.count)"/>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:text>}&#10;&#10;</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>&#10;</xsl:text>
    <!-- lilypond score block -->
    <xsl:text>\score { &lt;&lt;&#10;</xsl:text>
    <xsl:apply-templates select="descendant::mei:scoreDef[1]"/>
    <xsl:text>&gt;&gt;&#10;}&#10;</xsl:text>
  </xsl:template>
  <!-- MEI score definition -->
  <xsl:template match="mei:scoreDef">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI staff group -->
  <xsl:template match="mei:staffGrp">
    <xsl:text>\new StaffGroup </xsl:text>
    <xsl:if test="@label or @label.abbr">
      <xsl:call-template name="setInstrumentName"/>
    </xsl:if>
    <xsl:text>&lt;&lt;&#10;</xsl:text>
    <xsl:call-template name="setStaffGrpStyle"/>
    <xsl:apply-templates/>
    <xsl:text>&gt;&gt;&#10;</xsl:text>
  </xsl:template>
  <!-- MEI staff definitons -->
  <xsl:template match="mei:staffDef">
    <xsl:variable name="staffNumber" select="@n"/>
    <xsl:text>  \new Staff = &quot;Staff </xsl:text>
    <xsl:value-of select="$staffNumber"/>
    <xsl:text>&quot;&#32;</xsl:text>
    <xsl:if test="@label or @label.abbr">
      <xsl:call-template name="setInstrumentName"/>
    </xsl:if>
    <xsl:if test="//mei:harm[descendant::mei:fb]/@staff = $staffNumber">
      <xsl:value-of select="concat('&#10;  \Staff',codepoints-to-string(xs:integer(64 + $staffNumber)),'_fb')"/>
      <xsl:text>&#10;  \context Staff = &quot;Staff </xsl:text>
      <xsl:value-of select="$staffNumber"/>
      <xsl:text>&quot;&#32;</xsl:text>
    </xsl:if>
    <xsl:text>{&#10;    </xsl:text>
    <xsl:apply-templates select="mei:instrDef"/>
    <xsl:text>\autoBeamOff \set tieWaitForNote = ##t&#10;    </xsl:text>
    <xsl:call-template name="setClef">
      <xsl:with-param name="clefShape" select="@clef.shape"/>
      <xsl:with-param name="clefLine" select="@clef.line"/>
      <xsl:with-param name="clefDis" select="@clef.dis"/>
      <xsl:with-param name="clefDisPlace" select="@clef.dis.place"/>
    </xsl:call-template>
    <xsl:call-template name="setTimeSig">
      <xsl:with-param name="meterSymbol" select="ancestor-or-self::*[@meter.sym][1]/@meter.sym[1]"/>
      <xsl:with-param name="meterCount" select="ancestor-or-self::*[@meter.count][1]/@meter.count"/>
      <xsl:with-param name="meterUnit" select="ancestor-or-self::*[@meter.unit][1]/@meter.unit"/>
      <xsl:with-param name="meterRend" select="ancestor-or-self::*[@meter.rend][1]/@meter.rend"/>
    </xsl:call-template>
    <xsl:call-template name="setKeySignature">
      <xsl:with-param name="accidentals" select="ancestor-or-self::*/@key.sig"/>
    </xsl:call-template>
    <xsl:value-of select="concat('\Staff',codepoints-to-string(xs:integer(64 + $staffNumber)))"/>
    <xsl:text>&#32;}&#10;</xsl:text>
    <xsl:if test="//mei:syl[ancestor::mei:staff/@n = $staffNumber]">
      <xsl:value-of select="concat('  \new Lyrics \Lyrics',codepoints-to-string(xs:integer(64 + $staffNumber)),'&#10;  ')"/>
    </xsl:if>
  </xsl:template>
  <!-- MEI instrument definition -->
  <xsl:template match="mei:instrDef">
    <xsl:if test="@midi.instrname">
      <xsl:choose>
        <xsl:when test="parent::mei:staffDef">
          <xsl:value-of select="concat('\set Staff.midiInstrument = #&quot;',@midi.instrname,'&quot;&#10;    ')"/>
        </xsl:when>
        <xsl:when test="parent::mei:staffGrp">
          <xsl:value-of select="concat('  \set StaffGroup.midiInstrument = #&quot;',@midi.instrname,'&quot;&#10;')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <!-- MEI sections -->
  <xsl:template match="mei:section">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- MEI measures -->
  <xsl:template name="measures" match="mei:measure">
    <xsl:value-of select="'  '"/>
    <xsl:if test="@left">
      <xsl:call-template name="setBarLine">
        <xsl:with-param name="barLineStyle" select="@left"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="mei:tempo"/>
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
        <xsl:when test="$clefDis = 8">
          <xsl:choose>
            <xsl:when test="$clefDisPlace='below'">
              <xsl:value-of select="-7"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="7"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$clefDis != 8 and $clefDisPlace='below'">
          <xsl:value-of select="-1 * clefDis"/>
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
      <xsl:value-of select="concat('\override Staff.Clef.color = #(x11-color &quot;',$clefColor,'&quot;) ')"/>
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
    <xsl:if test="@visible='false'">
      <xml:text>\once \hideNotes </xml:text>
    </xsl:if>
    <xsl:if test="@head.color">
      <xsl:value-of select="concat('\once \override NoteHead.color = #(x11-color &quot;',@head.color,'&quot;) ')"/>
    </xsl:if>
    <xsl:if test="//mei:octave[@dis='8']/@startid = $noteKey">
      <xml:text>\set Staff.ottavation = #"8va" </xml:text>
    </xsl:if>
    <xsl:call-template name="setStemDir"/>
    <xsl:if test="@grace and not(preceding::mei:note[1]/@grace)">
      <xsl:call-template name="setGraceNote"/>
      <xsl:if test="parent::mei:beam and position()=1">
        <xml:text>{</xml:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="(starts-with(@tuplet,'i') or (//mei:tupletSpan/@startid = $noteKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="concat('\tuplet ',//mei:tupletSpan[@startid = $noteKey]/@num,'/',//mei:tupletSpan[@startid = $noteKey]/@numbase,' {')"/>
    </xsl:if>
    <xsl:if test="@head.shape = 'x'">
      <xml:text>\xNote </xml:text>
    </xsl:if>
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
    <xsl:if test="not(parent::mei:chord/@dur)">
      <xsl:call-template name="setDuration"/>
    </xsl:if>
    <xsl:if test="contains(@tie,'i') or contains(@tie,'m') or (//mei:tie/@startid = $noteKey)">
      <xml:text>~</xml:text>
    </xsl:if>
    <xsl:if test="parent::mei:beam">
      <xsl:if test="position()=1">
        <xml:text>[</xml:text>
      </xsl:if>
      <xsl:if test="position()=last()">
        <xml:text>]</xml:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="contains(@slur,'t') or (//mei:slur/@endid = $noteKey)">
      <xml:text>)</xml:text>
    </xsl:if>
    <xsl:if test="contains(@slur,'i') or (//mei:slur/@startid = $noteKey)">
      <xsl:call-template name="setMarkupDirection">
        <xsl:with-param name="direction" select="//mei:slur[@startid = $noteKey]/@curvedir"/>
      </xsl:call-template>
      <xml:text>(</xml:text>
    </xsl:if>
    <xsl:if test="@grace and parent::mei:beam and position()=last()">
      <xml:text>}</xml:text>
    </xsl:if>
    <xsl:if test="//mei:hairpin/@endid = $noteKey or //mei:dynam/@endid = $noteKey">
      <xml:text>\!</xml:text>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/mei:dynam[@startid = $noteKey]"/>
    <xsl:apply-templates select="ancestor::mei:measure/mei:hairpin[@startid = $noteKey]"/>
    <xsl:apply-templates/>
    <xsl:if test="@artic">
      <xsl:call-template name="artic"/>
    </xsl:if>
    <xsl:call-template name="ornam"/>
    <xsl:if test="//mei:trill/@endid = $noteKey">
      <xml:text>\stopTrillSpan</xml:text>
    </xsl:if>
    <xsl:if test="//mei:trill/@startid = $noteKey">
      <xsl:choose>
        <xsl:when test="//mei:trill[@startid = $noteKey]/@endid">
          <xml:text>\startTrillSpan</xml:text>
        </xsl:when>
        <xsl:otherwise>
          <xml:text>\trill</xml:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/mei:pedal[@startid = $noteKey]"/>
    <xsl:if test="@fermata or (//mei:fermata/@startid = $noteKey)">
      <xsl:call-template name="fermata"/>
    </xsl:if>
    <xsl:if test="(starts-with(@tuplet,'t') or (//mei:tupletSpan/@endid = $noteKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="'} '"/>
    </xsl:if>
    <xsl:if test="//mei:octave[@dis='8']/@endid = $noteKey">
      <xml:text>\unset Staff.ottavation</xml:text>
    </xsl:if>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI chords -->
  <xsl:template match="mei:chord">
    <xsl:variable name="chordKey" select="concat('#',./@xml:id)"/>
    <xsl:variable name="subChordKeys" select="descendant-or-self::*/concat('#',./@xml:id)"/>
    <xsl:variable name="chordSubIDs" select="descendant-or-self::*/@xml:id"/>
    <xsl:if test="@visible='false'">
      <xml:text>\once \hideNotes </xml:text>
    </xsl:if>
    <xsl:if test="//mei:octave[@dis='8']/@startid = $chordKey">
      <xml:text>\set Staff.ottavation = #"8va" </xml:text>
    </xsl:if>
    <xsl:call-template name="setStemDir"/>
    <xsl:if test="(starts-with(@tuplet,'i') or (//mei:tupletSpan/@startid = $chordKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="concat('\tuplet ',//mei:tupletSpan[@startid = $chordKey]/@num,'/',//mei:tupletSpan[@startid = $chordKey]/@numbase,' {')"/>
    </xsl:if>
    <xsl:if test="//mei:arpeg[tokenize(@plist,' ') = $subChordKeys or @startid = $chordKey]/@order">
      <xsl:call-template name="setArpegStyle">
        <xsl:with-param name="arpegStyle" select="//mei:arpeg[tokenize(@plist,' ') = $subChordKeys or @startid = $chordKey]/@order"/>
      </xsl:call-template>
    </xsl:if>
    <xml:text>&lt; </xml:text>
    <xsl:apply-templates select="mei:note"/>
    <xml:text>&gt;</xml:text>
    <xsl:call-template name="setDuration"/>
    <xsl:if test="contains(@tie,'i') or contains(@tie,'m') or (//mei:tie/@startid = $chordKey)">
      <xml:text>~</xml:text>
    </xsl:if>
    <xsl:if test="parent::mei:beam">
      <xsl:if test="position()=1">
        <xml:text>[</xml:text>
      </xsl:if>
      <xsl:if test="position()=last()">
        <xml:text>]</xml:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="contains(@slur,'t') or (//mei:slur/@endid = $chordKey)">
      <xml:text>)</xml:text>
    </xsl:if>
    <xsl:if test="contains(@slur,'i') or (//mei:slur/@startid = $chordKey)">
      <xml:text>(</xml:text>
    </xsl:if>
    <xsl:if test="//mei:arpeg[tokenize(@plist,' ') = $subChordKeys or @startid = $chordKey]">
      <xml:text>\arpeggio</xml:text>
    </xsl:if>
    <xsl:if test="//mei:hairpin/@endid = $chordKey or //mei:dynam/@endid = $chordKey">
      <xml:text>\!</xml:text>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/mei:dynam[@startid = $chordKey]"/>
    <xsl:apply-templates select="ancestor::mei:measure/mei:hairpin[@startid = $chordKey]"/>
    <xsl:apply-templates select="mei:artic[1]"/>
    <xsl:if test="@artic">
      <xsl:call-template name="artic"/>
    </xsl:if>
    <xsl:if test="@fermata or (//mei:fermata/@startid = $chordKey)">
      <xsl:call-template name="fermata"/>
    </xsl:if>
    <xsl:call-template name="ornam"/>
    <xsl:if test="(starts-with(@tuplet,'t') or (//mei:tupletSpan/@endid = $chordKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="'} '"/>
    </xsl:if>
    <xsl:if test="//mei:octave[@dis='8']/@endid = $chordKey">
      <xml:text>\unset Staff.ottavation</xml:text>
    </xsl:if>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI rests -->
  <xsl:template match="mei:rest">
    <xsl:variable name="restKey" select="concat('#',./@xml:id)"/>
    <xsl:if test="@visible='false'">
      <xml:text>\once \hideNotes </xml:text>
    </xsl:if>
    <xsl:if test="(starts-with(@tuplet,'i') or (//mei:tupletSpan/@startid = $restKey)) and not(ancestor::mei:tuplet)">
      <xsl:value-of select="concat('\tuplet ',//mei:tupletSpan[@startid = $restKey]/@num,'/',//mei:tupletSpan[@startid = $restKey]/@numbase,' {')"/>
    </xsl:if>
    <xml:text>r</xml:text>
    <xsl:call-template name="setDuration"/>
    <xsl:if test="//mei:hairpin/@endid = $restKey or //mei:dynam/@endid = $restKey">
      <xml:text>\!</xml:text>
    </xsl:if>
    <xsl:apply-templates select="ancestor::mei:measure/mei:dynam[@startid = $restKey]"/>
    <xsl:apply-templates select="ancestor::mei:measure/mei:hairpin[@startid = $restKey]"/>
    <xsl:if test="@fermata or (//mei:fermata/@startid = $restKey)">
      <xsl:call-template name="fermata"/>
    </xsl:if>
    <xsl:if test="starts-with(@tuplet,'t') or (//mei:tupletSpan/@endid = $restKey)">
      <xsl:value-of select="'} '"/>
    </xsl:if>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI measure rest -->
  <xsl:template name="setMeasureRest" match="mei:mRest">
    <xml:text>R</xml:text>
    <xsl:choose>
      <xsl:when test="@dur">
        <xsl:call-template name="setDuration"/>
      </xsl:when>
      <xsl:when test="preceding::*/@meter.unit">
        <xsl:value-of select="concat(preceding::*[@meter.unit][1]/@meter.unit,'*',preceding::*[@meter.count][1]/@meter.count)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
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
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="' '"/>
  </xsl:template>
  <!-- MEI accidentals elements -->
  <xsl:template match="mei:accid"/>
  <!-- MEI articulation -->
  <xsl:template name="artic" match="mei:artic">
    <xsl:if test="name()='artic'">
      <xsl:call-template name="setMarkupDirection">
        <xsl:with-param name="direction" select="@place"/>
      </xsl:call-template>
    </xsl:if>
    <!-- ly:Articulation scripts -->
    <xsl:for-each select="tokenize(@artic,'\s+')">
      <xsl:choose>
        <xsl:when test=". = 'acc'">
          <xsl:text>\accent</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'stacc'">
          <xsl:text>\staccato</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'ten'">
          <xsl:text>\tenuto</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'stacciss'">
          <xsl:text>\staccatissimo</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'marc'">
          <xsl:text>\marcato</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'dot'">
          <xsl:text>\staccato</xsl:text>
        </xsl:when>
        <!-- ly:Instrument-specific scripts -->
        <xsl:when test=". = 'dnbow'">
          <xsl:text>\downbow</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'upbow'">
          <xsl:text>\upbow</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'harm'">
          <xsl:text>\flageolet</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'snap'">
          <xsl:text>\snappizzicato</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'open'">
          <xsl:text>\open</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'stop'">
          <xsl:text>\stopped</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <!-- MEI fermata -->
  <xsl:template name="fermata" match="mei:fermata">
    <xsl:if test="@place='above' or @fermata='above'">
      <xsl:text>^</xsl:text>
    </xsl:if>
    <xsl:if test="@place='below' or @fermata='below'">
      <xsl:text>_</xsl:text>
    </xsl:if>
    <xml:text>\fermata</xml:text>
  </xsl:template>
  <!-- MEI mordent -->
  <xsl:template name="mordent" match="mei:mordent">
    <xsl:call-template name="setMarkupDirection">
      <xsl:with-param name="direction" select="@place"/>
    </xsl:call-template>
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
  </xsl:template>
  <!-- MEI octave -->
  <xsl:template match="mei:octave">
  </xsl:template>
  <!-- MEI ornament attributes -->
  <xsl:template name="ornam">
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
  <!-- MEI tuplet elements -->
  <xsl:template match="mei:tuplet">
    <xsl:if test="@bracket.visible">
      <xsl:value-of select="'\once \override TupletBracket.bracket-visibility = ##',substring(@bracket.visible,1,1),' '"/>
    </xsl:if>
    <xsl:if test="@num.visible='false'">
      <xsl:value-of select="'\once \omit TupletNumber '"/>
    </xsl:if>
    <xsl:if test="@num.format='ratio'">
      <xsl:value-of select="'\once \override TupletNumber.text = #tuplet-number::calc-fraction-text '"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@bracket.place='above' or @num.place='above'">
        <xsl:value-of select="'\once \tupletDown '"/>
      </xsl:when>
      <xsl:when test="@bracket.place='below' or @num.place='below'">
        <xsl:value-of select="'\once \tupletUp '"/>
      </xsl:when>
    </xsl:choose>
    <xsl:value-of select="concat('\tuplet ',@num,'/',@numbase,' {')"/>
    <xsl:apply-templates/>
    <xsl:text>} </xsl:text>
  </xsl:template>
  <!-- MEI dynamic -->
  <xsl:template match="mei:dynam">
    <xsl:call-template name="setMarkupDirection">
      <xsl:with-param name="direction" select="@place"/>
    </xsl:call-template>
    <xsl:value-of select="concat('\',.)"/>
  </xsl:template>
  <!-- MEI hairpin -->
  <xsl:template match="mei:hairpin">
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
    <xsl:variable name="meterCount" select="preceding::*[@meter.count][1]/@meter.count"/>
    <xsl:variable name="meterUnit" select="preceding::*[@meter.unit][1]/@meter.unit"/>
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
        <xsl:call-template name="decimal-to-fraction">
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
          <xsl:call-template name="decimal-to-fraction">
            <xsl:with-param name="decimalnum" select="$meterCount - @tstamp + 1"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat('*',$meterFactor)"/>
      </xsl:when>
      <xsl:when test="following-sibling::mei:harm[@staff = current()/@staff]/mei:fb and (following-sibling::mei:harm[@staff = current()/@staff][mei:fb][1]/@tstamp - @tstamp != 1)">
        <xsl:variable name="meterFactor">
          <xsl:call-template name="decimal-to-fraction">
            <xsl:with-param name="decimalnum" select="following-sibling::mei:harm[@staff = current()/@staff][mei:fb][1]/@tstamp - @tstamp"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat('*',$meterFactor)"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>&#32;</xsl:text>
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
    <xsl:if test="following-sibling::mei:f">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>
  <!-- MEI tempo -->
  <xsl:template name="setTempo" match="mei:tempo">
    <xsl:value-of select="concat('\tempo &quot;',normalize-space(.),'&quot;&#10;  ')"/>
  </xsl:template>
  <!-- MEI rend -->
  <xsl:template match="mei:rend">
    <xsl:if test="@color">
      <xsl:value-of select="concat('\with-color #(x11-color &quot;',@color,'&quot;) ')"/>
    </xsl:if>
    <xsl:if test="@fontweight">
      <xsl:value-of select="concat('\',@fontweight,' ')"/>
    </xsl:if>
    <xsl:if test="@fontstyle">
      <xsl:value-of select="concat('\',@fontstyle),' '"/>
    </xsl:if>
    <xsl:text>{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>} </xsl:text>
  </xsl:template>
  <!-- excluded elements -->
  <xsl:template match="mei:app"/>
  <xsl:template match="mei:dir"/>
  <xsl:template match="mei:encodingDesc"/>
  <xsl:template match="mei:label"/>
  <xsl:template match="mei:lyr"/>
  <xsl:template match="mei:ornam"/>
  <xsl:template match="mei:pgHead"/>
  <xsl:template match="mei:pgFoot"/>
  <xsl:template match="mei:revisionDesc"/>
  <xsl:template match="mei:sourceDesc"/>
  <xsl:template match="mei:syl"/>
  <xsl:template match="mei:symbol"/>
  <xsl:template match="mei:verse"/>
  <!-- helper templates -->
  <!-- set octave -->
  <xsl:template name="setOctave">
    <xsl:if test="@oct &lt; 3">
      <xsl:for-each select="@oct to 2">
        <xsl:text>,</xsl:text>
      </xsl:for-each>
    </xsl:if>
    <xsl:if test="@oct &gt; 3">
      <xsl:for-each select="4 to @oct">
        <xsl:text>'</xsl:text>
      </xsl:for-each>
    </xsl:if>
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
  </xsl:template>
  <!-- set duration -->
  <xsl:template name="setDuration">
    <xsl:choose>
      <xsl:when test="@dur='breve'">
        <xsl:text>\breve</xsl:text>
      </xsl:when>
      <xsl:when test="@dur='longa'">
        <xsl:text>\longa</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@dur"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="1 to @dots">
      <xsl:text>.</xsl:text>
    </xsl:for-each>
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
  <!-- set instrument names -->
  <xsl:template name="setInstrumentName">
    <xsl:text>\with { </xsl:text>
    <xsl:if test="@label">
      <xsl:value-of select="concat('instrumentName = #&quot;',@label,'&quot; ')"/>
    </xsl:if>
    <xsl:if test="@label.abbr">
      <xsl:value-of select="concat('shortInstrumentName = #&quot;',@label,'&quot; ')"/>
    </xsl:if>
    <xsl:text>} </xsl:text>
  </xsl:template>
  <!-- set key -->
  <xsl:template name="setKeySignature">
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
  <!-- set time sig -->
  <xsl:template name="setTimeSig">
    <xsl:param name="meterSymbol" />
    <xsl:param name="meterCount" />
    <xsl:param name="meterUnit" />
    <xsl:param name="meterRend" />
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
      <xsl:when test="$meterCount or $meterUnit">
        <xsl:if test="($meterCount = $meterUnit) and not($meterSymbol)">
          <xsl:text>\once \numericTimeSignature </xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$meterRend = 'num'">
            <xsl:text>\once \override Staff.TimeSignature.style = #'single-digit </xsl:text>
          </xsl:when>
          <xsl:when test="$meterRend = 'invis'">
            <xsl:text>\once \override Staff.TimeSignature.transparent = ##t </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="concat('\time ',$meterCount,'/',$meterUnit,' ')"/>
      </xsl:when>
    </xsl:choose>
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
      <xsl:value-of select="concat('  \override StaffGroup.BarLine.allow-span-bar = ##',substring(@barthru,1,1)),'&#10;'"/>
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
  <!-- set arpeggio style -->
  <xsl:template name="setArpegStyle">
    <xsl:param name="arpegStyle" select="@order"/>
    <xsl:choose>
      <xsl:when test="$arpegStyle = 'up'">
        <xml:text>\once \arpeggioArrowUp </xml:text>
      </xsl:when>
      <xsl:when test="$arpegStyle = 'down'">
        <xml:text>\once \arpeggioArrowDown </xml:text>
      </xsl:when>
      <xsl:when test="$arpegStyle = 'nonarp'">
        <xml:text>\once \arpeggioBracket </xml:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <!-- set simple markup diections -->
  <xsl:template name="setMarkupDirection">
    <xsl:param name="direction"/>
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
  <!--                -->
  <!-- Bruch erzeuger -->
  <!--                -->
  <xsl:template name="decimal-to-fraction">
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
    <xsl:value-of select="$num div $gcd"/>/<xsl:value-of select="$dom div $gcd"/>
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
        <!-- Error, both parameters zero -->
        <xsl:text>error</xsl:text>
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
