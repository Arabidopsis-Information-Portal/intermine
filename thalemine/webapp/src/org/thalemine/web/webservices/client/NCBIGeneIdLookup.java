package org.thalemine.web.webservices.client;

import java.io.IOException;

import org.apache.commons.httpclient.DefaultHttpMethodRetryHandler;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.params.HttpMethodParams;
import org.apache.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.thalemine.web.controller.GeneRifSubmissionController;
import org.thalemine.web.database.DBConnectionManager;

public class NCBIGeneIdLookup {

	private static final Logger log = Logger.getLogger(NCBIGeneIdLookup.class);
	
	private static final String GET_URL = "http://mygene.info/v2/query";
	private static final String QUERY_PARAM = "q";
	private static final String GENE_SEARCH_PREFIX = "tair:";
	private static final String SPECIES_PARAM = "species";
	private static final String SPECIES = "thale-cress";

	private static final String MIME_TYPE = "application/json";
	private static final String ACCEPT = "accept";

	private final static EntrezGene entrezGene = new EntrezGene();
	
	
	private static String processRequest(String primaryIdentifier) {

		String entrezGeneId = null;
		Exception exception = null;
		
		HttpClient client = new HttpClient();
		HttpMethod method = new GetMethod(GET_URL);

		method.getParams().setParameter(HttpMethodParams.RETRY_HANDLER, new DefaultHttpMethodRetryHandler(10, false));
		method.addRequestHeader(ACCEPT, MIME_TYPE);
		
		final NameValuePair[] queryString = getQueryString(primaryIdentifier);
		method.setQueryString(queryString);
		
		
		try {
			// Execute the method.
			int statusCode = client.executeMethod(method);

			if (statusCode != HttpStatus.SC_OK) {
				log.error("Method failed: " + method.getStatusLine());
			}

			String response = method.getResponseBodyAsString();
			entrezGeneId = parseResponse(response);

		} catch (HttpException e) {
			exception = e;
			log.error("Fatal protocol violation: " + e.getMessage());
			e.printStackTrace();
		} catch (IOException e) {
			exception = e;
			log.error("Fatal transport error: " + e.getMessage());
			e.printStackTrace();
		} catch (ParseException e) {
			exception = e;
			e.printStackTrace();
		} catch (Exception e) {
			exception = e;
			e.printStackTrace();
		} finally {
			
			if (exception!=null){
				log.error("Error occurred while retrieving NCBI entrez gene ID " + exception.getMessage());
			}
			method.releaseConnection();
		}
		
		return entrezGeneId;
	}

	
	private static String parseResponse(String response) throws Exception, ParseException{
		String entrezGeneId = null;
		
		JSONParser parser = new JSONParser();
		Object obj = parser.parse(response);
		JSONObject jsonObj = (JSONObject) obj;
		
		if (jsonObj.containsKey("hits")){
			JSONArray jsonArray = (JSONArray) jsonObj.get("hits");
		
		for (Object item : jsonArray) {

			JSONObject itemObj = (JSONObject) item;
			if (itemObj.containsKey("entrezgene")){
				entrezGeneId = String.valueOf(itemObj.get("entrezgene"));
				break;
			}
			
		}
		
		}
		
		return entrezGeneId;
	}
	
	private static NameValuePair[] getQueryString(String primaryIdentifier){
		return new NameValuePair [] {getGeneQuery(primaryIdentifier),getSpeciesQuery() };
	}
	
	private static String getGeneQueryString(String primaryIdentifier) {
		return GENE_SEARCH_PREFIX + primaryIdentifier;
	}

	private static NameValuePair getGeneQuery(String primaryIdentifier) {
		return new NameValuePair(QUERY_PARAM, getGeneQueryString(primaryIdentifier));
	}
	
	private static NameValuePair getSpeciesQuery() {
		return new NameValuePair(SPECIES_PARAM, SPECIES);
	}

	public static EntrezGene getEntrezGeneByGeneId(final String primaryIdentifier) {
		
		Exception exception = null;
		
		try {
			
		String entrezGeneId = processRequest(primaryIdentifier);
		entrezGene.setEntrezGeneId(entrezGeneId);
		entrezGene.setGenePrimaryIdentifier(primaryIdentifier);
		
		}
		catch (Exception e){
			exception = e;
		}finally{
			if (exception!=null){
				log.error("Error occurred while retrieving NCBI entrez gene ID " + exception.getMessage());
			}
			
			log.info("Entrez Gene: " + entrezGene);
		}
	
		return entrezGene;
	}

}
