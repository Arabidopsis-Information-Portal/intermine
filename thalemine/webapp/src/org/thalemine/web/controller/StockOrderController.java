package org.thalemine.web.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.net.URL.*;
import java.net.*;
import java.io.IOException.*;
import java.io.UnsupportedEncodingException;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.tiles.ComponentContext;
import org.apache.struts.tiles.actions.TilesAction;
import org.thalemine.web.domain.datacategory.DataSummaryVO;
import org.thalemine.web.metadata.DataSummaryService;

public class StockOrderController extends TilesAction {

	private final static String TAIR_URL_PREFIX = "https://ui.arabidopsis.org/#/contentaccess/login?partnerId=tair&redirect=https%3A%2F%2Fwww.arabidopsis.org%2Fservlets%2FTairObject%3Fid%3D";
	private final static String OBJECT_TYPE = "germplasm";

	protected static final Logger log = Logger.getLogger(StockOrderController.class);
	private String stockAccessionId;

	public ActionForward execute(ComponentContext context, ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response) throws Exception {

		Exception exception = null;

		log.info("StockOrderController has started.");
		this.stockAccessionId = "6530293244";

		String accessionId = request.getParameter("stockAccessionId");
		log.info("Accession Id:" + accessionId );
				
				
		String url = null;
		if (!StringUtils.isBlank("accessionId")) {
			try {
				
				stockAccessionId = accessionId;
				log.info("Stock Accession Id:" + stockAccessionId);
				url= createURL(stockAccessionId);
				log.info("Stock URL:" + url);
				
				} catch (Exception e) {
				exception = e;
			} finally {
				if (exception != null) {
					log.error("Error occurred while seeting up StockOrder Info" + "; Message: "
							+ exception.getMessage() + "; Cause: " + exception.getCause());
					exception.printStackTrace();

				} else {
					request.setAttribute("url", url);
					request.setAttribute("stockAccessionId", stockAccessionId);
					log.info("StockOrderController has completed.");
				}
			}
		}

		return null;
	}

	private String createURL(String id) throws MalformedURLException, URISyntaxException, UnsupportedEncodingException {
		
		String urlStr = TAIR_URL_PREFIX + id  + "%26type%3Dgermplasm";
		log.info("URL: " + urlStr);

		return urlStr;

	}
}
