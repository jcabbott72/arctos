<cfcontent type="application/rdf+xml; charset=ISO-8859-1">
<cfinclude template="/includes/functionLib.cfm">
<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionid)#">
	select 
		filtered_flat.LAST_EDIT_DATE,
		guid,
		collection,
		began_date,
		ended_date,
		RelatedInformation,
		BASISOFRECORD,
		INSTITUTION_ACRONYM,
		COLLECTION_CDE,
		CAT_NUM,
		COLLECTORS,
		YEAR,
		MONTH,
		DAY,
		VERBATIM_DATE,
		DAYOFYEAR,
		HIGHER_GEOG,
		CONTINENT_OCEAN,
		ISLAND_GROUP,
		ISLAND,
		COUNTRY,
		STATE_PROV,
		COUNTY,
		SPEC_LOCALITY,
		DEC_LAT,
		DEC_LONG,
		DATUM,
		ORIG_LAT_LONG_UNITS,
		VERBATIMLATITUDE,
		VERBATIMLONGITUDE,
		GEOREFMETHOD,
		COORDINATEUNCERTAINTYINMETERS,
		LAT_LONG_REMARKS,
		MIN_ELEV_IN_M,
		MAX_ELEV_IN_M,
		VERBATIMELEVATION,
		MIN_DEPTH_IN_M,
		MAX_DEPTH_IN_M,
		SCIENTIFIC_NAME,
		FULL_TAXON_NAME,
		KINGDOM,
		PHYLUM,
		PHYLCLASS,
		PHYLORDER,
		FAMILY,
		GENUS,
		SPECIES,
		SUBSPECIES,
		AUTHOR_TEXT,
		IDENTIFICATIONMODIFIER,
		IDENTIFIEDBY,
		TYPESTATUS,
		SEX,
		PARTS,
		INDIVIDUALCOUNT,
		AGE_CLASS,
		GENBANKNUM,
		OTHERCATALOGNUMBERS,
		RELATEDCATALOGEDITEMS,
		REMARKS,
		enteredPerson.agent_name EnteredBy,
		editedPerson.agent_name EditedBy,
		COLL_OBJECT_ENTERED_DATE		
	from 
		filtered_flat,
		coll_object,
		preferred_agent_name enteredPerson,
		preferred_agent_name editedPerson		
	where 
		filtered_flat.collection_object_id = coll_object.collection_object_id AND
		coll_object.entered_person_id = enteredPerson.agent_id AND
		coll_object.last_edited_person_id = editedPerson.agent_id (+) AND
	upper(guid)='#ucase(guid)#'		
</cfquery>
<cfoutput>
<cfif (d.verbatim_date is d.began_date) AND (d.verbatim_date is d.ended_date)>
	<cfset thisDate = #d.verbatim_date#>
<cfelseif (
	(d.verbatim_date is not d.began_date) OR
		(d.verbatim_date is not d.ended_date)
	) AND d.began_date is d.ended_date>
	<cfset thisDate = "#d.verbatim_date# (#d.began_date#)">
<cfelse>
	<cfset thisDate = "#d.verbatim_date# (#d.began_date# - #d.ended_date#)">
</cfif>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:tap="http://rs.tdwg.org/tapir/1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:hyam="http://hyam.net/tapir2sw##"
	xmlns:dwc="http://rs.tdwg.org/dwc/terms/" xmlns:dwcc="http://rs.tdwg.org/dwc/curatorial/"
	xmlns:dc="http://purl.org/dc/terms/"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos##">
    <rdf:Description
        rdf:about="#application.serverRootUrl#/guid/#guid#">
        <dc:creator>#d.EnteredBy#</dc:creator>
        <dc:created>#d.COLL_OBJECT_ENTERED_DATE#</dc:created>
        <dc:hasVersion rdf:resource="#application.serverRootUrl#/guid/#guid#" />
    </rdf:Description>
      <!--This is metadata about this specimen-->
    <rdf:Description rdf:about="#application.serverRootUrl#/guid/#guid#">
	<dc:title>#d.guid#: #d.collection# #d.cat_num# #d.scientific_name#</dc:title>
	<dc:description>#d.collection# #d.cat_num# #d.scientific_name#</dc:description>
	<dc:created>#thisDate#</dc:created>
	<geo:Point>
		<geo:lat>#d.dec_lat#</geo:lat>
		<geo:long>#d.dec_long#</geo:long>
	</geo:Point>
  	<!-- Assertions based on experimental version of Darwin Core -->
	<dwc:SampleID>#application.serverRootUrl#/guid/#d.guid#</dwc:SampleID>
	<dc:modified>#d.last_edit_date#</dc:modified>
	<dwc:BasisOfRecord>#d.BasisOfRecord#</dwc:BasisOfRecord>
	<dwc:InstitutionCode>#d.institution_acronym#</dwc:InstitutionCode>
	<dwc:CollectionCode>#d.collection_cde#</dwc:CollectionCode>
	<dwc:CatalogNumber>#d.cat_num#</dwc:CatalogNumber>
	<dwc:ScientificName>#d.scientific_name#</dwc:ScientificName>
	<dwc:HigherTaxon>#d.FULL_TAXON_NAME#</dwc:HigherTaxon>
	<dwc:Kingdom>#d.KINGDOM#</dwc:Kingdom>
	<dwc:Phylum>#d.PHYLUM#</dwc:Phylum>
	<dwc:Class>#d.PHYLCLASS#</dwc:Class>
	<dwc:Order>#d.PHYLORDER#</dwc:Order>
	<dwc:Family>#d.FAMILY#</dwc:Family>
	<dwc:Genus>#d.GENUS#</dwc:Genus>
	<dwc:Species>#d.SPECIES#</dwc:Species>
	<dwc:Subspecies>#d.SUBSPECIES#</dwc:Subspecies>
	<dwc:IdentifiedBy>#d.IDENTIFIEDBY#</dwc:IdentifiedBy>
	<dwc:HigherGeography>#d.higher_geog#</dwc:HigherGeography>
	<dwc:ContinentOcean>#d.CONTINENT_OCEAN#</dwc:ContinentOcean>
	<dwc:Country>#d.country#</dwc:Country>
	<dwc:StateProvince>#d.state_prov#</dwc:StateProvince>
	<dwc:IslandGroup>#d.ISLAND_GROUP#</dwc:IslandGroup>
	<dwc:Island>#d.ISLAND#</dwc:Island>
	<dwc:County>#d.COUNTY#</dwc:County>
	<dwc:Locality>#d.spec_locality#</dwc:Locality>
	<dwc:DecimalLongitude>#d.dec_lat#</dwc:DecimalLongitude>
	<dwc:DecimalLatitude>#d.dec_long#</dwc:DecimalLatitude>
	<dwc:HorizontalDatum>#d.DATUM#</dwc:HorizontalDatum>
	<dwc:OriginalCoordinateSystem>#d.ORIG_LAT_LONG_UNITS#</dwc:OriginalCoordinateSystem>
	<dwc:VerbatimLatitude>#d.VERBATIMLATITUDE#</dwc:VerbatimLatitude>
	<dwc:VerbatimLongitude>#d.VERBATIMLONGITUDE#</dwc:VerbatimLongitude>
	<dwc:GeorefMethod>#d.GEOREFMETHOD#</dwc:GeorefMethod>
	<dwc:CoordinateUncertaintyInMeters>#d.COORDINATEUNCERTAINTYINMETERS#</dwc:CoordinateUncertaintyInMeters>
	<dwc:LatLongComments>#d.LAT_LONG_REMARKS#</dwc:LatLongComments><dwc:MinimumElevationInMeters>#d.MIN_ELEV_IN_M#</dwc:MinimumElevationInMeters>
	<dwc:MaximumElevationInMeters>#d.MAX_ELEV_IN_M#</dwc:MaximumElevationInMeters>
	<dwc:VerbatimElevation>#d.VERBATIMELEVATION#</dwc:VerbatimElevation>
	<dwc:MinimumDepthInMeters>#d.MIN_DEPTH_IN_M#</dwc:MinimumDepthInMeters>
	<dwc:MaximumDepthInMeters>#d.MAX_DEPTH_IN_M#</dwc:MaximumDepthInMeters>
	<dwc:TypeStatus>#d.TYPESTATUS#</dwc:TypeStatus>
	<dwc:Sex>#d.SEX#</dwc:Sex>
	<dwc:Preparations>#d.PARTS#</dwc:Preparations>
	<dwc:IndividualCount>#d.INDIVIDUALCOUNT#</dwc:IndividualCount>
	<dwc:AgeClass>#d.AGE_CLASS#</dwc:AgeClass>
	<dwc:OtherCatalogNumbers>#d.OTHERCATALOGNUMBERS#</dwc:OtherCatalogNumbers>
	<dwc:GenBankNum>#d.GENBANKNUM#</dwc:GenBankNum>
	<dwc:RelatedCatalogedItems>#d.RELATEDCATALOGEDITEMS#</dwc:RelatedCatalogedItems>
	<dwc:Collector>#d.collectors#</dwc:Collector>
	<dwc:EarliestDateCollected>#d.began_date#</dwc:EarliestDateCollected>
	<dwc:LatestDateCollected>#d.ended_date#</dwc:LatestDateCollected>
	<dwc:VerbatimCollectingDate>#d.VERBATIM_DATE#</dwc:VerbatimCollectingDate>
	<dwc:Remarks>#d.REMARKS#</dwc:Remarks>
    </rdf:Description>
</rdf:RDF>
</cfoutput>