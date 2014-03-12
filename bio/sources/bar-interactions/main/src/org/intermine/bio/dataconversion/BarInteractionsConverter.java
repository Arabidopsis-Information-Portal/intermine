package org.intermine.bio.dataconversion;

/*
 * Copyright (C) 2002-2011 FlyMine
 *
 * This code may be freely distributed and modified under the
 * terms of the GNU Lesser General Public Licence.  This should
 * be distributed with the code.  See the LICENSE file for more
 * information or http://www.gnu.org/copyleft/lesser.html.
 *
 */

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;
import org.apache.log4j.Logger;

import org.apache.commons.lang.StringUtils;
import org.intermine.dataconversion.ItemWriter;
import org.intermine.metadata.Model;
import org.intermine.objectstore.ObjectStoreException;
import org.intermine.sql.Database;
import org.intermine.xml.full.Item;

/**
 *
 * @author Julie Sullivan
 */
public class BarInteractionsConverter extends BioDBConverter
{
    private static final Logger LOG =
        Logger.getLogger(BarInteractionsConverter.class);
    private static final String DATASET_TITLE = "Interactions data set";
    private static final String DATA_SOURCE_NAME = "BAR";
    private static final int TAXON_ID = 3702;
    private Map<String, String> genes = new HashMap<String, String>();
    private Map<String, String> publications = new HashMap<String, String>();
    private Map<String, String> terms = new HashMap<String, String>();
    private static final String INTERACTION_TYPE = "physical";
    private static final String PUBMED_PREFIX = "PubMed";

    /**
     * Construct a new BarInteractionsConverter.
     * @param database the database to read from
     * @param model the Model used by the object store we will write to with the ItemWriter
     * @param writer an ItemWriter used to handle Items created
     */
    public BarInteractionsConverter(Database database, Model model, ItemWriter writer) {
        super(database, model, writer, DATA_SOURCE_NAME, DATASET_TITLE);
    }

    /**
     * {@inheritDoc}
     */
    public void process() throws Exception {

    	Connection connection = null;

        if (getDatabase() == null) {
            // no Database when testing and no connection needed
            connection = null;
        } else {
        	// a database has been initialised from properties starting with db.bar-interactions
            connection = getDatabase().getConnection();
        }
        processQueryResults(connection);
    }

    private void processQueryResults(Connection connection)
        throws SQLException, ObjectStoreException {
        ResultSet res = runInteractionsQuery(connection);
    	while (res.next()) {
    		String gene1 = res.getString(1);
    		String gene2 = res.getString(2);
    		Integer quality = new Integer(res.getInt(3));
    		Integer index = new Integer(res.getInt(4));
    		// is this a confidence score?
    		Double pcc = new Double(res.getDouble(5));
    		String pubString = res.getString(6);
    		String interactionsDetectionMI = res.getString(7);
//    		String interactionsDetection = res.getString(8);
    		String interactionsTypeMI = res.getString(8);
//    		String interactionsType = res.getString(10);

    		// strings that represent the stored gene
    		String geneRefId1 = getGene(gene1);
    		String geneRefId2 = getGene(gene2);

    		String interactionRefId = processInteraction(geneRefId1, geneRefId2, quality, index,
    				pcc, pubString, interactionsDetectionMI, interactionsTypeMI);
    		processInteractionDetails(interactionRefId, geneRefId1, geneRefId2, pubString,
    				interactionsDetectionMI, interactionsTypeMI);
    	}
    	res.close();
    }

    private String processInteraction(String geneRefId1, String geneRefId2,
    		Integer quality, Integer index, Double pcc, String pubString,
    		String interactionsDetectionMI, String interactionsTypeMI) throws ObjectStoreException {

    	Item interaction = createItem("Interaction");
    	interaction.setReference("gene1", geneRefId1);
    	interaction.setReference("gene2", geneRefId2);
    	store(interaction);
    	return interaction.getIdentifier();
    }

    private String processInteractionDetails(String interactionRefId, String geneRefId1,
    		String geneRefId2, String pubString, String
    		interactionsDetectionMI, String interactionsTypeMI)
    		throws ObjectStoreException {
    	Item detail = createItem("InteractionDetail");
    	detail.setAttribute("type", INTERACTION_TYPE);
    	if (StringUtils.isNotEmpty(interactionsTypeMI)) {
    		detail.setReference("relationshipType", getTerm(interactionsTypeMI));
    	}
    	detail.addToCollection("dataSets", getDataSourceItem(getDataSetTitle(TAXON_ID)));
        detail.addToCollection("allInteractors", geneRefId1);
        detail.addToCollection("allInteractors", geneRefId2);
        if (StringUtils.isNotEmpty(interactionsDetectionMI + pubString)) {
        	detail.setReference("experiment", getExperiment(pubString, interactionsDetectionMI));
        }
        detail.setReference("interaction", interactionRefId);
        store(detail);
        return detail.getIdentifier();
    }

    private String getExperiment(String pubString, String interactionsDetectionMI)
    		throws ObjectStoreException {
        Item experiment = createItem("InteractionExperiment");
        // some publications don't start with PubMed, what are those?
        if (StringUtils.isNotEmpty(pubString) && pubString.startsWith(PUBMED_PREFIX)
        		&& pubString.length() >  PUBMED_PREFIX.length() + 1) {
        	String pubRefId = getPublication(pubString);
        	if (StringUtils.isNotEmpty(pubRefId)) {
        		experiment.setReference("publication", pubRefId);
        	}
        }
        if (StringUtils.isNotEmpty(interactionsDetectionMI)) {
        	experiment.addToCollection("interactionDetectionMethods",
        			getTerm(interactionsDetectionMI));
        }
        store(experiment);
        return experiment.getIdentifier();
    }

    private String getPublication(String pubString) throws ObjectStoreException {
        String pubMedId =  pubString.substring(PUBMED_PREFIX.length());

    	// why do some look like this?
    	// PubMed18849490                  +

        String pubRefId = publications.get(pubMedId);
        if (pubRefId != null) {
        	return pubRefId;
        }
        Item publication = createItem("Publication");
        publication.setAttribute("pubMedId", pubMedId);
        store(publication);
        pubRefId = publication.getIdentifier();
        publications.put(pubMedId, pubRefId);
        return pubRefId;
    }

    private String getGene(String identifier)
    		throws ObjectStoreException {
    	String geneRefId = genes.get(identifier);

    	// we've already seen this gene, don't store again
    	if (geneRefId != null) {
		return geneRefId;
    	}

    	// create new gene
    	Item gene = createItem("Gene");
    	gene.setReference("organism", getOrganismItem(TAXON_ID));
    	gene.setAttribute("primaryIdentifier", identifier);

    	// put in our map
	geneRefId=gene.getIdentifier();
    	genes.put(identifier, geneRefId);

    	// store to database
    	store(gene);

    	return gene.getIdentifier();
    }

    private String getTerm(String identifier) throws ObjectStoreException {
    	String refId = terms.get(identifier);
    	if (refId != null) {
    		return refId;
    	}
    	Item item = createItem("InteractionTerm");
    	item.setAttribute("identifier", "MI:" + identifier);
    	terms.put(identifier, item.getIdentifier());
   		store(item);
    	return item.getIdentifier();
    }

    /**
     * Default implementation that makes a data set title based on the data source name.
     * {@inheritDoc}
     */
    @Override
    public String getDataSetTitle(int taxonId) {
        return DATA_SOURCE_NAME + " interactions data set";
    }

    /**
     * Return the interactions from the bar-interactions table
     * This is a protected method so that it can be overriden for testing.
     * @param connection the bar database connection
     * @throws SQLException if there is a problem while querying
     * @return the interactions
     */
    protected ResultSet runInteractionsQuery(Connection connection) throws SQLException {
        Statement stmt = connection.createStatement();
    	String query = "select upper(protein1), upper(protein2), quality, index, pcc, bind_id, " +
    			"interactions_detection_mi, interactions_detection, interactions_type_mi, " +
    			"interactions_type from interactions;";
        ResultSet res = stmt.executeQuery(query);
        return res;
    }
}
