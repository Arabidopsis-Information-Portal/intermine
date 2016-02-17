<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im"%>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles"%>

<!-- stockAccessionDisplayer.jsp -->

<script>
function OrderStocks(stockurl) {
	var myWindow = window.open(stockurl, "Order Stocks from ABRC", "width=900,height=800", "");
}
</script>

<script>
function test(var1) {
    alert(var1);
}
</script>

<div id="stock-availability_displayer" class="collection-table">

<style>
		.button {
	-moz-box-shadow: 3px 4px 0px 0px #899599;
	-webkit-box-shadow: 3px 4px 0px 0px #899599;
	box-shadow: 3px 4px 0px 0px #899599;
	background:-webkit-gradient(linear, left top, left bottom, color-stop(0.05, #ededed), color-stop(1, #bab1ba));
	background:-moz-linear-gradient(top, #ededed 5%, #bab1ba 100%);
	background:-webkit-linear-gradient(top, #ededed 5%, #bab1ba 100%);
	background:-o-linear-gradient(top, #ededed 5%, #bab1ba 100%);
	background:-ms-linear-gradient(top, #ededed 5%, #bab1ba 100%);
	background:linear-gradient(to bottom, #ededed 5%, #bab1ba 100%);
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ededed', endColorstr='#bab1ba',GradientType=0);
	background-color:#ededed;
	-moz-border-radius:15px;
	-webkit-border-radius:15px;
	border-radius:15px;
	border:1px solid #d6bcd6;
	display:inline-block;
	cursor:pointer;
	color:#3a8a9e;
	font-family:Arial;
	font-size:14px;
	padding:7px 25px;
	width:250px;
	text-decoration:none;
	text-shadow:0px 1px 0px #e1e2ed;
}
.button:hover {
	background:-webkit-gradient(linear, left top, left bottom, color-stop(0.05, #bab1ba), color-stop(1, #ededed));
	background:-moz-linear-gradient(top, #bab1ba 5%, #ededed 100%);
	background:-webkit-linear-gradient(top, #bab1ba 5%, #ededed 100%);
	background:-o-linear-gradient(top, #bab1ba 5%, #ededed 100%);
	background:-ms-linear-gradient(top, #bab1ba 5%, #ededed 100%);
	background:linear-gradient(to bottom, #bab1ba 5%, #ededed 100%);
	filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#bab1ba', endColorstr='#ededed',GradientType=0);
	background-color:#bab1ba;
}

.button:active {
	position:relative;
	top:1px;
}

a.button:link {
    color:#3a8a9e;
    text-decoration:none;
}

/* visited link */
a.button:visited {
    color:#3a8a9e;
    text-decoration:none;
}

/* mouse over link */
a.button:hover {
    color:#3a8a9e;
    text-decoration:none;
}

/* selected link */
a.button:active {
  color:#3a8a9e;
  text-decoration:none;
}

</style>


<c:choose>
		<c:when test="${!empty result}">
		
		<div class="header">
		
		<h3>			
			Stock Availability
		</h3>
		
		</div>

			<div>

				<table>
					<thead>
						<tr>
								<th>Available At ?</th>
						</tr>
					</thead>
					<tbody>
     				 	<c:forEach var="item" items="${result}">	
     				 	<tr>
     				 	
     				 		<td>			
     				 		
     				 		<c:if test = "${item.stockCenter eq 'ABRC'}">
  								<a class="button" href="${item.externalStockObjectUrlPrefix}${item.stockNumber}&type=germplasm">Order from ABRC</a>
  								
  								<c:set var="stockurl" scope="request" value="stockOrder.do?stockAccessionId=${item.stockNumber}"/>
  															
  								<a class="button" href="#" onclick="OrderStocks('${stockurl}');return false;">Order ABRC Stocks/Login to TAIR</a>
  						 								  								  							
							</c:if>
							<c:if test = "${item.stockCenter eq 'NASC'}">
  								<a class="button" href="${item.externalStockObjectUrlPrefix}${item.stockNumber}">Order from NASC</a>
							</c:if>
	
     				 		</td>
  
     				 	</tr>
     				  	</c:forEach>
   					 </tbody>
				</table>
			</div>

		</c:when>
		<c:otherwise>
    			No stock available in ABRC/NASC. Please, consult with the external reference.
    			
    			<c:if test = "${!empty externalURL}">
    				<a href="${externalURL}" style="color:#2A65D2">
    				
    				<c:choose>
						<c:when test="${!empty objectName}">
    						${objectName} in ABRC/TAIR
    				</c:when>
    				<c:otherwise>
    						ABRC/TAIR
    				</c:otherwise>
    				</c:choose>
    				
    				</a>
				</c:if>
    			
  		</c:otherwise>

	</c:choose>
	
</div>

<!-- /stockAccessionDisplayer.jsp -->
