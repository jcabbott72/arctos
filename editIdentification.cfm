<cfinclude template="/includes/_frameHeader.cfm">
	<script language="JavaScript" src="/includes/CalendarPopup.js" type="text/javascript"></script>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">
		var cal1 = new CalendarPopup("theCalendar");
		cal1.showYearNavigation();
		cal1.showYearNavigationInput();
	</SCRIPT>
	<SCRIPT LANGUAGE="JavaScript" type="text/javascript">document.write(getCalendarStyles());</SCRIPT>



<script type='text/javascript' src='/includes/_editIdentification.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.field.js'></script>
<script type='text/javascript' src='/includes/jquery/jquery.form.js'></script>

<script type="text/javascript" language="javascript">
jQuery( function($) {
	setInterval(checkRequired,500);
});
function checkRequired(){	
	// loop over all the forms...
	$('form').each(function(){
		var fid=this.id;
		var hasIssues=0;
		var allFormObjs = $('#' + fid).formSerialize();
		var AFA=allFormObjs.split('&');
		for (i=0;i<AFA.length;i++){
			var fp=AFA[i].split('=');
			var ffName=fp[0];
			var ffVal=fp[1];
			var ffClass=$("#" + ffName).attr('class');
			if (ffClass=='reqdClr' && ffVal==''){
				hasIssues+=1;
			}
		}
		// get the form submit
		// REQUIREMENT: form dubmit button has id of formID + _submit
		//REQUIREMENT: form submit has a title
		var sbmBtnStr=fid + "_submit";
		var sbmBtn=document.getElementById(sbmBtnStr);
		var v=sbmBtn.value;
		if (hasIssues > 0) {
			// form is NOT ready for submission
			document.getElementById(fid).setAttribute('onsubmit',"return false");
			sbmBtn.value="Not ready...";		
		} else {
			document.getElementById(fid).removeAttribute('onsubmit');
			sbmBtn.value=sbmBtn.title;	
		}
	});
}


</script>
</div><!--- kill content div --->
<!----------------------------------------------------------------------------------->

<cfif #Action# is "nothing">
<cfoutput>
<cfquery name="ctnature" datasource="#Application.web_user#">
	select nature_of_id from ctnature_of_id
</cfquery>
<cfquery name="ctFormula" datasource="#Application.web_user#">
	select taxa_formula from cttaxa_formula order by taxa_formula
</cfquery>
<cfquery name="getID" datasource="#Application.web_user#">
	SELECT
		identification.identification_id,
		institution_acronym,
		identification.scientific_name, 
		cat_num, 
		cataloged_item.collection_cde, 
		agent_name,
		identifier_order,
		identification_agent.agent_id,
		made_date,
		nature_of_id, 
		accepted_id_fg, 
		identification_remarks,
		identification_agent_id
	FROM 
		cataloged_item, 
		identification,
		collection ,
		identification_agent,
		preferred_agent_name
	WHERE 
		identification.collection_object_id = cataloged_item.collection_object_id AND
		identification.identification_id = identification_agent.identification_id (+) AND
		identification_agent.agent_id = preferred_agent_name.agent_id (+) AND
		cataloged_item.collection_id=collection.collection_id AND
		cataloged_item.collection_object_id = #collection_object_id#
		ORDER BY accepted_id_fg
	DESC
</cfquery>

<table class="newRec">
 <tr>
 	<td colspan="2">
	
<strong><font size="+1">Add new Determination</font></strong>&nbsp;
<a href="javascript:void(0);" onClick="getDocs('identification')"><img src="/images/info.gif" border="0"></a>
	</td>
 </tr>
<form name="newID" id="newID" method="post" action="editIdentification.cfm">
    <input type="hidden" name="Action" value="createNew">
    <input type="hidden" name="collection_object_id" value="#collection_object_id#" >
    <tr>
		<td>
			<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_formula')">ID Formula:</a>
		</td>
		<td>
			<cfif not isdefined("taxa_formula")>
				<cfset taxa_formula='A'>
			</cfif>
			<cfset thisForm = "#taxa_formula#">
			<select name="taxa_formula" id="taxa_formula" size="1" class="reqdClr"
				onchange="newIdFormula(this.value);">
					<cfloop query="ctFormula">
						<cfif #ctFormula.taxa_formula# is "A">
							<cfset thisDispVal = "one taxon">
						<cfelseif #ctFormula.taxa_formula# is "A ?">
							<cfset thisDispVal = 'taxon + "?"'>
						<cfelseif #ctFormula.taxa_formula# is "A or B">
							<cfset thisDispVal = 'A "or" B'>
						<cfelseif #ctFormula.taxa_formula# is "A / B intergrade">
							<cfset thisDispVal = 'A / B intergrade'>
						<cfelseif #ctFormula.taxa_formula# is "A x B">
							<cfset thisDispVal = 'A "x" B'>
						<cfelseif #ctFormula.taxa_formula# is "A and B">
							<cfset thisDispVal = 'A "and" B'>
						<cfelseif #ctFormula.taxa_formula# is "A sp.">
							<cfset thisDispVal = 'A "sp."'>
						<cfelseif #ctFormula.taxa_formula# is "A cf.">
							<cfset thisDispVal = 'A "cf."'>
						<cfelseif #ctFormula.taxa_formula# is "A aff.">
							<cfset thisDispVal = 'A "aff."'>
						<cfelseif #ctFormula.taxa_formula# is "A ssp.">
							<cfset thisDispVal = 'A "ssp."'>
						<cfelse>
							<cfset thisDispVal = "ERROR!!!">
						</cfif>
						<option 
							<cfif #thisForm# is "#ctFormula.taxa_formula#"> selected </cfif>value="#ctFormula.taxa_formula#">#thisDispVal#</option>
					</cfloop>
			</select>
		</td>
	</tr>     
	<tr> 
    	<td>
			<div align="right">Taxon A:</div>
		</td>
         <td>
		  	<input type="text" name="taxa_a" id="taxa_a" class="reqdClr" size="50" 
				onChange="taxaPick('TaxonAID','taxa_a','newID',this.value); return false;"
				onKeyPress="return noenter(event);">
			<input type="hidden" name="TaxonAID" id="TaxonAID" class="reqdClr"> 
		</td>
  	</tr>
	<tr id="taxon_b_row" style="display:none;"> 
    	<td>
			<div align="right">Taxon B:</div>
		</td>
        <td>
			<input type="text" name="taxa_b" id="taxa_b"  size="50" 
				onChange="taxaPick('TaxonBID','taxa_b','newID',this.value); return false;"
				onKeyPress="return noenter(event);">
			<input type="hidden" name="TaxonBID" id="TaxonBID">
		</td>
  	</tr>
    <tr> 
    	<td>
			<div align="right">
				<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_by')">ID By:</a>
			</div>
		</td>
        <td>
			<input type="text" name="idBy" id="idBy" class="reqdClr" size="50" 
				onchange="getAgent('newIdById','idBy','newID',this.value); return false;"
			  	onkeypress="return noenter(event);"> 
            <input type="hidden" name="newIdById" id="newIdById" class="reqdClr"> 
			<span class="infoLink" onclick="addNewIdBy('two');">more...</span>
		</td>
	</tr>
	<tr id="addNewIdBy_two" style="display:none;"> 
    	<td>
			<div align="right">
				ID By:<span class="infoLink" onclick="clearNewIdBy('two');"> remove</span>	
			</div>
		</td>
        <td>
			<input type="text" name="idBy_two" id="idBy_two" size="50" 
				onchange="getAgent('newIdById_two','idBy_two','newID',this.value); return false;"
			  	onkeypress="return noenter(event);"> 
            <input type="hidden" name="newIdById_two" id="newIdById_two"> 
			<span class="infoLink" onclick="addNewIdBy('three');">more...</span>			
		 </td>
	</tr>
    <tr id="addNewIdBy_three" style="display:none;"> 
    	<td>
			<div align="right">
				ID By:<span class="infoLink" onclick="clearNewIdBy('three');"> remove</span>	
			</div>
		</td>
        <td>
			<input type="text" name="idBy_three" id="idBy_three"  size="50" 
			 	onchange="getAgent('newIdById_three','idBy_three','newID',this.value); return false;"
			 	onkeypress="return noenter(event);"> 
            <input type="hidden" name="newIdById_three" id="newIdById_three"> 			
		 </td>
    </tr>
    <tr> 
    	<td>
			<div align="right">
				<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','id_date')">ID Date:</a></td>
			 </div>
		</td>
        <td>
			<input type="text" name="made_date" id="made_date"
				onclick="cal1.select(document.newID.made_date,'anchor1','dd-MMM-yyyy');">
				<a name="anchor1" id="anchor1"></a>						
		</td>
	</tr>
    <tr> 
    	<td>
			<div align="right">
				<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','nature_of_id')"> Nature of ID:</a>
			</div>
		</td>
		<td>
			<select name="nature_of_id" id="nature_of_id" size="1" class="reqdClr">
            	<cfloop query="ctnature">
                	<option  value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
                </cfloop>
            </select>
			<span class="infoLink" onClick="getCtDoc('ctnature_of_id',newID.nature_of_id.value)">Define</span>
		</td>
	</tr>
    <tr> 
    	<td>
			<div align="right">Remarks:</div>
		</td>
        <td>
			<input type="text" name="identification_remarks" id="identification_remarks" size="50">
		</td>
    </tr>
    <tr>
		<td colspan="2">
			<div align="center"> 
            	<input type="submit" id="newID_submit" value="Create" class="insBtn" title="Create Identification">	
             </div>
		</td>
    </tr>
</form>
</table>







<strong><font size="+1">Edit an Existing Determination</font></strong>
<img src="/images/info.gif" border="0" onClick="getDocs('identification')" class="likeLink">
<cfset i = 1>
<table border>
<cfquery name="distIds" dbtype="query">
	SELECT
		identification_id,
		institution_acronym,
		scientific_name, 
		cat_num, 
		collection_cde, 
		made_date,
		nature_of_id, 
		accepted_id_fg, 
		identification_remarks
	FROM 
		getID
	GROUP BY
		identification_id,
		institution_acronym,
		scientific_name, 
		cat_num, 
		collection_cde, 
		made_date,
		nature_of_id, 
		accepted_id_fg, 
		identification_remarks
	ORDER BY 
		accepted_id_fg DESC,
		made_date
</cfquery>
<form name="editIdentification" id="editIdentification" method="post" action="editIdentification.cfm">
    <input type="hidden" name="Action" value="saveEdits">
    <input type="hidden" name="collection_object_id" value="#collection_object_id#" >
	<input type="hidden" name="number_of_ids" id="number_of_ids" value="#distIds.recordcount#">
<cfloop query="distIds">
	<tr #iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#><td>
	<cfquery name="identifiers" dbtype="query">
		select 
			agent_name,
			identifier_order,
			agent_id,
			identification_agent_id
		FROM
			getID
		WHERE
			identification_id=#identification_id#
		group by
			agent_name,
			identifier_order,
			agent_id,
			identification_agent_id
		ORDER BY
			identifier_order
	</cfquery>
	<cfset thisIdentification_id = #identification_id#>
	<input type="hidden" name="identification_id_#i#" id="identification_id_#i#" value="#identification_id#">
	<input type="hidden" name="number_of_identifiers_#i#" id="number_of_identifiers_#i#" 
			value="#identifiers.recordcount#">
	<table id="mainTable_#i#">
    	<tr> 
        	<td><div align="right">Scientific Name:</div></td>
            <td><b><i>#scientific_name#</i></b></td>
        </tr>
        <tr> 
        	<td><div align="right">Accepted?:</div></td>
			<td>
				
				<cfif #accepted_id_fg# is 0>
					<select name="accepted_id_fg_#i#" 
						id="accepted_id_fg_#i#" size="1" 
						class="reqdClr">
						<option value="1"
							<cfif #ACCEPTED_ID_FG# is 1> selected </cfif>>yes</option>
                    	<option 
							<cfif #accepted_id_fg# is 0> selected </cfif>value="0">no</option>
						<cfif #ACCEPTED_ID_FG# is 0>
							<option value="delete">DELETE</option>
						</cfif>
                  	</select>
					<cfif #ACCEPTED_ID_FG# is 0>
						<span class="infoLink" onclick="document.getElementById('accepted_id_fg_#i#').value='delete';">Delete</span>
					</cfif>
				<cfelse>
					<input name="accepted_id_fg_#i#" id="accepted_id_fg_#i#" type="hidden" value="1">
					<b>Yes</b>
				</cfif>
			</td>					
       	</tr>
        <tr>
			<td colspan="2">
				<table id="identifierTable_#i#">
					<tbody id="identifierTableBody_#i#">
						<cfset idnum=1>
						<cfloop query="identifiers">
							<tr id="IdTr_#i#_#idnum#">
								<td>Identified By:</td>
								<td>
									<input type="text" 
										name="IdBy_#i#_#idnum#" 
										id="IdBy_#i#_#idnum#" 
										value="#agent_name#" 
										class="reqdClr"
										size="50" 
										onchange="
										getAgent('IdById_#i#_#idnum#','IdBy_#i#_#idnum#','editIdentification',this.value); return false;"
							 			onKeyPress="return noenter(event);"> 
									<input type="hidden" 
										name="IdById_#i#_#idnum#" 
										id="IdById_#i#_#idnum#" value="#agent_id#"
										class="reqdClr">
									<input type="hidden" name="identification_agent_id_#i#_#idnum#" id="identification_agent_id_#i#_#idnum#"
										value="#identification_agent_id#">
									<cfif #idnum# gt 1>
										<img src="/images/del.gif" class="likeLink" 
											onclick="removeIdentifier('#i#','#idnum#')" />
									</cfif>
				 				</td>
				 			</tr>
							<cfset idnum=idnum+1>
						</cfloop>
					</tbody>
				</table>
			</td>
		</tr>
        <tr>
			<td>
				<span class="infoLink" id="addIdentifier_#i#" 
					onclick="addIdentifier('#i#','#idnum#')">Add Identifier</span>
			</td>	
		</tr>
		<tr> 
        	<td>
				<div align="right">
					<a href="javascript:void(0);" class="novisit" 
						onClick="getDocs('identification','id_date')">ID Date:</a>
				</div>
			</td>
            <td>
				<input type="text" value="#dateformat(made_date,'dd-mmm-yyyy')#" name="made_date_#i#"
				 id="made_date_#i#"
				 onclick="cal1.select(document.editIdentification.made_date_#i#,'anchor1#i#','dd-MMM-yyyy');">
				<a name="anchor1#i#" id="anchor1#i#"></a>
           </td>
              </tr>
              <tr> 
                <td><div align="right">
				<a href="javascript:void(0);" class="novisit" onClick="getDocs('identification','nature_of_id')"> Nature of ID:</a></td>
				</div></td>
                <td>
				<cfset thisID = #nature_of_id#>
				<select name="nature_of_id_#i#" id="nature_of_id_#i#" size="1" class="reqdClr" onchange="saveNatureOfId('#i#', this.value);">
                    <cfloop query="ctnature">
                      <option <cfif #ctnature.nature_of_id# is #thisID#> selected </cfif> value="#ctnature.nature_of_id#">#ctnature.nature_of_id#</option>
                    </cfloop>
                  </select>
			<span class="infoLink" onClick="getCtDoc('ctnature_of_id',newID.nature_of_id.value)">Define</span>
				</td>
              </tr>
              <tr> 
                <td><div align="right">Remarks:</div></td>
                <td><input type="text" name="identification_remarks_#i#" id="identification_remarks_#i#" value="#identification_remarks#" size="50" onchange="saveIdRemarks('#i#', this.value);"></td>
              </tr>
			</table>
           

	<cfset i = #i#+1>
	</td></tr>
</cfloop>
<tr>
				<td>
					<input type="submit" class="savBtn" id="editIdentification_submit" value="Save Changes" title="Save Changes">
				</td>
			</tr>
            </table>
			      </form>
			      
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->
<cfif #Action# is "saveEdits">

<cfoutput>
	<cftransaction>
		<cfloop from="1" to="#NUMBER_OF_IDS#" index="n">
			<cfset thisAcceptedIdFg = #evaluate("ACCEPTED_ID_FG_" & n)#>
			<cfset thisIdentificationId = #evaluate("IDENTIFICATION_ID_" & n)#>
			<cfset thisIdRemark = #evaluate("IDENTIFICATION_REMARKS_" & n)#>
			<cfset thisMadeDate = #evaluate("MADE_DATE_" & n)#>
			<cfset thisNature = #evaluate("NATURE_OF_ID_" & n)#>
			<cfset thisNumIds = #evaluate("NUMBER_OF_IDENTIFIERS_" & n)#>
			
	
			<cfif #thisAcceptedIdFg# is 1>
				<cfquery name="upOldID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #collection_object_id#
				</cfquery>
				<cfquery name="newAcceptedId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					UPDATE identification SET ACCEPTED_ID_FG=1 where identification_id = #thisIdentificationId#
				</cfquery>
			</cfif>
			<cfquery name="updateId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
					UPDATE identification SET
					nature_of_id = '#thisNature#'
					<cfif len(#thisMadeDate#) gt 0>
						,made_date = '#dateformat(thisMadeDate,'dd-mmm-yyyy')#'
					<cfelse>
						,made_date=NULL
					</cfif>
					<cfif len(#thisIdRemark#) gt 0>
						,identification_remarks = '#thisIdRemark#'
					<cfelse>
						,identification_remarks = NULL
					</cfif>
				where identification_id=#thisIdentificationId#
			</cfquery>
			<cfloop from="1" to="#thisNumIds#" index="nid">
				<cftry>
					<!--- couter does not increment backwards - may be a few empty loops in here ---->
					<cfset thisIdId = evaluate("IdById_" & n & "_" & nid)>
					<cfcatch>
						<cfset thisIdId =-1>
					</cfcatch>
				</cftry>
				<cftry>
					<cfset thisIdAgntId = evaluate("identification_agent_id_" & n & "_" & nid)>
					<cfcatch>
						<cfset thisIdAgntId=-1>
					</cfcatch>
				</cftry>
				<cfif #thisIdAgntId# is -1 and (thisIdId is not "delete" and thisIdId gt 0)>
					<!--- new identifier --->
					<cfquery name="updateIdA" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
						insert into identification_agent 
							( IDENTIFICATION_ID,AGENT_ID,IDENTIFIER_ORDER)
						values 
							(
								#thisIdentificationId#,
								#thisIdId#,
								#nid#
							)
					</cfquery>
				<cfelse>
					<!--- update or delete --->
					<cfif #thisIdId# is "delete">
						<!--- delete --->
						<cfquery name="updateIdA" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
							delete from identification_agent
							where identification_agent_id=#thisIdAgntId#				
						</cfquery>
					<cfelseif thisIdId gt 0>
						<!--- update --->
						<cfquery name="updateIdA" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
							update identification_agent set 
								agent_id=#thisIdId#,
								identifier_order=#nid#
							 where
							 	identification_agent_id=#thisIdAgntId#
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
	</cftransaction>
	<cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cfif #Action# is "deleteIdent">
	<cfif #accepted_id_fg# is "1">
		<font color="#FF0000" size="+1">You can't delete the accepted identification!</font> 
		<cfabort>
    </cfif>
	<cftransaction>
		<cfquery name="deleteId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			DELETE FROM identification WHERE identification_id = #identification_id#
		</cfquery>
		<cfquery name="deleteTId" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			DELETE FROM identification_taxonomy WHERE identification_id = #identification_id#
		</cfquery>
	</cftransaction>
	<cf_logEdit collection_object_id="#collection_object_id#">
  <cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
</cfif>
<!----------------------------------------------------------------------------------->

<!--------------------------------------------------------------------------------------------------->
<cfif #Action# is "multi">
<cfoutput>
	<cflocation url="multiIdentification.cfm?collection_object_id=#collection_object_id#" addtoken="false">
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->





<!----------------------------------------------------------------------------------->
<cfif #Action# is "createNew">
<cfquery name="nextID" datasource="#Application.web_user#">
	select max(identification_id) + 1 as nextID from identification
</cfquery>
<cfoutput>
<cfif #taxa_formula# is "A">
	<cfset scientific_name = "#taxa_a#">
<cfelseif #taxa_formula# is "A or B">
	<cfset scientific_name = "#taxa_a# or #taxa_b#">
<cfelseif #taxa_formula# is "A and B">
	<cfset scientific_name = "#taxa_a# and #taxa_b#">
<cfelseif #taxa_formula# is "A x B">
	<cfset scientific_name = "#taxa_a# x #taxa_b#">
<cfelseif #taxa_formula# is "A ?">
		<cfset scientific_name = "#taxa_a# ?">
<cfelseif #taxa_formula# is "A sp.">
		<cfset scientific_name = "#taxa_a# sp.">

<cfelseif #taxa_formula# is "A ssp.">
		<cfset scientific_name = "#taxa_a# ssp.">
<cfelseif #taxa_formula# is "A cf.">
		<cfset scientific_name = "#taxa_a# cf.">
<cfelseif #taxa_formula# is "A aff.">
	<cfset scientific_name = "#taxa_a# aff.">
<cfelseif #taxa_formula# is "A / B intergrade">
	<cfset scientific_name = "#taxa_a# / #taxa_b# intergrade">
<cfelse>
	The taxa formula you entered isn't handled yet! Please submit a bug report.
	<cfabort>
</cfif>
<!--- set all IDs to not accepted for this item --->



<cftransaction>
	<cfquery name="upOldID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		UPDATE identification SET ACCEPTED_ID_FG=0 where collection_object_id = #collection_object_id#
	</cfquery>
	
	<cfquery name="newID" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	INSERT INTO identification (
		IDENTIFICATION_ID,
		COLLECTION_OBJECT_ID
		<cfif len(#MADE_DATE#) gt 0>
			,MADE_DATE
		</cfif>
		,NATURE_OF_ID
		 ,ACCEPTED_ID_FG
		 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
			,IDENTIFICATION_REMARKS
		</cfif>
		,taxa_formula
		,scientific_name,
		id_made_by_agent_id)
	VALUES (
		#nextID.nextID#,
		#COLLECTION_OBJECT_ID#
		<cfif len(#MADE_DATE#) gt 0>
			,'#dateformat(MADE_DATE,"dd-mmm-yyyy")#'
		</cfif>
		,'#NATURE_OF_ID#'
		 ,1
		 <cfif len(#IDENTIFICATION_REMARKS#) gt 0>
			,'#IDENTIFICATION_REMARKS#'
		</cfif>
		,'#taxa_formula#'
		,'#scientific_name#',
		#newIdById#)
		 </cfquery>
		<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			insert into identification_agent (
				identification_id,
				agent_id,
				identifier_order) 
			values (
				#nextID.nextID#,
				#newIdById#,
				1
				)
		</cfquery>
		 <cfif len(#newIdById_two#) gt 0>
		 	<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into identification_agent (
					identification_id,
					agent_id,
					identifier_order) 
				values (
					#nextID.nextID#,
					#newIdById_two#,
					2
					)
			</cfquery>
		 </cfif>
		 <cfif len(#newIdById_three#) gt 0>
		 	<cfquery name="newIdAgent" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				insert into identification_agent (
					identification_id,
					agent_id,
					identifier_order) 
				values (
					#nextID.nextID#,
					#newIdById_three#,
					3
					)
			</cfquery>
		 </cfif>
		
		 <cfquery name="newId2" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		 	INSERT INTO identification_taxonomy (
				identification_id,
				taxon_name_id,
				variable)
			VALUES (
				#nextID.nextID#,
				#TaxonAID#,
				'A')
		 </cfquery>
		
		 <cfif #taxa_formula# contains "B">
			 <cfquery name="newId3" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
				INSERT INTO identification_taxonomy (
					identification_id,
					taxon_name_id,
					variable)
				VALUES (
					#nextID.nextID#,
					#TaxonBID#,
					'B')
			 </cfquery>
		 </cfif>
		
		<!--- make the newest ID accepted --->
		<cfquery name="oneAcc" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			update identification set ACCEPTED_ID_FG=1 where identification_id=#nextID.nextID#
		</cfquery>	 
</cftransaction>
		 <cf_logEdit collection_object_id="#COLLECTION_OBJECT_ID#">

	<cflocation url="editIdentification.cfm?collection_object_id=#collection_object_id#">
	
</cfoutput>
</cfif>
<!----------------------------------------------------------------------------------->

<!---
<cfoutput>
<script type="text/javascript" language="javascript">
	changeStyle('#getID.institution_acronym#');
	parent.dyniframesize();
</script>
</cfoutput>
--->

	<cfinclude template="includes/_pickFooter.cfm">
</div>

<script>
	parent.dyniframesize();
</script>


<DIV ID="theCalendar" STYLE="position:absolute;visibility:hidden;background-color:white;layer-background-color:white;"></DIV>