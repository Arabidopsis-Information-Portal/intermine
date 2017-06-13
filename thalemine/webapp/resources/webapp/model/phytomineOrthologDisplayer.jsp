<!doctype html>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>

<!-- phytomineOrthologDisplayer.jsp -->
<div id="phytomineOrtholog_displayer" class="collection-table">
<div class="header">
<h3>Phytozome Homologs</h3>
<p>Data Source: <a target="_blank" href="/${WEB_PROPERTIES['webapp.path']}/portal.do?class=DataSet&externalids=Phytozome+Orthologs">Phytozome</a></p>
</div>

<c:set var="object" value="${reportObject.object}"/>

<c:choose>
<c:when test="${((!empty object.chromosomeLocation && !empty object.chromosome)
                || className == 'Chromosome') && className != 'ChromosomeBand'}">
<br />

<div id="InParanoidDisplayer" class="collection-table imtables-dashboard container-fluid imtables">
  <c:set var="name" value="${object.primaryIdentifier}"/>

  <c:choose>
  <c:when test="${WEB_PROPERTIES['phytomine.homolog.prefix'] != null}">
 <div id="phytomine-homolog-container">
 <!-- temporarily removed
   <p class="apology">
     Please be patient while the results of your query are retrieved.
   </p>
   -->
 </div>

 <script type="text/javascript">

   var geneId = "${name}";
   // for local test only
   // var webapp_root_url="http://phytozome.jgi.doe.gov/phytomine/";
   var webapp_root_url = "${WEB_PROPERTIES['phytomine.homolog.prefix']}";

   var phytomine = new imjs.Service({root: webapp_root_url});

   var options = {
          type: 'table',
          service: phytomine,
          query: {
              "model":{"name":"genomic"},
              "select": [
                "Homolog.ortholog_gene.primaryIdentifier",
                "Homolog.ortholog_gene.organism.shortName",
                "Homolog.ortholog_gene.briefDescription"
              ],
              "where": [
                {
                  "path": "Homolog.gene",
                  "op": "LOOKUP",
                  "value": geneId,
                  "extraValue": "A. thaliana",
                  "code": "A"
                },
                {
                  "path": "Homolog.ortholog_gene.organism.shortName",
                  "op": "!=",
                  "value": "A. thaliana",
                  "code": "B"
                }
              ],
              "orderBy": [
                {
                  "path": "Homolog.ortholog_gene.organism.shortName",
                  "direction": "ASC"
                }
              ],
              "constraintLogic":"A and B"
          },
         properties: { pageSize: 10 }
    };

   var wrapSpan = function(text){
       return '<span>'+text+'</span>';
    };

   var formatLink = function(url, text, target, cls){
     target = target || "_self";
     text = text || url;

    if (cls == 'extlink') {
          return '<a class="'+cls+'" href="'+url+'" target="'+target+'">' + text + '</a>';
       } else {
          return '<a href="'+url+'" target="'+target+'">' + text + '</a>';
       }
     };

    var formatPhytomineLink = function(id, dataClass, value) {
        var thalemine_url = '/${WEB_PROPERTIES['webapp.path']}' + '/portal.do?class=' + dataClass + '&externalids=' + id;
        var medicmine_url = '${WEB_PROPERTIES['intermines.medicmine.url']}' + '/portal.do?class=' + dataClass + '&externalids=' + id;
        var phytomine_url = '${WEB_PROPERTIES['phytomine.url']}' + '/portal.do?class=' + dataClass + '&externalids=' + id;
        if (typeof value === 'undefined') {
            value = id;
        }

        var AT_pat, MT_pat;
        if (dataClass == 'Gene') {
            AT_pat = '^AT';
            MT_pat = '^Medtr';
        } else if (dataClass == 'Organism') {
            AT_pat = 'thaliana$';
            MT_pat = 'truncatula$';
        }

        var AT_re = new RegExp(AT_pat);
        var MT_re = new RegExp(MT_pat);
        if (AT_re.test(id)) {
            return formatLink(thalemine_url, wrapSpan(value), "_blank", 'internal');
        } else if (MT_re.test(id)) {
            return formatLink(medicmine_url, wrapSpan(value), "_blank", 'extlink');
        } else {
            return formatLink(phytomine_url, wrapSpan(value), "_blank", 'extlink');
        }
    };

    var phytomineGeneFormatter = function(o) {
        return formatPhytomineLink(o.get('primaryIdentifier'), "Gene", undefined);
    };

    var phytomineOrganismFormatter = function(o) {
        return formatPhytomineLink(o.get('shortName'), "Organism", undefined);
    };

    var phytomineDeflineFormatter = function(o) {
        return formatPhytomineLink(o.get('primaryIdentifier'), "Gene", o.get('briefDescription'));
    };

    // new way for using imtables
    imtables.formatting
                .registerFormatter(phytomineGeneFormatter, 'genomic', 'Gene', [ 'primaryIdentifier' ]);

    imtables.formatting
                .registerFormatter(phytomineOrganismFormatter, 'genomic', 'Organism', [ 'shortName' ]);

    imtables.formatting
                .registerFormatter(phytomineDeflineFormatter, 'genomic', 'Gene', [ 'briefDescription' ]);


    // note: imtables.loadTable delivers a table without controls (only pagination)

    // to fix quickly MINE-979
    imtables.configure('DefaultPageSize', 10);
    imtables.configure('TableCell.IndicateOffHostLinks', false);

    imtables.loadDash('#phytomine-homolog-container',
        {start : 0, size : 10},
        {service : options.service,
            query : options.query}
        ).then(
            withTable,
            FailureNotification.notify
        );

        function withTable(table) {
            table.bus.on('list-action:failure', LIST_EVENTS['list-creation:failure']);
            table.bus.on('list-action:success', LIST_EVENTS['list-creation:success']);
        }
    </script>

  </c:when>
  <c:otherwise>
     <p>There was a problem rendering the homolog data</code>.</p>
  <script type="text/javascript">
    jQuery('#InParanoidDisplayer').addClass('warning');
  </script>
  </c:otherwise>
  </c:choose>
</c:when>
<c:otherwise>
  <p style="font-style:italic;">No homolog data available</p>
</c:otherwise>
</c:choose>
</div>
<!-- /phytomineOrthologDisplayer.jsp -->
