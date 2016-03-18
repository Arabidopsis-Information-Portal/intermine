package org.thalemine.web.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.tiles.ComponentContext;
import org.intermine.web.logic.results.ReportObject;
import org.thalemine.web.webservices.client.EntrezGene;
import org.apache.struts.tiles.actions.TilesAction;
import org.intermine.model.InterMineObject;
import org.intermine.model.bio.Gene;
import org.thalemine.web.webservices.client.GeneRIFSubmissionResponse;
import org.thalemine.web.webservices.client.NCBIGeneIdLookup;
import org.thalemine.web.webservices.client.EntrezGene;
import org.intermine.api.InterMineAPI;
import org.intermine.model.InterMineObject;
import org.intermine.web.logic.results.ReportObject;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.methods.PostMethod;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.zip.GZIPInputStream;

public class AraportGeneRifSubmissionController {

	protected static final Logger log = Logger.getLogger(AraportGeneRifSubmissionController.class);
	private final static String GENE_RIF_SUMBISSION_BASEURL = "http://www.ncbi.nlm.nih.gov/gene/submit-generif/";
	private static final String SITE = "gene";
	private static final String ENTREZ_GENERIF = "EntrezSystem2.PEntrez.Gene.Gene_SubmitGeneRIF:SubmitGeneRIF";
	private final static String PUBMEDID_PARAM = "pubmedBuff";
	private final static String TEXT_PARAM = "textBuff";
	private final static String EMAIL_PARAM = "emailBuff";

	private String primaryIdentifier;
	private String pubMedId;
	private String email;
	private String submissionText;

	public ActionForward execute(ComponentContext context, ActionMapping mapping, ActionForm form,
			HttpServletRequest request, HttpServletResponse response) throws Exception {

		Exception exception = null;

		log.info("Araport GeneRifSubmissionController has started.");

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

			primaryIdentifier = removeTrailingSpaces(geneObject.getPrimaryIdentifier());
			symbol = geneObject.getSymbol();

			if (!StringUtils.isEmpty(symbol)) {
				symbol = removeTrailingSpaces(geneObject.getSymbol());
			}

			NCBIGeneIdLookup webclient = new NCBIGeneIdLookup();
			entrezGene = webclient.getEntrezGeneByGeneId(primaryIdentifier);
			ncbiGeneId = removeTrailingSpaces(entrezGene.getEntrezGeneId());

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
		}

		log.info("Araport GeneRifSubmissionController has completed.");
		return null;

	}

	private String removeTrailingSpaces(final String identifier) throws Exception {

		if (StringUtils.isBlank(identifier)) {
			throw new Exception("Identifier cannot be empty!");
		}

		String result = StringUtils.trim(identifier);

		return identifier;
	}

	private boolean sendPostRequest(final String geneId, final String pubMedId, final String email,
			final String submissionText) {

		Exception exception = null;
		HttpClient client = new HttpClient();
		PostMethod method = new PostMethod(GENE_RIF_SUMBISSION_BASEURL);

		method.addRequestHeader("Accept-Encoding", "gzip, deflate");
		method.addRequestHeader("Accept-Language", "en-US,en;q=0.8");
		method.addRequestHeader("Content-type", "application/x-www-form-urlencoded");
		method.addRequestHeader("Accept", "*/*");

		method.addRequestHeader("Connection", "keep-alive");
		method.addRequestHeader("DNT", "1");
		method.addRequestHeader("NCBI-PHID", "CE894BCF6E1FAAA10000000000D50863.02");

		method.addParameter("p$site", "gene");
		method.addParameter("p$rq", "EntrezSystem2.PEntrez.Gene.Gene_SubmitGeneRIF:SubmitGeneRIF");
		method.addParameter("pubmedBuff", pubMedId);
		method.addParameter("textBuff", submissionText);
		method.addParameter("emailBuff", email);
		method.addParameter("geneId", geneId);

		try {

			int returnCode = client.executeMethod(method);

			log.info("POST Response Status:: " + returnCode);

			log.info("POST Response Sent:: " + method.isRequestSent());

			log.info("POST Response Aborted:: " + method.isAborted());

			if (returnCode == HttpStatus.SC_NOT_IMPLEMENTED) {
				log.error("The Post method is not implemented by this URI");
				// still consume the response body
				method.getResponseBodyAsString();
			} else {
				method.isRequestSent();
				InputStream in = method.getResponseBodyAsStream();
				InputStream zin = new GZIPInputStream(in);
				byte[] buffer = new byte[4096];
				int len = 0;
				String out = new String();
				while ((len = zin.read(buffer)) != -1) {
					out += new String(buffer, 0, len);
				}

				log.info("Gene RIF Successfully submitted:" + out);
				in.close();
			}
		} catch (Exception e) {
			exception = e;
		} finally {

			if (exception != null) {

				log.error("Gene RIF submission: Error occurred:" + exception.getMessage());
				exception.printStackTrace();

			}else{
				log.info("Gene RIF Successfully submitted");
			}
			method.releaseConnection();
		}

		log.info("GeneRIF: POST DONE.");

		return true;

	}
	
	private static GeneRIFSubmissionResponse parseResponse(String response) throws Exception, ParseException{
		String entrezGeneId = null;
		
		GeneRIFSubmissionResponse geneRifResponse = new GeneRIFSubmissionResponse();
		
		JSONParser parser = new JSONParser();
		Object obj = parser.parse(response);
		JSONObject jsonObj = (JSONObject) obj;
		
		if (jsonObj.containsKey("geneId")){
			geneRifResponse.setGeneId(String.valueOf(jsonObj.get("geneId")));
		}
				
		
		if (jsonObj.containsKey("emailBuff")){
			geneRifResponse.setEmail(String.valueOf(jsonObj.get("emailBuff")));
		}
		
		if (jsonObj.containsKey("textBuff")){
			geneRifResponse.setGeneId(String.valueOf(jsonObj.get("textBuff")));
		}
				
		if (jsonObj.containsKey("pubmedBuff")){
			geneRifResponse.setPubmedId(String.valueOf(jsonObj.get("pubmedBuff")));
		}
		
		if (jsonObj.containsKey("responseError")){
			geneRifResponse.setPubmedId(String.valueOf(jsonObj.get("responseError")));
		}
		
		if (jsonObj.containsKey("result")){
			geneRifResponse.setPubmedId(String.valueOf(jsonObj.get("result")));
		}
		
		return geneRifResponse;
	}

}
