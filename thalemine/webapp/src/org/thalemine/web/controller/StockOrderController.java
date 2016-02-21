package org.thalemine.web.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.net.URL.*;
import java.net.*;
import java.io.IOException.*;
import java.io.UnsupportedEncodingException;
import javax.servlet.http.Cookie;
import java.net.HttpCookie;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.CookiePolicy;
import java.net.CookieStore;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.tiles.ComponentContext;
import org.apache.struts.tiles.actions.TilesAction;

public class StockOrderController extends TilesAction {

	private final static String TAIR_URL_PREFIX = "https://ui.arabidopsis.org/#/contentaccess/login?partnerId=tair&redirect=https%3A%2F%2Fwww.arabidopsis.org%2Fservlets%2FTairObject%3Fid%3D";
	private final static String OBJECT_TYPE = "%26type%3Dgermplasm";

	protected static final Logger log = Logger.getLogger(StockOrderController.class);
	private String stockAccessionId;

	public ActionForward execute(ComponentContext context, ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response) throws Exception {

		Exception exception = null;

		log.info("StockOrderController has started.");

		String accessionId = request.getParameter("stockAccessionId");
		log.info("Accession Id:" + accessionId);

		Cookie[] cookies = null;
		cookies = request.getCookies();

		log.info("Cookies:");
		
		for (int i = 0; i < cookies.length; i++) {
			String name = cookies[i].getName();
			String value = cookies[i].getValue();
			String domain = cookies[i].getDomain();
			boolean secure = cookies[i].getSecure();
			int maxAge = cookies[i].getMaxAge();
			String path = cookies[i].getPath();

			log.info("Cookie Name:" + name + "; " + "Cookie Value: " + value + "; " + "Cookie Domain: " + domain + "; "
					+ "Cookie Secure: " + secure + "; " + "Cookie MaxAge: " + maxAge + "; " + "Cookie Path: " + path);

		}

		
		 	CookieManager cm = new CookieManager();
		    cm.setCookiePolicy(CookiePolicy.ACCEPT_ALL);
		    CookieHandler.setDefault(cm);

		    new URL("https://www.arabidopsis.org").openConnection().getContent();
		    CookieStore cookieStore = cm.getCookieStore();
		    
		    List<HttpCookie> cookiesH = cookieStore.getCookies();
		    for (HttpCookie cookie : cookiesH) {
		      log.info("Name = " + cookie.getName());
		      log.info("Value = " + cookie.getValue());
		      log.info("Lifetime (seconds) = " + cookie.getMaxAge());
		      log.info("Path = " + cookie.getPath());
		      log.info("Domain = " + cookie.getDomain());
		      log.info("Secure = " + cookie.getSecure());
		      log.info("Expired = " + cookie.hasExpired());
		    }
		    
		
		String url = null;
		if (!StringUtils.isBlank("accessionId")) {
			try {

				stockAccessionId = accessionId;
				log.info("Stock Accession Id:" + stockAccessionId);
				url = createURL(stockAccessionId);
				log.info("Stock URL:" + url);

			} catch (Exception e) {
				exception = e;
			} finally {
				if (exception != null) {
					log.error("Error occurred while setting up StockOrder Info" + "; Message: "
							+ exception.getMessage() + "; Cause: " + exception.getCause());
					exception.printStackTrace();

				} else {
					request.setAttribute("url", url);
					request.setAttribute("stockAccessionId", stockAccessionId);
					log.info("StockOrderController has completed.");
				}
			}
		} else {
			log.error("Stock Accession Id cannot be null!");
		}

		return null;
	}

	private String createURL(String id) throws MalformedURLException, URISyntaxException, UnsupportedEncodingException {

		String urlStr = TAIR_URL_PREFIX + id + OBJECT_TYPE;
		log.info("URL: " + urlStr);

		return urlStr;

	}
}
