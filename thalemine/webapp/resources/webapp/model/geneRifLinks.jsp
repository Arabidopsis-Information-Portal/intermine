<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im" %>
<%@ taglib uri="/WEB-INF/functions.tld" prefix="imf" %>

<link rel="stylesheet" href="http://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.4.0/css/font-awesome.min.css">

<tiles:importAttribute/>
<html:xhtml/>

<tiles:importAttribute name="object" />

<style>

.box{
display: block;
margin:5px;
}

.submitlinks{
font-weight: bold;
font-size: 14px;
}

</style>

<!-- geneRifLinks.jsp -->

<div class="box" id="gene-rif-links">

<c:choose>
		<c:when test="${!empty geneSubmissionURL}">
			<span class="submitlinks">
			Submit:	<a href="${geneSubmissionURL}" target="_blank">New GeneRIF <i class="fa fa-external-link"></i></a>&nbsp;&nbsp;
				    <a href="${geneCorrectionURL}" target="_blank">Correction <i class="fa fa-external-link"></i></a>
			</span>
		</c:when>
	    <c:otherwise>
	    </c:otherwise>
</c:choose>
</div>
<!-- /geneRifLinks.jsp -->