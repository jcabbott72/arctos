
<cfset collection_object_id="587812">
<cfset collection_object_id="587812,587718,587830,587754,587826,587696,587782,587700,587862,587742,587798,587850,587692,587756,587780,587776,641000">
<cfif not isdefined("collection_object_id")>
		<cfabort>
	</cfif>

	
<cfset sql="
	select
		cataloged_item.collection_object_id,
			get_scientific_name_auths(cataloged_item.collection_object_id) sci_name_with_auth,
		concatAcceptedIdentifyingAgent(cataloged_item.collection_object_id) identified_by,
		get_taxonomy(cataloged_item.collection_object_id,'family') family,
		get_taxonomy(cataloged_item.collection_object_id,'scientific_name') tsname,
		get_taxonomy(cataloged_item.collection_object_id,'author_text') auth,
		identification_remarks,
		made_date,
		cat_num,
		state_prov,
		country,
		quad,
		county,
		island,
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
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier') fieldnum,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service accession') npsa,
		concatsingleotherid(cataloged_item.collection_object_id,'U. S. National Park Service catalog') npsc,
		concatsingleotherid(cataloged_item.collection_object_id,'ALAAC') ALAAC,
		verbatim_date,
		habitat_desc,
		habitat,
		associated_species,
		project_name
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
		concatsingleotherid(cataloged_item.collection_object_id,'original identifier')
			">
	<cfquery name="data" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>

<!---- 
	Last label is mussed if there are an odd number of labels
	<cfif  #data.recordcount# mod 2 neq 0>
		<!--- pad on a garbage record --->
		<cfset temp = queryaddrow(data,1)>
		<cfset temp = querysetcell(data,'family','blank filler')>
		
	</cfif>
	--->
	
	
<cfoutput>
	<cfpdfform source="#application.webDirectory#/Reports/templates/alaLabelTemplate.pdf" result="resultStruct" action="read"/>
<cfdump var="#resultStruct#">
<!---

--->
<cfset f=0>
<cfset i=1>
<cfset outPutName="ala_page_">
 <cfloop query="data">
 	
	<cfset coordinates = "">
	<cfif len(#verbatimLatitude#) gt 0 AND len(#verbatimLongitude#) gt 0>
		<cfset coordinates = "#verbatimLatitude# / #verbatimLongitude#">
		<!---
		<cfset coordinates = replace(coordinates,"d","&##176;","all")>
		<cfset coordinates = replace(coordinates,"m","'","all")>
		<cfset coordinates = replace(coordinates,"s","''","all")>
		---->
	</cfif>
	<cfset sna = #sci_name_with_auth#>
	<cfset sna = replace(sna,"<i>",'<Emphasis style="italic">',"all")>
	<cfset sna = replace(sna,"</i>",'</Emphasis>',"all")>
	<cfset sna = replace(sna,"&nbsp;"," ","all")>
	<cfif #collectors# contains ";">
		<Cfset spacePos = find(";",collectors)>
		<cfset thisColl = left(collectors,#SpacePos# - 1)>
		<cfset thisColl = "#thisColl# et al.">
	<cfelse>
		<cfset thisColl = #collectors#>
	</cfif>
	
	<cfset thisDate = "">
	<cftry>
		<cfset thisDate = #dateformat(verbatim_date,"dd mmm yyyy")#>
		<cfcatch>
			<cfset thisDate = #verbatim_date#>
		</cfcatch>
	</cftry>
	<cfset geog="#ucase(state_prov)#">
	<cfif #country# is "United States">
		<cfset geog="#geog#, USA">
	<cfelse>
		<cfset geog="#geog#, #ucase(country)#">
	</cfif>
	<cfset locality="">
	<cfif len(#locality#) gt 0>
		<cfset locality = "#quad# Quad.:">
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
	 <cfif right(locality,1) is not "."><cfset locality = "#locality#."></cfif>
	 <cfset collector="#collectors# #fieldnum#">
		<cfset determiner="">
		<cfif #collectors# neq #identified_by# AND #identified_by# is not "unknown">
			<cfset determiner="Det: #identified_by# on #dateformat(made_date,"dd mmm yyyy")#">
		</cfif>
		<cfset project="#project_name#">
		
		<cfif len(#npsa#) gt 0 or len(#npsc#) gt 0>
			<cfif len(#project#) gt 0>
				<cfset project="#project#<br/>">
			</cfif>
			<cfset project="#project#NPS: #npsa# #npsc#">
		</cfif>
		<cfset alaacString="Herbarium, University of Alaska Museum (ALA) accession #alaac#">			
	<cfset f=f+1>
	<cfif f is 5>
		<cfset f=1>
	</cfif>
	<cfset cFile = "#outPutName#_#f#.pdf">
	f is: #f#<br>
	<cfif f is 1>
		<hr>
		cfpdfform action="populate" 
			destination="#application.webDirectory#/Reports/templates/#cFile#"
			source="#application.webDirectory#/Reports/templates/alaLabelTemplate.pdf"
			overwrite="true">
		<br>
	</cfif>
    		cfpdfformparam name="family" value="#family#" index="#f#">
			<!---
			<cfpdfformparam name="geog" value="#geog#" index="#f#">
			<cfpdfformparam name="identification" value="#sna#" index="#f#">
			<cfpdfformparam name="identification_remarks" value="#identification_remarks#" index="#f#">
			<cfpdfformparam name="locality" value="#locality#" index="#f#">
			<cfpdfformparam name="collector" value="#collector#" index="#f#">
			<cfpdfformparam name="colldate" value="#thisDate#" index="#f#">
			<cfpdfformparam name="determiner" value="#determiner#" index="#f#">
			<cfpdfformparam name="project" value="#project#" index="#f#">
			<cfpdfformparam name="alaac" value="#alaacString#" index="#f#">
			--->
			--#i#--<br> --#data.recordcount#--<br>
	<cfif f is 4 OR i is #data.recordcount#>
		/cfpdfform>
		<hr>
	</cfif>
	<cfif f is 1>
		<a href="#application.serverRootUrl#/Reports/templates/#cfile#">#cfile#</a>
	</cfif>


<cfset i=i+1>
</cfloop>
<!---
<cfset filesToMerge=listappend(filesToMerge,"#application.webDirectory#/Reports/templates/temp_#collection_object_id#.pdf",",")>
filesToMerge: #filesToMerge#
 <cfloop list="#filesToMerge#" index="i">
		cfpdfparam source="#i#"
	</cfloop> 
<cfpdf action="merge" destination="#application.webDirectory#/Reports/templates/merged.pdf" overwrite="true">
    <cfloop list="#filesToMerge#" index="i">
		<cfpdfparam source="#i#">
	</cfloop> 
</cfpdf>



<a href="#application.serverRootUrl#/Reports/templates/merged.pdf">merged.pdf</a> 
--->
<!---
				
					
						<td colspan="2"  align="middle" class="times12">
							
						</td>
					</tr>
					<tr>
						<td colspan="2" align="middle" class="times12b">
							
						</td>
					</tr>
					
					
					
				</table>
				<!--- end cell table --->
				</td><!--- end cell cell --->
	
	
	<cfset i=#i#+1>
	<cfset t=#t#+1>	
	</cfloop>
</tr>
</table><!--- close page table --->
	<!-----

	----->
	</cfdocument>
	
	<a href="#Application.ServerRootUrl#/temp/alaLabel.pdf">pdf</a>
	--->
	</cfoutput>
	

