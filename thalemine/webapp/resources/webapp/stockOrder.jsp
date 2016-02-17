<!doctype html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im"%>


<!-- stockOrder -->
<html:xhtml />
<style>
/* stock ordering styles*/
.stock_order{
font-family:Arial, Helvetica, sans-serif; 
font-size:13px;	
}

.logo {
    padding-top: 5px;
    padding-right: 5x;
    padding-bottom: 0px;
    padding-left: 5px;
    display: block;
    border: none;
}

/* information messages*/
.info {
border: 1px solid;
margin: 3px 0px;
padding:15px 10px 15px 50px;
background-repeat: no-repeat;
background-position: 10px center;
color: #608BD8;
background-color: #F4F7FC;
border-style: solid;
border-color: #608BD8;
border-left-width: 20px;
border-top-width: 2px;
border-bottom-width: 2px;
border-right-width: 2px;
box-sizing: border-box;
line-height: 20px;
font-size: 13px;
margin-bottom: 20px;
padding-bottom: 15px;
padding-left: 15px;
padding-right: 15px;
padding-top: 15px;
display: block;
}

</style>

<div class="stock_order">

<img class="logo" align="top"
		src="model/images/logo.png">

<div id="explanation" class="info">This window will help you order stocks. Your
	Arabidopsis stock orders will be fulfilled by ABRC. Your order will be
	taken and processed by TAIR. To use this order system, you will need to
	log in with a TAIR account that has been approved by TAIR for stock
	ordering. TAIR takes orders as a free service without requiring a
	subscription. Your TAIR account is not linked to your Araport account
	in any way.
</div>

<div id="tair_order_stock">
<iframe
		src="${url}"
		name="Order Stocks" 
		scrolling="auto" frameborder="yes" align="center" 
		height="1000px" width="800px"
		>
</iframe>
</div>

</div>
<!-- /stockOrder -->
