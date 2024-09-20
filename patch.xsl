<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes"/>

    <!-- Identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Template for disk elements -->
    <xsl:template match="devices/disk">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[not(self::target)]"/>
            <target>
                <xsl:attribute name="dev">
                    <xsl:choose>
                        <xsl:when test="target/@dev = 'hda'">sda</xsl:when>
                        <xsl:when test="target/@dev = 'hdb'">sdb</xsl:when>
                        <xsl:when test="target/@dev = 'hdc'">sdc</xsl:when>
                        <xsl:when test="target/@dev = 'hdd'">sdd</xsl:when>
                        <xsl:otherwise><xsl:value-of select="target/@dev"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="bus">
                    <xsl:choose>
                        <xsl:when test="target/@bus = 'ide'">sata</xsl:when>
                        <xsl:otherwise><xsl:value-of select="target/@bus"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:apply-templates select="target/@*[not(name()='dev' or name()='bus')]"/>
                <xsl:apply-templates select="target/node()"/>
            </target>
            <xsl:apply-templates select="*[not(self::target) and following-sibling::target]"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>