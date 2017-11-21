<!doctype html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im"%>
<%@ taglib uri="/WEB-INF/imutil.tld" prefix="imutil" %>
<%@ taglib uri="/WEB-INF/functions.tld" prefix="imf" %>
<% pageContext.setAttribute("newLineChar", "\n"); %>


<!-- report.jsp -->
<html:xhtml/>

<script type="text/javascript">
  <%-- apply white background as report page loads slowly and body bg will show through --%>
  var pageBackgroundColor = jQuery('body').css('background-color');
  jQuery('body').css('background-color', '#FFF');

  <%--  Expose useful properties to the js. The properties themselves are
        set in the foreach later down the page --%>
  var imSummaryFields = {
    type : "${object.type}"
  };

</script>

<c:choose>
  <c:when test="${object != null}">

<script type="text/javascript">
  <%-- the number of entries to show in References & Collections before switching to "show all" --%>
  var numberOfTableRowsToShow = '${object.numberOfTableRowsToShow}'; <%-- required on report.js --%>
  numberOfTableRowsToShow = (numberOfTableRowsToShow == '') ? 30 : parseInt(numberOfTableRowsToShow);
</script>

<link rel="stylesheet" type="text/css" href="css/960gs.css" />
<link rel="stylesheet" type="text/css" href="css/report.print.css" media="print" />

<div id="header_wrap">

  <div id="object_header">
    <c:if test="${object.headerLink != null}">
        <c:set var="headerLink" value="${object.headerLink}"/>
        <div id="headerLink">
            <a href="${headerLink.url}" target="new">
              <c:choose>
                <c:when test="${headerLink.text != null || headerLink.image != null}">
                  <c:if test="${headerLink.image != null}">
                      <img src="model/images/${headerLink.image}" />
                  </c:if>
                  <c:if test="${headerLink.text != null}">
                      ${headerLink.text}
                  </c:if>
                </c:when>
                <c:otherwise>
                  ${headerLink.url}
                </c:otherwise>
              </c:choose>
            </a>
        </div>
    </c:if>
    <a name="summary">
    <h1 class="title">
        <im:displaypath path="${object.type}"/>:
        <c:forEach var="title" varStatus="status" items="${object.titleMain}">
          <c:if test="${status.count > 0}"> </c:if><strong><c:out escapeXml="false" value="${title.value.formatted}" /></strong>
        </c:forEach>
        <c:forEach var="title" varStatus="status" items="${object.titleSub}">
          <c:if test="${status.count > 0}"> </c:if><c:out escapeXml="false" value="${title.value.formatted}" />
        </c:forEach>
    </h1>
    </a>

    <%-- summary short fields --%>
    <table class="fields">
      <c:set var="tableCount" value="0" scope="page" />
      <c:set var="tableInc" value="1" scope="page" />
<c:if test="${object.type eq 'Gene' || object.type eq 'MRNA'}" >
<%-- to have a display in 2 columns (instead of 4) for the 2 types --%>
      <c:set var="tableInc" value="2" scope="page" />
</c:if>


      <c:forEach var="field" items="${object.objectSummaryFields}">
        <%-- Expose useful props to the js --%>
        <%-- <script>alert("TEST");</script> --%>
        <%-- <script> imSummaryFields["${field.name}"] = "${field.value}";</script> --%>
        <script> imSummaryFields["${field.name}"] = "${fn:replace(field.value, newLineChar, "; ")}";</script>


        <c:if test="${field.showInHeader ne false}">
          <c:if test="${tableCount %2 == 0}">
            <c:choose>
              <c:when test="${tableCount == 0}">
                <tr>
              </c:when>
              <c:otherwise>
                </tr><tr>
              </c:otherwise>
            </c:choose>
          </c:if>

          <c:set var="fieldDisplayText"
            value="${imf:formatFieldChain(field.pathString, INTERMINE_API, WEBCONFIG)}"/>
          <c:choose>
            <c:when test="${field.valueHasDisplayer}">
              <!-- Short summary fields with displayer: change field description to bold, text to normal -->
              <td class="label"><strong>
                  ${fieldDisplayText}&nbsp;
                  <im:typehelp type="${field.pathString}"/>
              </strong></td>
              <td style="vertical-align: top">
                <!-- pass value to displayer -->
                <c:set var="interMineObject" value="${object.object}" scope="request"/>
                  <tiles:insert page="${field.displayerPage}">
                    <tiles:put name="expr" value="${field.name}" />
                  </tiles:insert>
              </td>
              <c:set var="tableCount" value="${tableCount+1}" scope="page" />
            </c:when>
            <c:otherwise>
              <c:if test="${!field.doNotTruncate && !empty field.value}">
              <!-- Short summary fields: change field description to bold, text to normal -->
                <td class="label"><strong>${fieldDisplayText}&nbsp;<im:typehelp type="${field.pathString}"/></strong></td>

                <c:choose>
                <c:when test="${fn:trim(fieldDisplayText) == 'Computational Description' && fn:contains(field.value,'; Has ')}" >
                  <td style="vertical-align: top">${fn:substringBefore(field.value, '; Has ')}.&nbsp; ${WEB_PROPERTIES['tair.attribution']}</td>
                </tr><tr>
                </c:when>
                <c:when test="${fn:trim(fieldDisplayText) == 'Computational Description' && !fn:contains(field.value,'; Has ')}" >
                  <td style="vertical-align: top">${field.value}&nbsp; ${WEB_PROPERTIES['tair.attribution']}</td>
                </tr><tr>
                </c:when>
                <c:when test="${fn:trim(fieldDisplayText) == 'Curator Summary' }" >
                  <td style="vertical-align: top">${field.value}&nbsp; ${WEB_PROPERTIES['tair.attribution']}</tr>
                </c:when>
                <c:when test="${fn:trim(fieldDisplayText) == 'Brief Description' }" >
                  <td style="vertical-align: top">${field.value}&nbsp; ${WEB_PROPERTIES['araport.attribution']}</tr>
                </c:when>
                <c:otherwise>
                  <td style="vertical-align: top"><c:out escapeXml="${field.escapeXml}" value="${field.value}" /></td>
                </c:otherwise>
                </c:choose>

                <c:set var="tableCount" value="${tableCount+tableInc}" scope="page" />
              </c:if>
            </c:otherwise>
          </c:choose>
          </c:if>
      </c:forEach>
    </table>

    <%-- summary long fields --%>
    <table>
      <c:forEach var="field" items="${object.objectSummaryFields}">
        <c:if test="${field.doNotTruncate}">
          <tr>
            <c:if test="${!empty field.value}">
              <!-- Long summary fields: change field description to bold, text to normal -->
              <td class="label"><strong>${field.name}&nbsp;<im:typehelp type="${field.pathString}"/></strong></td>
              <td style="vertical-align: top"><c:out escapeXml="${field.escapeXml}" value="${field.value}" /></td>
            </c:if>
          </tr>
        </c:if>
      </c:forEach>
    </table>

    <%-- header Inline Lists --%>
    <c:if test="${object.hasHeaderInlineLists}">
      <tiles:insert page="/reportHeaderInlineLists.jsp">
        <tiles:put name="object" beanName="object" />
      </tiles:insert>
    </c:if>

  <%-- shown @ top displayers --%>
  <div class="displayers">
    <tiles:insert page="/reportDisplayers.jsp">
      <tiles:put name="placement" value="top" />
      <tiles:put name="reportObject" beanName="object" />
    </tiles:insert>
  </div>

    <%-- permalink --%>
    <%-- <p class="share">Share this page: <a href="${stableLink}">${stableLink}</a></p> --%>
    <div id="share">
      <a></a>
      <div class="popup">
        <span class="close"></span>
        Paste the following link
        <input type="text" value="${stableLink}">
      </div>
      <script type="text/javascript">
        //<![CDATA[
        jQuery('#object_header #share a').click(function() {
          // show
          jQuery("#object_header #share div.popup").show();
          // select
          jQuery("#object_header #share div.popup").find('input').select();
        });
        jQuery('#object_header #share div.popup span.close').click(function() {
          // hide
          jQuery("#object_header #share div.popup").hide();
        });
        //]]>
      </script>
  </div>

  </div>
</div>

<div id="content">

<c:if test="${categories != null}">
  <div id="menu-target">&nbsp;</div>
  <div id="toc-menu-wrap">
    <tiles:insert name="reportMenu.jsp">
      <tiles:put name="summary" value="current" />
    </tiles:insert>
  </div>
  <div id="fixed-menu">
    <tiles:insert name="reportMenu.jsp" />
  </div>
  <script type="text/javascript">
    //<![CDATA[
    (function() {
      jQuery('#fixed-menu').hide(); // hide for IE7
      jQuery(window).scroll(function() {
        // transition fix
        if (jQuery('#menu-target').isInView('partial')) {
          jQuery('#fixed-menu').hide();
        } else {
          jQuery('#fixed-menu').show();
        }
        // where are we
        var currentAspect = null;
        var currentAspectDistance = 9999;

        // distance from top (screen)
        var screenTop = jQuery(window).scrollTop();
        // distance from bottom (screen)
        var screenBottom = screenTop + jQuery(window).height();
        // center of the screen
        var screenMiddle = ((screenBottom - screenTop) / 2) + screenTop;

        // traverse aspect blocks
        jQuery('div.aspectBlock').each(function(i) {
          // is this aspect in view?
          if (jQuery(this).isInView('partial')) {
              // top & bottom distance for the element, increase the top one as divs align
              var elementTop = jQuery(this).offset().top + 1;
              var elementBottom = elementTop + jQuery(this).height() - 1;

              // absolute distance from the middle of the screen is...
              var elementTopDistance = Math.abs(elementTop - screenMiddle);
              var elementBottomDistance = Math.abs(elementBottom - screenMiddle);

              // save the one that is closer to the middle
              if (elementTopDistance < currentAspectDistance) {
                currentAspectDistance = elementTopDistance;
                currentAspect = jQuery(this).attr('id');
              }
              if (elementBottomDistance < currentAspectDistance) {
                currentAspectDistance = elementBottomDistance;
                currentAspect = jQuery(this).attr('id');
              }
          }
        });

        if (currentAspect != null) {
          // strip the 'Category' suffix
          currentAspect = currentAspect.substring(0, currentAspect.length - 8);
          // find the one link in the top menu that corresponds to where we are
          jQuery('#fixed-menu div.links a').each(function(i) {
              if (jQuery(this).text() == currentAspect) {
                  jQuery(this).addClass('current');
              } else {
                  jQuery(this).removeClass('current');
              }
          });
        }

      });

      if (jQuery(window).width() < '900') {
        jQuery('div.wrap').each(function(index) {
            jQuery(this).addClass('smallscreen');
        });
      }
    })();
  //]]>
  </script>
</c:if>

<div class="container_12">

 <c:set value="${fn:length(CATEGORIES)}" var="aspectCount" /> <c:set
  var="templateIdPrefix" value="reportTemplate${objectType}" /> <c:set
  var="miscId" value="reportMisc${objectType}" /> <%-- All other references and collections --%>

<script type="text/javascript">
  //<![CDATA[
    var modifyDetailsURL = '<html:rewrite action="/modifyDetails"/>';
    var detailsType = 'object';
  //]]>-->
</script>
<script type="text/javascript" src="js/inlinetemplate.js"></script>
<div class="grid_10">

  <div id="summaryCategory" class="aspectBlock">
   <tiles:insert page="/reportDisplayers.jsp">
      <tiles:put name="placement" value="summary" />
    <tiles:put name="reportObject" beanName="object" />
     </tiles:insert>

   <tiles:insert name="templateList.tile">
    <tiles:put name="scope" value="global" />
    <tiles:put name="placement" value="im:aspect:summary" />
    <tiles:put name="reportObject" beanName="object" />
  </tiles:insert>

    <tiles:insert page="/reportRefsCols.jsp">
      <tiles:put name="object" beanName="object" />
      <tiles:put name="placement" value="im:summary" />
    </tiles:insert>

  </div>

  <c:forEach items="${categories}" var="aspect" varStatus="status">
    <div id="${fn:replace(aspect, " ", "_")}Category" class="aspectBlock">
      <tiles:insert name="reportAspect.tile">
        <tiles:put name="mapOfInlineLists" beanName="mapOfInlineLists" />
        <tiles:put name="placement" value="im:aspect:${aspect}" />
        <tiles:put name="reportObject" beanName="object" />
        <tiles:put name="trail" value="${request.trail}" />
        <tiles:put name="aspectId" value="${templateIdPrefix}${status.index}" />
       <tiles:put name="opened" value="${status.index == 0}" />
      </tiles:insert>

<!-- /ATTED data -->

      <c:if test="${aspect eq 'Expression' && object.type == 'Gene'}">

<!-- co-regulation header -->
<div id="atted-section" class="collection-table column-border" style="margin-bottom: 0px">

    <div class="header">
      <h3>Co-expression</h3>
<!--       <p>Data source: <a href="http://atted.jp/">ATTED-II</a></p> -->
    </div>

</div>

<%-- TODO JCVI: Change the link here to your displayer --%>
<script charset="utf-8" type="text/javascript" src="${WEB_PROPERTIES['head.cdn.location']}/js/atted-displayer/1.2.0/build/atted-displayer-1.2.0.min.js"></script>

<%-- Comment this out because it changes the formatting of the whole report page relative to the rest of the site --%>
<%--<link rel="stylesheet" type="text/css" href="${WEB_PROPERTIES['head.cdn.location']}/css/bootstrap/2.3.2/css/bootstrap.min.css">--%>

<c:set var="AGI" value="${fn:substringAfter(stableLink, 'externalids=')}" />

<div id="atted_displayercontainer"></div>
   <script type="text/javascript">
      var id = "${AGI}";
      var webapp_url = "${WEB_PROPERTIES['webapp.baseurl']}/${WEB_PROPERTIES['webapp.path']}";
      var attedcallback = function(values) {

      var options = {
             type: 'table',
             url: webapp_url,
             token: $SERVICE.token,
             query: {"model":{"name":"genomic"},"select":["Gene.primaryIdentifier","Gene.symbol","Gene.curatorSummary"],"orderBy":[{"Gene.primaryIdentifier":"ASC"}],"where":[{"path":"Gene.primaryIdentifier","op":"ONE OF","code":"A","values":values}]}
          };
      if (values == null || values.length < 1) {
        jQuery('#query-container').html("");
        jQuery('#attedexport').hide();
      } else {
        jQuery('#attedexport').show();
        //jQuery('#query-container').imWidget(options);

        imtables.loadDash('#query-container',
                {start : 0, size : 25},
                {service: $SERVICE, query : options.query}
                ).then(
                    withTable,
                    FailureNotification.notify
                );
          function withTable(table) {
                    table.bus.on('list-action:failure', LIST_EVENTS['list-creation:failure']);
                    table.bus.on('list-action:success', LIST_EVENTS['list-creation:success']);
                }
      }

         }

      var attedqueryhook = function() {
          jQuery('#query-container').html("Waiting for results...");
      }

      var opts = {
            target: '#atted_displayercontainer',
            AGIcode: id,
            method: 'mr',
            cutoff: 20,
            guarantee: 10,
            service: webapp_url + "/service",
            atted: "${WEB_PROPERTIES['atted.url.prefix']}",
            accessToken: "${WEB_PROPERTIES['araport.accessToken']}"
            }


      var displayer = new AttedDisplayer(opts,attedcallback,attedqueryhook);
</script>

<%-- toggle --%>
<script type="text/javascript" charset="utf-8">

jQuery(document).ready(function () {
 jQuery(".tbox").children('doopen').show();
 jQuery(".tbox").children('doclose').hide();

  jQuery('.tbox').click(function () {
  var text = jQuery(this).children('doclose');

  if (text.is(':hidden')) {
       jQuery(this).children('doclose').show("slow");
     } else {
         jQuery(this).children('doopen').show("slow");
      }
   });

  jQuery("doopen").click(function(){
     jQuery(this).toggle("slow");
     return true;
    });

  jQuery("doclose").click(function(){
      jQuery(this).toggle("slow");
        return true;
    });
  });

</script>


<html:link linkName="#" styleId="sis" style="cursor:pointer">
    <h3 id="attedexport">
        Save / Export
        <img src="images/undisclosed.gif" id="co">
    </h3>

</html:link>



<script type="text/javascript" charset="utf-8">
    jQuery(document).ready(function () {
        jQuery("#sis").click(function () {
           if(jQuery("#protocols").is(":hidden")) {
             jQuery("#co").attr("src", "images/disclosed.gif");
           } else {
             jQuery("#co").attr("src", "images/undisclosed.gif");
           }
           jQuery("#protocols").toggle("slow");
        });
    })
</script>

<div id="protocols" style="display: none">
<link rel="stylesheet" type="text/css" href="${WEB_PROPERTIES['head.cdn.location']}/js/intermine/im-tables/latest/imtables.css">
<!-- A place holder element in your page to hold the table -->
<div id="query-container">
 <p class="apology">
  Please be patient while the results of your query are retrieved.
 </p>
</div>
</div>

<p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p>

</c:if>

<!-- /ATTED data -->


<!-- PROTEIN DOMAIN data -->

<c:if test="${aspect eq 'Proteins' && object.type == 'Protein'}">
<div id="domainregion" class="collection-table column-border" style="margin-bottom: 0px"></div>
  <c:set var="QUERYID" value="${fn:substringAfter(stableLink, 'externalids=')}" />
  <c:set var="MINEURL" value="${WEB_PROPERTIES['webapp.baseurl']}/${WEB_PROPERTIES['webapp.path']}" />

<svg id="mychart" class="pdchart" style="width: 100%;"></svg>

<script type="text/javascript" charset="utf-8">
var queryId="${QUERYID}";
var mineUrl="${MINEURL}/";
</script>

<script type="text/javascript" charset="utf-8" src="${WEB_PROPERTIES['head.cdn.location']}/js/d3/3.5.5/d3.min.js"></script>
<link rel="stylesheet" type="text/css" href="${WEB_PROPERTIES['head.cdn.location']}/js/intermine/protein-domain/1.2.0/protein-domain.css">
<script type="text/javascript" charset="utf-8" src="${WEB_PROPERTIES['head.cdn.location']}/js/intermine/protein-domain/1.2.0/protein-domain.js"></script>

</c:if>

<!--  /PROTEIN DOMAIN REGIONS -->

<!-- RNASEQ EXPRESSION -->

<c:set var="TYPE" value="none" />

<c:if test="${fn:contains(object.type, 'RNA') || fn:contains(object.type, 'Transcript')}">
<c:set var="TYPE" value="Transcript" />
</c:if>
<c:if test="${object.type == 'Gene' || object.type == 'Pseudogene' || object.type == 'TransposableElementGene'}">
<c:set var="TYPE" value="Gene" />
</c:if>


<c:if test="${aspect eq 'Expression' && (TYPE eq 'Gene' || TYPE eq 'Transcript')}">
<div id="domainregion" class="collection-table column-border" style="margin-bottom: 0px"></div>
  <c:set var="QUERYID" value="${fn:substringAfter(stableLink, 'externalids=')}" />
  <c:set var="MINEURL" value="${WEB_PROPERTIES['webapp.baseurl']}/${WEB_PROPERTIES['webapp.path']}" />

<svg id="eChart" class="eChart" style="width: 100%;"></svg>

<script type="text/javascript" charset="utf-8">
var queryId="${QUERYID}";
var mineUrl="${MINEURL}/";
var svgId="eChart";
var token="${token}"; // not needed for report, but for temporary lists
var type="${TYPE}";   // the root for the ws query
</script>

<script type="text/javascript" charset="utf-8" src="${WEB_PROPERTIES['head.cdn.location']}/js/d3/3.5.5/d3.min.js"></script>
<script type="text/javascript" charset="utf-8" src="${WEB_PROPERTIES['head.cdn.location']}/js/d3-legend/1.8.0/d3-legend.min.js"></script>
<link rel="stylesheet" type="text/css" href="${WEB_PROPERTIES['head.cdn.location']}/js/intermine/expression/1.0.2/expression.css">
<script type="text/javascript" charset="utf-8" src="${WEB_PROPERTIES['head.cdn.location']}/js/intermine/expression/1.0.2/expression.min.js"></script>
<br>
</c:if>
<br>
<!--  /RNASEQ EXPRESSION -->



  </div>

  </c:forEach>

  <div id="OtherCategory" class="aspectBlock">
    <c:if test="${categories != null}">
      <c:if test="${fn:length(placementRefsAndCollections['im:aspect:Miscellaneous']) > 0 || fn:length(listOfUnplacedInlineLists) > 0}">
        <div class="clear">&nbsp;</div>
        <a name="other"><h2>Other</h2></a>
      </c:if>
    </c:if>

    <tiles:insert page="/reportUnplacedInlineLists.jsp">
      <tiles:put name="listOfUnplacedInlineLists" beanName="listOfUnplacedInlineLists" />
    </tiles:insert>

    <tiles:insert page="/reportRefsCols.jsp">
      <tiles:put name="object" beanName="object" />
      <tiles:put name="placement" value="im:aspect:Miscellaneous" />
    </tiles:insert>
  </div>
</div>

<div style="float:right;" class="grid_2 sidebar">
  <div id="in-lists">
    <tiles:insert name="reportInList.tile">
      <tiles:put name="object" beanName="object"/>
    </tiles:insert>
  </div>

  <c:set var="getFriendly" value="no"></c:set>
  <c:if test="${fn:endsWith(fn:toLowerCase(object.type), 'gene')}">
     <c:set var="getFriendly" value="yes"></c:set>
  </c:if>
  <c:set var="object_bk" value="${object}"/>
  <c:set var="object" value="${reportObject.object}" scope="request"/>
  <div id="external-links">
  <c:if test="${getFriendly == 'yes'}">
    <tiles:insert name="otherMinesLink.tile" />
  </c:if>
    <tiles:insert name="attributeLinks.tile" >
    <tiles:put name="reportObject" beanName="object" />
  </tiles:insert>
  </div>
  <c:set var="object" value="${object_bk}"/>

  <%-- shown in a sidebar displayers --%>
  <div id="displayers" class="table">
    <tiles:insert page="/reportDisplayers.jsp">
      <tiles:put name="placement" value="sidebar" />
      <tiles:put name="reportObject" beanName="object" />
    </tiles:insert>
  </div>
</div>
</div>
</div>

  </c:when>
  <c:otherwise>
    <script type="text/javascript">
        <%-- fudge the layout I can? --%>
        jQuery("#pagecontentmax").attr('id', "pagecontent");
    </script>
    <div id="wrap">
      <h1>Object not found</h1>
      <p>That which you were looking for does not exist. Try...
        <ol>
          <li>going to the <a href="/thalemine">home page</a></li>
          <li>using the quicksearch</li>
          <li>or <a href="#" onclick="showContactForm()">Contact us</a> at support [at] araport@jcvi.org </li>
        </ol>
      </p>
    </div>
  </c:otherwise>
</c:choose>

<script type="text/javascript">
  jQuery('body').css('background-color', pageBackgroundColor);
</script>
