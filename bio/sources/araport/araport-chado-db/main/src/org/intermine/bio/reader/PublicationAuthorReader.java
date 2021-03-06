package org.intermine.bio.reader;

import java.sql.Connection;
import java.util.HashMap;
import java.util.Map;

import org.intermine.item.domain.database.DatabaseItemReader;
import org.intermine.bio.dataflow.config.SourceDataFlowTaskContainer;
import org.intermine.bio.domain.source.SourcePhenotype;
import org.intermine.bio.domain.source.SourcePubAuthors;
import org.intermine.bio.domain.source.SourcePublication;
import org.intermine.bio.domain.source.SourceStock;
import org.intermine.bio.item.ItemReader;
import org.intermine.bio.jdbc.core.PreparedStatementSetter;
import org.intermine.bio.rowmapper.PhenotypeRowMapper;
import org.intermine.bio.rowmapper.PublicationAuthorRowMapper;
import org.intermine.bio.rowmapper.PublicationRowMapper;
import org.intermine.bio.rowmapper.StockRowMapper;

public class PublicationAuthorReader {
	
	public PublicationAuthorReader(){
		
	}

public DatabaseItemReader<SourcePubAuthors> getReader(Connection con){
		
	DatabaseItemReader<SourcePubAuthors> reader = new DatabaseItemReader<SourcePubAuthors>();
	
		reader.setSql(SourceDataFlowTaskContainer.PUBLICATION_AUTHORS_SQL);
		reader.setDataSource(con);
		reader.setRowMapper(getRowMapper());
		
		return reader;
	}
	
	
	public PublicationAuthorRowMapper getRowMapper(){
		return new PublicationAuthorRowMapper();
	}

	
	public void setParameters(int pubId, DatabaseItemReader<SourcePubAuthors> reader){
		
		Map<Integer,Object> param = new HashMap<Integer, Object>();
		param.put(1, pubId);
		
		reader.setParameterValues(param);
		
	}
	
}
