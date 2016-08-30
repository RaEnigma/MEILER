<?xml version="1.0" encoding="UTF-8"?>
<!--                                      -->
<!-- silly.xsl                            -->
<!-- Strip Individual Layout for Lilypond -->
<!-- v0.1.0                               -->
<!-- programmed by Klaus Rettinghaus      -->
<!--                                      -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mei="http://www.music-encoding.org/ns/mei">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:strip-space elements="*"/>
  <xsl:template match="node()|@*" name="identity">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@num.place"/>
  <xsl:template match="@place"/>
  <!-- remove direction of ties and slurs -->
  <xsl:template match="@curvedir"/>
  <!-- remove stem styling -->
  <xsl:template match="@stem.dir"/>
  <xsl:template match="@stem.y"/>
  <!-- remove positioning of rests -->
  <xsl:template match="@ploc"/>
  <xsl:template match="@oloc"/>
  <!-- remove breaks -->
  <xsl:template match="mei:sb"/>
  <xsl:template match="mei:pb"/>
</xsl:stylesheet>
