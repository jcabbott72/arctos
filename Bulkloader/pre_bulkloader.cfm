<cfinclude template="/includes/_header.cfm">
<cfoutput>
	<cfset title="bulkloader pre-bulkloader">
	<cfif action is "nothing">
		Pre-bulkloader magic lives here.
		<p>
			This app is in early beta. Lots of stuff won't work. Some stuff will probably make messes.
			Make backups of your backups at every step.
			<p>
				<a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulkloader">grab a copy of your data here</a>
			</p>
		</p>

		<p>
			This form will NOT deal with multi-agent strings ("collector=you and me"). Split them out (there are agent tools) and load them
			as collector_agent_1=you,collector_agent_2=me, then use this form to download, standardize, and repatriate.
		</p>
		<p>
			Very few datasets will need everything in there.
		</p>
		<p>
			This may require iterative processes, eg, load, download geography, realize you have a giant mess, delete, fix your mess,
			load, download geography, rinse and repeat.
		</p>
		<p>
			File an Issue if we've missed something.
		</p>
		<p>
			This form deals in controlled data. Check code tables. All of Arctos is bitwise-indexed; characters that you cannot see still
			matter, values are case-sensitive, etc. Much of Arctos is data-driven - acceptable values for "attribute_value_x" depend on
			what's in "attribute_x."
		</p>
		<cfquery name="sts" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select loaded,enteredby,count(*) numrecs from pre_bulkloader group by loaded,enteredby
		</cfquery>
		<p>
			Currrent state of pre-bulkloader:
			<cfdump var=#sts#>
		</p>
		<p>Howto:</p>

		<ol>
			<li><a href="pre_bulkloader.cfm?action=deleteAll">Clear out the pre-bulkloader</a>. Use with caution. Be courteous.</li>
			<li>
				Get your data into pre-bulkloader. The specimen bulkloader will push here. Dirty data is fine - that's the point.
				This form will do nothing for poorly-structured data (multi-agent strings, etc.).
			</li>
			<li><a href="pre_bulkloader.cfm?action=nullLoaded">NULLify loaded</a>.</li>
			<li>Grab a donut. It'll take a while.</li>
			<li><a href="pre_bulkloader.cfm?action=checkStatus">checkStatus</a>. The checks are done when ALL loaded=init_pull_complete</li>

			<cfset tbls="pre_bulk_agent,pre_bulk_taxa,pre_bulk_attributes,pre_bulk_oidt,pre_bulk_date,pre_bulk_parts">
			<cfset tbls=tbls & ",pre_bulk_disposition,pre_bulk_collrole,pre_bulk_accn,pre_bulk_geog,pre_bulk_NATURE_OF_ID,">
			<cfset tbls=tbls & "pre_bulk_ORIG_LAT_LONG_UNITS,pre_bulk_GEOREFERENCE_PROTOCOL,pre_bulk_VERIFICATIONSTATUS,pre_bulk_MAX_ERROR_UNITS">
			<cfset tbls=tbls & "pre_bulk_COLLECTING_SOURCE,pre_bulk_DEPTH_UNITS,pre_bulk_DATUM">
			<li>
				Download Tables. Fill in shouldbe, reload below. Some table contain collection_cde, which will be ignored.
				<br>Do not edit the original column or replace will fail.
				<br>There are many agent cleanup tools in Arctos; use them, or contact a DBA for help.
				<br>There is a geography lookup/translation tool in Arctos; use it.
			<cfloop list="#tbls#" index="tbl">
				<ul>
					<li>
						Download <a href="/Admin/CSVAnyTable.cfm?tableName=#tbl#">#tbl#</a>
					</li>
				</ul>
			</cfloop>
			</li>
			<li>Fill in the blanks,then reload the lookup files.</li>
			<li>
				<cfloop list="#tbls#" index="tbl">
					<ul>
						<li>
							<a name="u_#tbl#"></a>
							<form name="up#tbl#" method="post" enctype="multipart/form-data" action="pre_bulkloader.cfm">
								<input type="hidden" name="action" value="getFile">
								<input type="hidden" name="table" value="#tbl#">
								<label for="FiletoUpload">Upload #tbl#</label>
								<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
								<input type="submit" value="Upload CSV" class="savBtn">
							 </form>
						</li>
					</ul>
				</cfloop>
			</li>

			<li>
				 <a href="pre_bulkloader.cfm?action=repatriate">repatriate the stuff you just re-loaded</a>
			</li>
			<li>
				Grab another donut. It'll take a while for the scripts to run.
			</li>
			<li><a href="pre_bulkloader.cfm?action=checkStatus">checkStatus</a>. The repatriation is done when ALL loaded=repatriation_complete</li>
			<li>
				<cfset dfltnls=StructNew()>
				<cfset dfltnls.COLLECTOR_AGENT_1="unknown">
				<cfset dfltnls.COLLECTOR_ROLE_1="collector">
				<cfset dfltnls.EVENT_ASSIGNED_DATE="#dateformat(now(),'yyyy-mm-dd')#">

				<cfloop collection = #dfltnls# item = "fld">
					<br>#fld#: #StructFind(dfltnls, fld)#
				</cfloop>

					<cfset dflts=",,,EVENT_ASSIGNED_BY_AGENT,ID_MADE_BY_AGENT">
		<cfset dflts=dflts & ",SPECIMEN_EVENT_TYPE,PART_NAME_1,VERIFICATIONSTATUS,NATURE_OF_ID">
		<cfset dflts=dflts & ",MADE_DATE,BEGAN_DATE,ENDED_DATE,VERBATIM_DATE,">
		<cfset dflts=dflts & ",HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY">

        employee.firstname = Form.firstname;
				Set defaults. ONLY when the following values are NULL, update them to...
				<br>(Clear the suggestion to do nothing.)
				<form name="dflt" method="post" action="pre_bulkloader.cfm">
					<input type="hidden" name="action" value="setNullDefaults">
					UPDATE pre_bulkloader SET
					<label for="NATURE_OF_ID">NATURE_OF_ID=</label>
					<input type="text" name="NATURE_OF_ID" value="legacy">,
					<label for="ID_MADE_BY_AGENT">ID_MADE_BY_AGENT=</label>
					<input type="text" name="ID_MADE_BY_AGENT" value="unknown">,
					<label for="MADE_DATE">MADE_DATE=</label>
					<input type="text" name="MADE_DATE" value="#dateform(now(),'yyyy-mm-dd')#">,
					<label for="VERBATIM_DATE">VERBATIM_DATE=</label>
					<input type="text" name="VERBATIM_DATE" value="before #dateform(now(),'yyyy-mm-dd')#">,
					<label for="BEGAN_DATE">BEGAN_DATE=</label>
					<input type="text" name="BEGAN_DATE" value="1800">,
					<label for="ENDED_DATE">ENDED_DATE=</label>
					<input type="text" name="ENDED_DATE" value="#dateform(now(),'yyyy-mm-dd')#">,
					<label for="HIGHER_GEOG">HIGHER_GEOG=</label>
					<input type="text" name="HIGHER_GEOG" value="no higher geography recorded">,
					<label for="SPEC_LOCALITY">SPEC_LOCALITY=</label>
					<input type="text" name="SPEC_LOCALITY" value="no specific locality recorded">,
					<label for="VERBATIM_LOCALITY">VERBATIM_LOCALITY=</label>
					<input type="text" name="VERBATIM_LOCALITY" value="no verbatim locality recorded">,
					<label for="EVENT_ASSIGNED_BY_AGENT">EVENT_ASSIGNED_BY_AGENT=</label>
					<input type="text" name="EVENT_ASSIGNED_BY_AGENT" value="unknown">,
					<label for="EVENT_ASSIGNED_DATE">EVENT_ASSIGNED_DATE=</label>
					<input type="text" name="EVENT_ASSIGNED_DATE" value="#dateform(now(),'yyyy-mm-dd')#">,
					<label for="VERIFICATIONSTATUS">VERIFICATIONSTATUS=</label>
					<input type="text" name="VERIFICATIONSTATUS" value="unverified">,
					<label for="COLLECTOR_AGENT_1">COLLECTOR_AGENT_1=</label>
					<input type="text" name="COLLECTOR_AGENT_1" value="unknown">,
					<label for="COLLECTOR_ROLE_1">COLLECTOR_ROLE_1=</label>
					<input type="text" name="COLLECTOR_ROLE_1" value="collector">,
					<label for="PART_NAME_1">PART_NAME_1=</label>
					<input type="text" name="PART_NAME_1" value="unknown">,
					<label for="SPECIMEN_EVENT_TYPE">SPECIMEN_EVENT_TYPE=</label>
					<input type="text" name="SPECIMEN_EVENT_TYPE" value="accepted place of collection">
				</form>
			</li>


					<label for="PART_CONDITION_1">PART_CONDITION_1=</label>
					<input type="text" name="PART_CONDITION_1" value="unknown">,


,,,,,,,,,,,,GUID_PREFIX,,,PART_LOT_COUNT_1,PART_DISPOSITION_1,



		</ol>


	</cfif>



				<form name="dflt" method="post" action="pre_bulkloader.cfm">
					<input type="hidden" name="action" value="">
					UPDATE pre_bulkloader SET


					<label for="">HIGHER_GEOG=</label>
					<input type="text" name="HIGHER_GEOG" value="no higher geography recorded">,
					<label for="">SPEC_LOCALITY=</label>
					<input type="text" name="SPEC_LOCALITY" value="no specific locality recorded">,
					<label for="">VERBATIM_LOCALITY=</label>
					<input type="text" name="VERBATIM_LOCALITY" value="no verbatim locality recorded">,


	<!------------------------------------------------------->
	<cfif action is "setNullDefaults">
		<cfset dflts="COLLECTOR_ROLE_1,COLLECTOR_AGENT_1,EVENT_ASSIGNED_DATE,EVENT_ASSIGNED_BY_AGENT,ID_MADE_BY_AGENT">
		<cfset dflts=dflts & ",SPECIMEN_EVENT_TYPE,PART_NAME_1,VERIFICATIONSTATUS,NATURE_OF_ID">
		<cfset dflts=dflts & ",MADE_DATE,BEGAN_DATE,ENDED_DATE,VERBATIM_DATE,">
		<cfset dflts=dflts & ",HIGHER_GEOG,SPEC_LOCALITY,VERBATIM_LOCALITY">
		<cfset dflts=dflts & ",">
		<cfset dflts=dflts & ",">
		<cfquery name="nullLoaded" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_bulkloader set loaded='go_go_gadget_repatriate'
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>

	<!------------------------------------------------------->
	<cfif action is "repatriate">
		<cfquery name="nullLoaded" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_bulkloader set loaded='go_go_gadget_repatriate'
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>

	<!------------------------------------------------------->
	<cfif action is "getFile">
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
        <cfset  util = CreateObject("component","component.utilities")>
		<cfset x=util.CSVToQuery(fileContent)>
        <cfset cols=x.columnlist>
		<cftransaction>
	        <cfloop query="x">
	            <cfquery name="ins" datasource="uam_god">
		            insert into #table# (#cols#) values (
		            <cfloop list="#cols#" index="i">
		            	'#escapeQuotes(evaluate(i))#'
		            	<cfif i is not listlast(cols)>
		            		,
		            	</cfif>
		            </cfloop>
		            )
	            </cfquery>
	        </cfloop>
		</cftransaction>
		loaded to #table# <a href="pre_bulkloader.cfm?action=nothing##u_#table#">return</a>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "uDATUM">
		<cfquery name="q" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			create table pre_bulk_datum as select distinct DATUM from pre_bulkloader where DATUM not in (select DATUM from CTDATUM)
		</cfquery>
		<a href="/Admin/CSVAnyTable.cfm?tableName=pre_bulk_datum">download</a>
		DO NOT change any data. DO change "shouldbe." (if you get ORA-00942, there are no problems with the data)
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "checkStatus">
		<cfquery name="checkStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select loaded,count(*) c from pre_bulkloader group by loaded
		</cfquery>
		<cfdump var=#checkStatus#>
		<a href="pre_bulkloader.cfm">return</a>
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "nullLoaded">
		<cfquery name="nullLoaded" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			update pre_bulkloader set loaded=null
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>
	<!------------------------------------------------------->
	<cfif action is "deleteAll">
		<cfquery name="deleteAll" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from pre_bulkloader
		</cfquery>
		<cflocation url="pre_bulkloader.cfm" addtoken="false">
	</cfif>

</cfoutput>
<cfinclude template="/includes/_footer.cfm">
