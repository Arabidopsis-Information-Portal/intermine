package org.intermine.webservice.server.template.result;

/*
 * Copyright (C) 2002-2009 FlyMine
 *
 * This code may be freely distributed and modified under the
 * terms of the GNU Lesser General Public Licence.  This should
 * be distributed with the code.  See the LICENSE file for more
 * information or http://www.gnu.org/copyleft/lesser.html.
 *
 */

import java.util.List;

import junit.framework.TestCase;

import org.intermine.webservice.server.TestUtil;
import org.intermine.webservice.server.output.Output;



/**
 * Tests query result web service.  
 * Tests urls like: http://localhost:8080/service/query/results?query=...
 * @author Jakub Kulaviak
 **/
public class TemplateResultTest extends TestCase
{
    
    private String serviceUrl;

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        this.serviceUrl = TestUtil.getServiceBaseURL() + "/template/results?";
    }
    
    /**
     * Default url (it is url with default values in it) for this template is
     * http://localhost:8080/intermine-test/service/template/results?name=employeesOfACertainAge&op1=gt
     * &value1=10&op2=ne&value2=10&size=10&format=tab 
     * This test checks, that values in template are replaced with actual parameters in request.
     * @throws Exception if some error occurs
     */
    public void testForNonDefaultParameterValues() throws Exception {
        String tabResult = getResultForQueryString("name=employeesOfACertainAge&cons1=Employee.age&code1=A&op1=gt" +
        		"&value1=20&cons2=Employee.age&code2=B&op2=ne&value2=40&size=10&format=tab").trim();
        List<List<String>> results = TestUtil.parseTabResult(tabResult);
        
        System.out.println("result: " + tabResult);
        
        assertEquals("EmployeeA3", results.get(0).get(0));
        assertEquals("30", results.get(0).get(1));

        assertEquals("EmployeeB2", results.get(1).get(0));
        assertEquals("50", results.get(1).get(1));

        assertEquals("EmployeeB3", results.get(2).get(0));
        assertEquals("60", results.get(2).get(1));
    }

    /**
     * Test template with 4 constraints.
     * @throws Exception
     */
    public void testFourConstraints() throws Exception {
        String tabResult = getResultForQueryString("name=fourConstraints&cons1=Employee.name" +
        		"&op1=CONTAINS&value1=Employee&cons2=Employee.age&code2=B&op2=lt&value2=20" +
        		"&cons3=Employee.age&code3=C&op3=gt&value3=20&cons4=Employee.fullTime&op4=eq" +
        		"&value4=false&size=10&format=tab").trim();
        List<List<String>> results = TestUtil.parseTabResult(tabResult);

        assertEquals("EmployeeA3", results.get(0).get(0));
        assertEquals("30", results.get(0).get(1));
        assertEquals("3", results.get(0).get(2));
        assertEquals("false", results.get(0).get(3));
    }
    
    /**
     * Tests that if you modify order of constraints in request than it returns
     * valid result. Old version of template service was dependent on order of 
     * constraints in request.
     * @throws Exception
     */
    public void testModifiedConstraintsOrder() throws Exception {
        String tabResult = getResultForQueryString("name=fourConstraints&cons4=Employee.name" +
                "&op4=CONTAINS&value4=Employee&cons3=Employee.age&code3=B&op3=lt&value3=20" +
                "&cons2=Employee.age&code2=C&op2=gt&value2=20&cons1=Employee.fullTime&op1=eq" +
                "&value1=false&size=10&format=tab").trim();
        List<List<String>> results = TestUtil.parseTabResult(tabResult);

        assertEquals("EmployeeA3", results.get(0).get(0));
        assertEquals("30", results.get(0).get(1));
        assertEquals("3", results.get(0).get(2));
        assertEquals("false", results.get(0).get(3));
    }
         
    private String getRequestString(String parameterString) {
        return getServiceUrl() + parameterString;
    }
    
    /**
     * Tests that error message appear when public template with this name doesn't exist.
     * @throws Exception when an error occurs
     */
    public void testErrorXMLOutput() throws Exception {
        /* There isn't probably way how to check error message generated by InterMinew 
         * (like <error><message>Invalid request</message></error>) with httpunit because
         * httpunit in case of http error throws exception without response body*/
        String req = getRequestString("name=unknown").trim();
        String msg = TestUtil.getResponseMessage(req);
        assertEquals("Not Found", msg);
    }

    /**
     * Test that appropriate response status code is returned 
     * for unknown template.
     * @throws Exception
     */
    public void testErrorXMLStatus() throws Exception {
        String req = getRequestString("name=unknown").trim();
        int status = TestUtil.getResponseCode(req);
        assertEquals(Output.SC_NOT_FOUND, status);
    }
    
    public String getServiceUrl() {
        return serviceUrl;
    }

    private String getResultForQueryString(String parameterString) throws Exception {
        String requestString = getServiceUrl() + parameterString;
        return TestUtil.getResult(requestString);
    }
}
