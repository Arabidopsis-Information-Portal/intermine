package org.thalemine.web.webservices.client;

public class EntrezGene {
	
	private String genePrimaryIdentifier;
	private String entrezGeneId;
	
	public EntrezGene() {
		
	}
	public String getGenePrimaryIdentifier() {
		return genePrimaryIdentifier;
	}
	public void setGenePrimaryIdentifier(String genePrimaryIdentifier) {
		this.genePrimaryIdentifier = genePrimaryIdentifier;
	}
	public String getEntrezGeneId() {
		return entrezGeneId;
	}
	public void setEntrezGeneId(String entrezGeneId) {
		this.entrezGeneId = entrezGeneId;
	}
	
	
	@Override
	public String toString() {
		return "EntrezGene [genePrimaryIdentifier=" + genePrimaryIdentifier + ", entrezGeneId=" + entrezGeneId + "]";
	}

}
