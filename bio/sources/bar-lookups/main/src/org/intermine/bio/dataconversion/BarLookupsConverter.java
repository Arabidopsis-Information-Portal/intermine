package org.intermine.bio.dataconversion;

/*
 * Copyright (C) 2002-2011 InterMine
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
import org.intermine.dataconversion.ItemWriter;
import org.intermine.metadata.Model;
import org.intermine.objectstore.ObjectStoreException;
import org.intermine.sql.Database;
import org.intermine.xml.full.Item;

/**
 *
 * @author sc
 */
public class BarLookupsConverter extends BioDBConverter
{
    private static final Logger LOG =
        Logger.getLogger(BarLookupsConverter.class);
    private static final String DATASET_TITLE = "Expressions data set";
    private static final String EXPERIMENT_CATEGORY = "hormone";
    private static final String DATA_SOURCE_NAME = "annotations_lookup";
    private static final int TAXON_ID = 3702;
    private Map<String, String> genes = new HashMap<String, String>();
    private Map<String, String> publications = new HashMap<String, String>();
    private Map<String, String> terms = new HashMap<String, String>();
    private static final String PUBMED_PREFIX = "PubMed";

    //pi, item Id
    private Map<String, String> probeGeneMap = new HashMap<String, String>();
    //barId, item Id
    private Map<Integer, String> sampleIdRefMap = new HashMap<Integer, String>();

    /**
     * Construct a new BarLookupsConverter.
     * @param database the database to read from
     * @param model the Model used by the object store we will write to with the ItemWriter
     * @param writer an ItemWriter used to handle Items created
     */
    public BarLookupsConverter(Database database, Model model, ItemWriter writer) {
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
        	// a database has been initialised from properties starting with db.bar-expressions
            connection = getDatabase().getConnection();
        }

        processProbes(connection);
    }


    private void processProbes(Connection connection)
            throws SQLException, ObjectStoreException {
            ResultSet res = getProbes(connection);
        	while (res.next()) {
        		String probe = res.getString(1);
        		String gene = res.getString(2).toUpperCase();
//        		LOG.info("GP: " + probe + "|"+ gene);

        		if (!gene.startsWith("AT")) {
        			// not a gene id!
        			LOG.warn("NOT A GENE: " + gene);
        			continue;
        		}

        		// if probe exist, check gene (could be many to many??)
        		if (probeGeneMap.containsKey(probe)) {
        			LOG.warn("probeset " + probe
        					+ " seems to be connected to multiple genes: "
        					+ probeGeneMap.get(probe) + ", " + gene);
        			continue;
        		}
        		if (probeGeneMap.containsValue(gene)) {
        			//addref
        			LOG.warn("MULTIPLE GENE: " + gene);
        			continue;
        		}
        		String geneRefId = createGene(gene);
        		probeGeneMap.put(probe, gene);

        		String probeRefId = createProbe(probe,geneRefId);
        	}
        	res.close();
    }


    private String createGene(String geneId)
    		throws ObjectStoreException {
    	Item gene = createItem("Gene");
    	gene.setAttribute("primaryIdentifier", geneId);
    	store(gene);
    	return gene.getIdentifier();
    }

    private String createProbe(String probeId, String geneRefId)
    		throws ObjectStoreException {
    	Item probe = createItem("Probe");
    	probe.setAttribute("name", probeId);
    	probe.setReference("gene", geneRefId);
    	store(probe);
    	return probe.getIdentifier();
    }


    /**
     * Return the samples from the bar-expressions table
     * This is a protected method so that it can be overridden for testing.
     * @param connection the bar database connection
     * @throws SQLException if there is a problem while querying
     * @return the samples
     */
    protected ResultSet getProbes(Connection connection) throws SQLException {
    	String query =
    			// data contains duplications by date (?)
    			"SELECT distinct probeset, agi "
    			+ "FROM at_agi_lookup;";
        return doQuery(connection, query, "getProbes");
    }

    /**
     * Default implementation that makes a data set title based on the data source name.
     * {@inheritDoc}
     */
    @Override
    public String getDataSetTitle(int taxonId) {
        return DATA_SOURCE_NAME + "expressions data set";
    }



    /**
     * method to wrap the execution of a query with log info)
     * @param connection
     * @param query
     * @param comment for not logging
     * @return the result set
     * @throws SQLException
     */
    private ResultSet doQuery(Connection connection, String query, String comment)
        throws SQLException {
        // see ModEncodeMetaDataProcessor
    	LOG.info("executing: " + query);
        long bT = System.currentTimeMillis();
        Statement stmt = connection.createStatement();
        ResultSet res = stmt.executeQuery(query);
        LOG.info("QUERY TIME " + comment + ": " + (System.currentTimeMillis() - bT) + " ms");
        return res;
    }

}
