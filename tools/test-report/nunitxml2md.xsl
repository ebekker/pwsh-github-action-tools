<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:ms="urn:schemas-microsoft-com:xslt"
                xmlns:dt="urn:schemas-microsoft-com:datatypes"
                xmlns:nuxml="urn:nuxml"
                xmlns:trx="http://microsoft.com/schemas/VisualStudio/TeamTest/2010"
                >

    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>

    <xsl:param name="reportTitle">
        <xsl:value-of select="/test-results/@name" />
        <xsl:text>_</xsl:text>
        <xsl:value-of select="/test-results/@date" />
        <xsl:text>_</xsl:text>
        <xsl:value-of select="/test-results/@time" />
    </xsl:param>

<!--https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md-->
<!--
    :radio_button:
    :x:
    
    :white_circle:
    :grey_question:
-->
    <xsl:template match="/">
# Test Report: <xsl:value-of select="$reportTitle" />

* Date: <xsl:value-of select="/test-results/@date" />
* Time: <xsl:value-of select="/test-results/@time" />

Expand the following summaries for more details:

&lt;details&gt;
    &lt;summary&gt; Environment:
    &lt;/summary&gt;

| **Env** | |
|--|--|
| **`user`:**          | `<xsl:value-of select="/test-results/environment/@user" />`
| **`cwd`:**           | `<xsl:value-of select="/test-results/environment/@cwd" />`
| **`os-version`:**    | `<xsl:value-of select="/test-results/environment/@os-version" />`
| **`user-domain`:**   | `<xsl:value-of select="/test-results/environment/@user-domain" />`
| **`machine-name`:**  | `<xsl:value-of select="/test-results/environment/@machine-name" />`
| **`nunit-version`:** | `<xsl:value-of select="/test-results/environment/@nunit-version" />`
| **`clr-version`:**   | `<xsl:value-of select="/test-results/environment/@clr-version" />`
| **`platform`:**      | `<xsl:value-of select="/test-results/environment/@platform" />`



&lt;/details&gt;

<xsl:variable name="passedCount" select="/test-results/@total - /test-results/@errors - /test-results/@failures - /test-results/@not-run - /test-results/@inconclusive - /test-results/@ignored - /test-results/@skipped - /test-results/@invalid" />

&lt;details&gt;
    &lt;summary&gt; Outcome: <xsl:value-of select="/test-rsults/test-suite/@result" />
        /> | Total Tests: <xsl:value-of select="/test-results/@total"
        /> | Passed: <xsl:value-of select="$passedCount"
        /> | Failed: <xsl:value-of select="/test-results/@failures" />
    &lt;/summary&gt;

| **Counters** | |
|-|-|
| **Total:**        | <xsl:value-of select="/test-results/@total" />
| **Errors:**       | <xsl:value-of select="/test-results/@errors" />
| **Failures:**     | <xsl:value-of select="/test-results/@failures" />
| **Not-run:**      | <xsl:value-of select="/test-results/@not-run" />
| **Inconclusive:** | <xsl:value-of select="/test-results/@inconclusive" />
| **Ignored:**      | <xsl:value-of select="/test-results/@ignored" />
| **Skipped:**      | <xsl:value-of select="/test-results/@skipped" />
| **Invalid:**      | <xsl:value-of select="/test-results/@invalid" />



&lt;/details&gt;


## Tests:

        <xsl:apply-templates select="/test-results/test-suite" />
    </xsl:template>

    <xsl:template match="test-suite">
        <xsl:param name="parentName" />
        <xsl:variable name="myName">
            <xsl:value-of select="$parentName" />
            <xsl:text> / </xsl:text>
            <xsl:value-of select="@name" />
        </xsl:variable>

        <xsl:if test="count(results/test-case)">
### <xsl:value-of select="$myName" />
            <xsl:apply-templates select="results/test-case">
                <xsl:with-param name="parentName" select="$myName" />
            </xsl:apply-templates>
        </xsl:if>

        <xsl:apply-templates select="results/test-suite">
            <xsl:with-param name="parentName" select="$myName" />
        </xsl:apply-templates>

    </xsl:template>

    <xsl:template match="test-case">
        <xsl:param name="parentName" />
        <xsl:variable name="myName">
            <xsl:value-of select="$parentName" />
            <xsl:text> / </xsl:text>
            <xsl:value-of select="@name" />
        </xsl:variable>
        <xsl:variable name="testResult"
                      select="@result" />
        <xsl:variable name="testOutcomeIcon">
            <xsl:choose>
                <xsl:when test="$testResult = 'Success'">:heavy_check_mark:</xsl:when>
                <xsl:when test="$testResult = 'Failure'">:x:</xsl:when>
                <!-- <xsl:when test="$testResult = 'NotExecuted'">:radio_button:</xsl:when> -->
                <xsl:otherwise>:grey_question:</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

&lt;details&gt;
    &lt;summary&gt;
<xsl:value-of select="$testOutcomeIcon" />
<xsl:text> </xsl:text>
<xsl:value-of select="@name" />
    &lt;/summary&gt;

<xsl:value-of select="@description" />

| | |
|-|-|
| **Parent:**        | `<xsl:value-of select="$parentName" />`
| **Name:**          | `<xsl:value-of select="@name" />`
| **Outcome:**       | `<xsl:value-of select="$testResult" />` <xsl:value-of select="$testOutcomeIcon" />
| **Time:**          | `<xsl:value-of select="@time" />` seconds

        <xsl:apply-templates select="failure" />
&lt;/details&gt;
    
    </xsl:template>

    <xsl:template match="failure">

&lt;details&gt;
    &lt;summary&gt;Error Message:&lt;/summary&gt;

```text
<xsl:value-of select="message" />
```
&lt;/details&gt;

&lt;details&gt;
    &lt;summary&gt;Error Stack Trace:&lt;/summary&gt;

```text
<xsl:value-of select="stack-trace" />
```
&lt;/details&gt;

    </xsl:template>


    <xsl:template match="trx:UnitTest">
        <xsl:variable name="testId"
                      select="@id" />
        <xsl:variable name="testResult"
                      select="/trx:TestRun/trx:Results/trx:UnitTestResult[@testId=$testId]" />
        <xsl:variable name="testOutcomeIcon">
            <xsl:choose>
                <xsl:when test="$testResult/@outcome = 'Passed'">:heavy_check_mark:</xsl:when>
                <xsl:when test="$testResult/@outcome = 'Failed'">:x:</xsl:when>
                <xsl:when test="$testResult/@outcome = 'NotExecuted'">:radio_button:</xsl:when>
                <xsl:otherwise>:grey_question:</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

<!--
  <xs:simpleType name="TestOutcome">
    <xs:restriction base="xs:string">
      <xs:enumeration value="Error"/>
      <xs:enumeration value="Failed"/>
      <xs:enumeration value="Timeout"/>
      <xs:enumeration value="Aborted"/>
      <xs:enumeration value="Inconclusive"/>
      <xs:enumeration value="PassedButRunAborted"/>
      <xs:enumeration value="NotRunnable"/>
      <xs:enumeration value="NotExecuted"/>
      <xs:enumeration value="Disconnected"/>
      <xs:enumeration value="Warning"/>
      <xs:enumeration value="Passed"/>
      <xs:enumeration value="Completed"/>
      <xs:enumeration value="InProgress"/>
      <xs:enumeration value="Pending"/>
    </xs:restriction>
  </xs:simpleType>
 -->

&lt;details&gt;
    &lt;summary&gt;
<xsl:value-of select="$testOutcomeIcon" />
<xsl:text> </xsl:text>
<xsl:value-of select="@name" />
    &lt;/summary&gt;

| | |
|-|-|
| **ID:**            | `<xsl:value-of select="@id" />`
| **Name:**          | `<xsl:value-of select="@name" />`
| **Outcome:**       | `<xsl:value-of select="$testResult/@outcome" />` <xsl:value-of select="$testOutcomeIcon" />
| **Computer Name:** | `<xsl:value-of select="$testResult/@computerName" />`
| **Start:**         | `<xsl:value-of select="$testResult/@startTime" />`
| **End:**           | `<xsl:value-of select="$testResult/@endTime" />`
| **Duration:**      | `<xsl:value-of select="$testResult/@duration" />`

&lt;details&gt;
    &lt;summary&gt;Test Method Details:&lt;/summary&gt;

* Code Base:  `<xsl:value-of select="trx:TestMethod/@codeBase" />`
* Class Name: `<xsl:value-of select="trx:TestMethod/@className" />`
* Method Name:  `<xsl:value-of select="trx:TestMethod/@name" />`

&lt;/details&gt;


<xsl:if test="$testResult/@outcome = 'Failed'">

&lt;details&gt;
    &lt;summary&gt;Error Message:&lt;/summary&gt;

```text
<xsl:value-of select="$testResult/trx:Output/trx:ErrorInfo/trx:Message" />
```
&lt;/details&gt;

&lt;details&gt;
    &lt;summary&gt;Error Stack Trace:&lt;/summary&gt;

```text
<xsl:value-of select="$testResult/trx:Output/trx:ErrorInfo/trx:StackTrace" />
```
&lt;/details&gt;

<!--
      <Output>
        <ErrorInfo>
          <Message>Assert.AreNotEqual failed. Expected any value except:&lt;CN=foo.example.com&gt;. Actual:&lt;CN=foo.example.com&gt;. </Message>
          <StackTrace>   at PKISharp.SimplePKI.UnitTests.PkiCertificateSigningRequestTests.ExportImportCsr(PkiAsymmetricAlgorithm algor, Int32 bits, PkiEncodingFormat format) in C:\local\prj\bek\ACMESharp\ACMESharpCore\test\PKISharp.SimplePKI.UnitTests\PkiCertificateSigningRequestTests.cs:line 284&#xD;
</StackTrace>
        </ErrorInfo>
      </Output>
-->
</xsl:if>

-----

&lt;/details&gt;

    </xsl:template>

</xsl:stylesheet>
