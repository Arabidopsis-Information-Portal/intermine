package org.thalemine.web.webservices.client;

import org.apache.log4j.Logger;

public class GeneRIFSubmissionResponse {
	
	private String geneId;
	private String pubmedId;
	private String submissionText;
	private String email;
	private String result;
	private String output;
	private String responseError;
	
	protected static final Logger log = Logger.getLogger(GeneRIFSubmissionResponse.class);
	
	public GeneRIFSubmissionResponse(){
		
	}
	
	public String getGeneId() {
		return geneId;
	}
	public void setGeneId(String geneId) {
		this.geneId = geneId;
	}
	public String getPubmedId() {
		return pubmedId;
	}
	public void setPubmedId(String pubmedId) {
		this.pubmedId = pubmedId;
	}
	public String getSubmissionText() {
		return submissionText;
	}
	public void setSubmissionText(String submissionText) {
		this.submissionText = submissionText;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getResult() {
		return result;
	}
	public void setResult(String result) {
		this.result = result;
	}
	public String getOutput() {
		return output;
	}
	public void setOutput(String output) {
		this.output = output;
	}
	public String getResponseError() {
		return responseError;
	}
	public void setResponseError(String responseError) {
		this.responseError = responseError;
	}

	@Override
	public String toString() {
		return "GeneRIFSubmissionResponse [geneId=" + geneId + ", pubmedId=" + pubmedId + ", submissionText="
				+ submissionText + ", email=" + email + ", result=" + result + ", output=" + output
				+ ", responseError=" + responseError + "]";
	}

}
