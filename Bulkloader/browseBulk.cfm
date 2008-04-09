<cfinclude template="/includes/_header.cfm">
	<script src="/includes/sorttable.js"></script>
<cfif #action# IS "nothing">
<cfoutput>
<cf_setDataEntryGroups>
<cfset afg = "">
<cfloop list="#adminForUsers#" index="m">
	<cfif len(#afg#) is 0>
		<cfset afg="'#m#'">
	<cfelse>
		<cfset afg="#afg#,'#m#'">
	</cfif>
</cfloop>
<cfif len(#afg#) is 0>
	You are not an admin for any active groups.
	<cfabort>
</cfif>

<cfquery name="ctAccn" datasource="#Application.web_user#">
	select accn from bulkloader where enteredby in (#preservesinglequotes(afg)#) group by accn order by accn
</cfquery>
<span style="font-size:smaller; font-style:italic;">
	You are in the <strong>#inAdminGroups#</strong> group(s), reviewing records entered by the <strong>#adminForGroups#</strong> group(s). 
	<br />Group Members are: <strong>#adminForUsers#</strong>
</span>

<p>Filter records in bulkloader to:</p>


<form name="f" method="post" action="browseBulk.cfm">
	<input type="hidden" name="action" value="viewTable" />
	<label for="enteredby">Entered By</label>
	<select name="enteredby" multiple="multiple" size="4" id="enteredby">
		<option value="#afg#" selected="selected">All</option>
		<cfloop list="#adminForUsers#" index='agent_name'>
			<option value="'#agent_name#'">#agent_name#</option>
		</cfloop>
	</select>
	<label for="accn">Accession</label>
	<select name="accn" multiple="multiple" size="10" id="accn">
		<option value="" selected>All</option>
		<cfloop query="ctAccn">
			<option value="'#accn#'">#accn#</option>
		</cfloop>
	</select>
	<br /><input type="submit" 
				value="View Table"
				class="lnkBtn"
				onmouseover="this.className='lnkBtn btnhov'"
				onmouseout="this.className='lnkBtn'">
 	<br/><input type="button" 
				value="SQL"
				class="lnkBtn"
				onclick="f.action.value='sqlTab';f.submit();">
</form>
</cfoutput>
</cfif>
<!----------------------------------------------------------->
<cfif #action# is "sqlTab">
<cfoutput>
	<cfset sql = "select * from bulkloader where enteredby IN (#enteredby#)">
	<cfif len(#accn#) gt 0>
		<cfset sql = "#sql# AND accn IN (#accn#)">
	</cfif>
	<cfquery name="data" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		#preservesinglequotes(sql)#	
	</cfquery>
	<cfquery name="cNames" datasource="uam_god">
		select column_name from user_tab_cols where table_name='BULKLOADER'
		order by internal_column_id
	</cfquery>

	<table border id="t" class="sortable">
		<tr>
		<cfloop query="cNames">
			<th>#column_name#</th>
			<cfloop query="data">
				<tr>
				<cfquery name="thisRec" dbtype="query">
					select * from data where collection_object_id=#collection_object_id#
				</cfquery>
				<cfloop query="cNames">
					<cfset thisData = evaluate("thisRec." & column_name)>
					<td>#thisData#</td>
				</cfloop>
				</tr>
			</cfloop>
		</cfloop>
		</tr>
	</table>
</cfoutput>
</cfif>
<!-------------------------->
<cfif #action# is "saveGridUpdate">
<cfoutput>
<cfquery name="cNames" datasource="uam_god">
	select column_name from user_tab_cols where table_name='BULKLOADER'
</cfquery>
<cfset ColNameList = valuelist(cNames.column_name)>
<cfset GridName = "blGrid">
<cfset numRows = #ArrayLen(form.blGrid.rowstatus.action)#>
<p></p>there are	#numRows# rows updated
<!--- loop for each record --->
<cfloop from="1" to="#numRows#" index="i">
	<!--- and for each column --->
	<cfset thisCollObjId = evaluate("Form.#GridName#.collection_object_id[#i#]")>
	<cfset sql ='update BULKLOADER SET collection_object_id = #thisCollObjId#'>
	<cfloop index="ColName" list="#ColNameList#">
		<cfset oldValue = evaluate("Form.#GridName#.original.#ColName#[#i#]")>
		<cfset newValue = evaluate("Form.#GridName#.#ColName#[#i#]")>
		<cfif #oldValue# neq #newValue#>
			<cfset sql = "#sql#, #ColName# = '#newValue#'">
		</cfif>
	</cfloop>
	
		<cfset sql ="#sql# WHERE collection_object_id = #thisCollObjId#">
	<cfquery name="up" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
</cfloop>
<cflocation url="browseBulk.cfm?action=viewTable&enteredby=#enteredby#&accn=#accn#">
</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "upBulk">
<cfoutput>
	<cfif len(#loaded#) gt 0 and
		len(#column_name#) gt 0 and
		len(#tValue#) gt 0>	
		<cfset sql="UPDATE bulkloader SET LOADED = ">
		<cfif #loaded# is "NULL">
			<cfset sql="#sql# NULL">
		<cfelse>
			<cfset sql="#sql# '#loaded#'">
		</cfif>
			<cfset sql="#sql# WHERE #column_name#	=
			'#trim(tValue)#' AND
			enteredby IN (#enteredby#)">
		<cfif len(#accn#) gt 0>
			<cfset sql = "#sql# AND accn IN (#accn#)">
		</cfif>
			#preservesinglequotes(sql)#
		<!---
		
		<cfabort>
		--->
		<cfquery name="upBulk" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
			#preservesinglequotes(sql)#
		</cfquery>
	</cfif>

<cflocation url="browseBulk.cfm?action=viewTable&enteredby=#enteredby#&accn=#accn#">
		
</cfoutput>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "viewTable">
<cfoutput>
<cfset sql = "select * from bulkloader
	where enteredby IN (#enteredby#)">
<cfif len(#accn#) gt 0>
	<!----
	<cfset thisAccnList = "">
	<cfloop list="#accn#" index="a" delimiters=",">
		<cfif len(#thisAccnList#) is 0>
			<cfset thisAccnList = "'#a#'">
		<cfelse>
			<cfset thisAccnList = "#thisAccnList#,'#a#'">
		</cfif>
	</cfloop>
	<cfset sql = "#sql# AND accn IN (#preservesinglequotes(thisAccnList)#)">
	---->
	<cfset sql = "#sql# AND accn IN (#accn#)">
	
</cfif>
<cfquery name="data" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	#preservesinglequotes(sql)#	
</cfquery>
<cfquery name="cNames" datasource="uam_god">
	select column_name from user_tab_cols where table_name='BULKLOADER'
	order by internal_column_id
</cfquery>
<div style="background-color:##FFFFCC;">
Roll yer own:
<cfset columnList = "SPEC_LOCALITY,HIGHER_GEOG,ENTEREDBY,LOADED,ACCN,OTHER_ID_NUM_5">

<form name="bulkStuff" method="post" action="browseBulk.cfm">
	<input type="hidden" name="action" value="upBulk" />
	<input type="hidden" name="enteredby" value="#enteredby#" />
	<input type="hidden" name="accn" value="#accn#" />
	UPDATE bulkloader SET LOADED = 
	<select name="loaded" size="1">
		<option value="NULL">NULL</option>
		<option value="FLAGGED BY BULKLOADER EDITOR">FLAGGED BY BULKLOADER EDITOR</option>
		<option value="MARK FOR DELETION">MARK FOR DELETION</option>
	</select>
	<br />WHERE
	<select name="column_name" size="1">
		<CFLOOP list="#columnList#" index="i">
			<option value="#i#">#i#</option>
		</CFLOOP>
	</select>
	= TRIM(
	<input type="text" name="tValue" size="50" />)
	<br />
	<input type="submit" 
				value="Update All Matches"
				class="savBtn"
				onmouseover="this.className='savBtn btnhov'"
				onmouseout="this.className='savBtn'">
</form>
</div>
<hr /><cfset ColNameList = valuelist(cNames.column_name)>
<cfset ColNameList = replace(ColNameList,"COLLECTION_OBJECT_ID","","all")>
<!---
<cfset ColNameList = replace(ColNameList,"LOADED","","all")>
<cfset ColNameList = replace(ColNameList,"ENTEREDBY","","all")>
--->
<hr />There are #data.recordcount# records in this view.
<cfform method="post" action="browseBulk.cfm">
	<cfinput type="hidden" name="action" value="saveGridUpdate">
	<cfinput type="hidden" name="enteredby" value="#enteredby#">
	<cfinput type="hidden" name="accn" value="#accn#">
	<cfgrid query="data"  name="blGrid" width="1200" height="400" selectmode="edit">
		<cfgridcolumn name="collection_object_id" select="no" href="/DataEntry.cfm?action=editEnterData&ImAGod=yes&pMode=edit" hrefkey="collection_object_id" target="_blank">
		<!----
		<cfgridcolumn name="loaded" select="yes">
		<cfgridcolumn name="ENTEREDBY" select="yes">
		---->
		<cfloop list="#ColNameList#" index="thisName">
			<cfgridcolumn name="#thisName#">
		</cfloop>
	<cfinput type="submit" name="save" value="Save Changes In Grid">
	</cfgrid>
</cfform>

</cfoutput>
</cfif>
<cfinclude template="/includes/_footer.cfm">