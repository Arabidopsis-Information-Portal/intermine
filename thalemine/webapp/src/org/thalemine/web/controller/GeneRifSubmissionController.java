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
import org.intermine.model.InterMineObject;
import org.intermine.model.bio.Gene;
import org.thalemine.web.webservices.client.NCBIGeneIdLookup;
import org.thalemine.web.webservices.client.EntrezGene;
import org.intermine.api.InterMineAPI;
import org.intermine.model.InterMineObject;
import org.intermine.web.logic.results.ReportObject;

public class GeneRifSubmissionController extends TilesAction {

	protected static final Logger log = Logger.getLogger(GeneRifSubmissionController.class);

	private final static String GENE_RIF_SUMBISSION_BASEURL = "http://www.ncbi.nlm.nih.gov/gene/submit-generif/?geneId";
	private final static String GENE_RIF_CORRECTION_BASEURL = "http://www.ncbi.nlm.nih.gov/projects/RefSeq/update.cgi?geneid";

	private final static String SYMBOL_PARAM = "sym";
	private final static String ORGANISM_PARAM = "org";
	private final static String PUBMEDID_PARAM = "pubmedBuff";
	private final static String TEXT_PARAM = "textBuff";
	private final static String EMAIL_PARAM = "emailBuff";
	private final static String TASK_PARAM = "task";

	private final static String ORGANISM_VALUE = "Arabidopsis%20thaliana";
	private final static String PUBMEDID_VALUE = "My%20PubMedID";
	private final static String TEXT_VALUE = "My%20GeneRIF%20goes%20here";
	private final static String EMAIL_VALUE = "submitter@hostname.org";
	private final static String TASK_VALUE = "fixpub";

	private String primaryIdentifier;
	private String symbol;

	public ActionForward execute(ComponentContext context, ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response) throws Exception {

		Exception exception = null;

		log.info("GeneRifSubmissionController has started.");

		ReportObject reportObject = (ReportObject) request.getAttribute("object");
		String className = null;
		String primaryIdentifier = null;
		String symbol = null;
		Gene geneObject = null;
		String ncbiGeneId = null;
		String geneSubmissionURL = null;
		String geneCorrectionURL = null;
		EntrezGene entrezGene = null;

		try {
			if (reportObject == null) {
				throw new Exception("Report object cannot be null!");
			}

			className = reportObject.getClassDescriptor().getUnqualifiedName();

			log.info("Object type:" + className);

			if (StringUtils.isEmpty(className)) {
				throw new Exception("Object Type cannot be null!");
			}

			if (!(className.equals("Gene") || className.equals("Pseudogene") || className
					.equals("TransposableElementGene"))) {

				throw new Exception(
						"Object Type can be only Gene,Pseudogene, or TransposableElementGene. Current Object Type is: "
								+ className);
			}

			geneObject = (Gene) reportObject.getObject();

			if (geneObject == null) {

				throw new Exception("Gene object cannot be null. Report Object is: " + reportObject);
			}

			primaryIdentifier = geneObject.getPrimaryIdentifier();
			symbol = geneObject.getSymbol();

			NCBIGeneIdLookup webclient = new NCBIGeneIdLookup();
			entrezGene = webclient.getEntrezGeneByGeneId(primaryIdentifier);
			ncbiGeneId = entrezGene.getEntrezGeneId();

			geneSubmissionURL = createGeneRifSubmissionURL(ncbiGeneId, symbol);
			geneCorrectionURL = createGeneRifCorrectionURL(ncbiGeneId, symbol);

		} catch (Exception e) {
			exception = e;
		} finally {

			if (exception != null) {
				log.error("Gene RIF Submission: Error occurred;" + exception.getMessage());
			}

			log.info("GeneRifSubmission Object:" + reportObject);
			log.info("Gene Primary Identifier:" + primaryIdentifier);
			log.info("Gene Symbol:" + symbol);
			log.info("NCBI Gene Id:" + ncbiGeneId);
			log.info("Gene Rif Submission URL:" + geneSubmissionURL);
			log.info("Gene Rif Correction URL:" + geneCorrectionURL);

		}

		log.info("GeneRifSubmissionController has completed.");
		request.setAttribute("entrezGene", entrezGene);
		request.setAttribute("geneSubmissionURL", geneSubmissionURL);
		request.setAttribute("geneCorrectionURL", geneCorrectionURL);

		return mapping.findForward("links");

	}

	private String createGeneRifSubmissionURL(final String geneId, final String symbol) throws Exception {

		StringBuilder urlBuilder = new StringBuilder();

		if (StringUtils.isEmpty(geneId)) {
			new Exception("Gene Id cannot be null!");
		}

		urlBuilder.append(GENE_RIF_SUMBISSION_BASEURL);
		urlBuilder.append("=");
		urlBuilder.append(geneId);

		if (!StringUtils.isEmpty(symbol)) {

			urlBuilder.append("&");
			urlBuilder.append(SYMBOL_PARAM);
			urlBuilder.append("=");
			urlBuilder.append(symbol);

		}

		urlBuilder.append("&name=");

		urlBuilder.append("&");
		urlBuilder.append(ORGANISM_PARAM);
		urlBuilder.append("=");
		urlBuilder.append(ORGANISM_VALUE);

		urlBuilder.append("&");
		urlBuilder.append(PUBMEDID_PARAM);
		urlBuilder.append("=");
		urlBuilder.append(PUBMEDID_VALUE);

		urlBuilder.append("&");
		urlBuilder.append(TEXT_PARAM);
		urlBuilder.append("=");
		urlBuilder.append(TEXT_VALUE);

		urlBuilder.append("&");
		urlBuilder.append(EMAIL_PARAM);
		urlBuilder.append("=");
		urlBuilder.append(EMAIL_VALUE);

		return urlBuilder.toString();
	}

	private String createGeneRifCorrectionURL(final String geneId, final String symbol) throws Exception {

		StringBuilder urlBuilder = new StringBuilder();

		if (StringUtils.isEmpty(geneId)) {
			new Exception("Gene Id cannot be null!");
		}

		urlBuilder.append(GENE_RIF_CORRECTION_BASEURL);
		urlBuilder.append("=");
		urlBuilder.append(geneId);

		if (!StringUtils.isEmpty(symbol)) {

			urlBuilder.append("&");
			urlBuilder.append(SYMBOL_PARAM);
			urlBuilder.append("=");
			urlBuilder.append(symbol);

		}

		urlBuilder.append("&");
		urlBuilder.append(TASK_PARAM);
		urlBuilder.append("=");
		urlBuilder.append(TASK_VALUE);

		return urlBuilder.toString();
	}
}
