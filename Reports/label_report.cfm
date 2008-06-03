<cfoutput>

<cfinclude template="/includes/_header.cfm">

<cfif #action# is "edit">
    edit
</cfif>
<cfif #action# is "clone">
    clone
</cfif>
<cfif #action# is "listReports">
    <cfdirectory action="list" directory="#Application.webDirectory#/Reports/templates" filter="*.cfr" name="reportList">
    <cfloop query="reportList">
        #name# <a href="labelReport.cfm?action=edit&name=#name#">Edit</a>
               <a href="labelReport.cfm?action=clone&name=#name#">Clone</a>                   
               <a href="labelReport.cfm?action=download&name=#name#">Download</a>
               <br>
    </cfloop>
</cfif>
<cfif #action# is "nothing">
<!----
    create table cf_report_sql (
        report_id number not null,
        report_name varchar2(38),
        report_template  varchar2(38),
        SQL varchar2(4000)
    );
    create or replace public synonym cf_report_sql for cf_report_sql;

    ALTER TABLE SQL
        add CONSTRAINT pk_cf_report_sql
        PRIMARY  KEY (report_id);
     CREATE OR REPLACE TRIGGER cf_report_sql_key                                         
         before insert  ON cf_report_sql  
		 for each row 
		    begin     
		    	if :NEW.report_id is null then                                                                                      
		    		select somerandomsequence.nextval into :new.report_id from dual;
		    	end if;                                
		    end;                                                                                            
		/
		sho err
  
---->
<a href="label_report.cfm?action=listReports" target="_blank">Manage Reports</a>

    <cfif not isdefined("collection_object_id")>
	<cfabort>
</cfif>	
<form name="custom" method="post" action="label_report.cfm">
    <input type="hidden" name="action" value="print">
    <input type="hidden" name="collection_object_id" value="#collection_object_id#">
    <label for="user_otherID">Other ID</label>
    <select name="user_otherID" id="user_otherID" size="1">
        <option value="noID">None</option>
        <cfloop query="ctOtherIdType">
            <option value="#other_id_type#">#other_id_type#</option>
        </cfloop>
    </select>
    
  <label for="include_island">include_island?</label>
    <input type="checkbox" value="1" name="include_island" id="include_island"
         <cfif #include_island# is "1"> checked="checked" </cfif>>
    <label for="include_island_group">include_island_group?</label>
    <input type="checkbox" value="1" name="include_island_group" id="include_island_group"
         <cfif #include_island_group# is "1"> checked="checked" </cfif>>
    <label for="include_feature">include_feature?</label>
    <input type="checkbox" value="1" name="include_feature" id="include_feature"
         <cfif #include_feature# is "1"> checked="checked" </cfif>>
                
    <label for="sort_order">Sort Order</label>
    <select name="sort_order" id="sort_order" size="1">
        <option value="cat_num">cat_num</option>
    </select>
         <input type="submit" value="Go">
</form>
</cfif>
<cfif #action# is "print">
<cfset sql="
	select
		get_scientific_name_auths(cataloged_item.collection_object_id) sci_name_with_auth,
		concatAcceptedIdentifyingAgent(cataloged_item.collection_object_id) identified_by,
        identification.scientific_name identified_as,
		get_taxonomy(cataloged_item.collection_object_id,'family') family,
		get_taxonomy(cataloged_item.collection_object_id,'scientific_name') tsname,
		get_taxonomy(cataloged_item.collection_object_id,'author_text') author_text,
		CONCATATTRIBUTE(cataloged_item.collection_object_id) attributes,
		trim(ConcatAttributeValue(cataloged_item.collection_object_id,'abundance')) abundance,
		identification_remarks,
		made_date identification_date,
		cat_num,
		state_prov,
		country,
		quad,
		county,
		island,
		island_group,
		sea,
		feature,
		spec_locality,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_lat || 'd'
			WHEN 'deg. min. sec.' THEN lat_deg || 'd ' || lat_min || 'm ' || lat_sec || 's ' || lat_dir
			WHEN 'degrees dec. minutes' THEN lat_deg || 'd ' || dec_lat_min || 'm ' || lat_dir
		END as VerbatimLatitude,
		CASE orig_lat_long_units
			WHEN 'decimal degrees' THEN dec_long || 'd'
			WHEN'degrees dec. minutes' THEN long_deg || 'd ' || dec_long_min || 'm ' || long_dir
			WHEN 'deg. min. sec.' THEN long_deg || 'd ' || long_min || 'm ' || long_sec || 's ' || long_dir
		END as VerbatimLongitude,
		MAXIMUM_ELEVATION,
		MINIMUM_ELEVATION,
		ORIG_ELEV_UNITS,
		concatColl(cataloged_item.collection_object_id) as collectors,
		concatotherid(cataloged_item.collection_object_id) as other_ids,
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier') original_identifier,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service accession') nps_accn,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service catalog') nps_catnum,
		concatsingleotherid(cataloged_item.collection_object_id,'ALAAC') ALAAC,
		verbatim_date,
		habitat_desc,
		habitat,
		associated_species,
		project_name,
        concatsingleotherid(cataloged_item.collection_object_id,'#user_otherID#') user_id_num,
        '#user_otherID#'
	FROM
		cataloged_item,
		identification,
		collecting_event,
		locality,
		geog_auth_rec,
		accepted_lat_long,
		coll_object_remark,
		project_trans,
		project
	WHERE
		cataloged_item.collection_object_id = identification.collection_object_id AND
		cataloged_item.collecting_event_id = collecting_event.collecting_event_id AND
		collecting_event.locality_id = locality.locality_id AND
		locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
		locality.locality_id = accepted_lat_long.locality_id (+) AND
		cataloged_item.collection_object_id = coll_object_remark.collection_object_id (+) AND
		cataloged_item.accn_id = project_trans.transaction_id (+) AND
		project_trans.project_id = project.project_id(+) AND
		accepted_id_fg=1 AND cataloged_item.collection_object_id IN (#collection_object_id#)
	ORDER BY
        #sort_order#
			">
	<cfquery name="d" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
    
    <cfset geogAry = ArrayNew(1)>
    <cfset coordAry = ArrayNew(1)>
    <cfset locAry = ArrayNew(1)>
    <cfset colAry = ArrayNew(1)>
    <cfset detrAry = ArrayNew(1)>
    <cfset projAry = ArrayNew(1)>
    <cfset alaAry = ArrayNew(1)>
    <cfset attAry = ArrayNew(1)>
    <cfset identAry = ArrayNew(1)>


    <cfset i=1>
    <cfloop query="d">
	    <cfset identification = replace(sci_name_with_auth,"&","&amp;","all")>
        <cfset identAry[i] = "#identification#">
        
        <cfset geog="#ucase(state_prov)#">
		<cfif #country# is "United States">
			<cfset geog="#geog#, USA">
		<cfelse>
			<cfset geog="#geog#, #ucase(country)#">
		</cfif>
        <cfset geogAry[i] = "#geog#">
        
	    <cfset coordinates = "">
		<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
			<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
			<cfset coordinates = replace(coordinates,"d","&##176;","all")>
			<cfset coordinates = replace(coordinates,"m","'","all")>
			<cfset coordinates = replace(coordinates,"s","''","all")>
		</cfif>
        <cfset coordAry[i] = "#coordinates#">
        
		<cfset locality="">
        
                <!---
        <cfif include_island is 1>
            <cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #island#">
            <cfelse>
                <cfset locality = "#island#">
            </cfif>            
		</cfif>
       

        <cfif include_island_group is 1>
            <cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #island_group#">
            <cfelse>
                <cfset locality = "#island_group#">
            </cfif>            
		</cfif>
        <cfif include_feature is 1>
            <cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #feature#">
            <cfelse>
                <cfset locality = "#feature#">
            </cfif>            
		</cfif>
        ---->
		<cfif len(#quad#) gt 0>
			<cfif len(#locality#) gt 0>
                <cfset locality = "#locality#, #quad# Quad.:">
            <cfelse>
                 <cfset locality = "#quad# Quad.:">
            </cfif>          
		</cfif>
		<cfif len(#spec_locality#) gt 0>
			<cfset locality = "#locality# #spec_locality#">
		</cfif>
		<cfif len(#coordinates#) gt 0>
		 	<cfset locality = "#locality#, #coordinates#">
		 </cfif>
		  <cfif len(#ORIG_ELEV_UNITS#) gt 0>
		 	<cfset locality = "#locality#. Elev. #MINIMUM_ELEVATION#-#MAXIMUM_ELEVATION# #ORIG_ELEV_UNITS#">
		 </cfif>
		 <cfif len(#habitat#) gt 0>
		 	<cfset locality = "#locality#, #habitat#">
		 </cfif>
		 <cfif len(#associated_species#) gt 0>
		 	<cfset locality = "#locality#, #associated_species#">
		 </cfif>	
		<cfif len(abundance) gt 0>
			<cfset locality = "#locality#, #abundance#">
		</cfif>
		 <cfif right(locality,1) is not ".">
			 <cfset locality = "#locality#.">
		</cfif>
        <cfset locAry[i] = "#locality#">
        
	    <cfset collector="#collectors#">
        <cfset colAry[i] = "#collector#">
                
	    <cfset determiner="">
		<cfif #collectors# neq #identified_by# AND #identified_by# is not "unknown">
			<cfset determiner="Det: #identified_by# #dateformat(made_date,"dd mmm yyyy")#">
		</cfif>
        <cfset detrAry[i] = "#determiner#">
        
		<cfset project="#project_name#">	
		<cfif len(#nps_accn#) gt 0 or len(#npsc#) gt 0>
			<cfif len(#project#) gt 0>
				<cfset project="#project#<br/>">
			</cfif>
			<cfset project="#project#NPS: #nps_accn# #npsc#">
		</cfif>    
        <cfset projAry[i] = "#project#">
    
	    <cfset alaacString="Herbarium, University of Alaska Museum (ALA) accn #alaac#">
        <cfset alaAry[i] = "#alaacString#">
            
		<cfset sAtt="">
		<cfloop list="#attributes#" index="att">
			<cfif att does not contain "abundance">
				<cfif att contains "diploid number">
					<cfset att=replace(att,"diploid number: ","2n=","all")>
				</cfif>
				<cfset sAtt=listappend(sAtt,att)>
			</cfif>
		</cfloop>  
        <cfset attAry[i] = "#sAtt#">
        
        <cfset i=i+1>
	</cfloop>
    
    <cfset temp = QueryAddColumn(d, "geog", "VarChar",geogAry)>
    <cfset temp = QueryAddColumn(d, "coordinates", "VarChar",coordAry)>
    <cfset temp = QueryAddColumn(d, "locality", "VarChar",locAry)>
    <cfset temp = QueryAddColumn(d, "collector", "VarChar",colAry)>
    <cfset temp = QueryAddColumn(d, "determiner", "VarChar",detrAry)>
    <cfset temp = QueryAddColumn(d, "project", "VarChar",projAry)>
    <cfset temp = QueryAddColumn(d, "ala", "VarChar",alaAry)>
    <cfset temp = QueryAddColumn(d, "formatted_attributes", "VarChar",attAry)>
    <cfset temp = QueryAddColumn(d, "identification", "VarChar",identAry)>
     <!---
    <cfreport
        format = "PDF"
        query="d"
        template = "#Application.webDirectory#/Reports/templates/alaLabel.cfr"
        encryption = "none"
        filename = "#Application.webDirectory#/temp/alaLabel.pdf"
        overwrite = "yes">
    </cfreport>

<a href="/temp/alaLabel.pdf">Download the PDF</a>
---->
<cfdump var="#d#">
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
