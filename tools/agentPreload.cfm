<!----


drop table cf_temp_agent_sort;

create table cf_temp_agent_sort (
	key number not null,
	agent_type varchar2(255),
	preferred_name varchar2(255),
	other_name_1  varchar2(255),
	other_name_type_1   varchar2(255),
	other_name_2  varchar2(255),
	other_name_type_2   varchar2(255),
	other_name_3  varchar2(255),
	other_name_type_3   varchar2(255),
	other_name_4  varchar2(255),
	other_name_type_4   varchar2(255),
	other_name_5  varchar2(255),
	other_name_type_5   varchar2(255),
	other_name_6  varchar2(255),
	other_name_type_6   varchar2(255),
	agent_remark varchar2(4000),
	agent_status_1 varchar2(255),
	agent_status_date_1 varchar2(255),
	agent_status_2 varchar2(255),
	agent_status_date_2 varchar2(255),
	 status varchar2(4000)
	);
	
	
	
	
	
	
create public synonym cf_temp_agent_sort for cf_temp_agent_sort;
grant all on cf_temp_agent_sort to coldfusion_user;

 CREATE OR REPLACE TRIGGER cf_temp_agent_sort_key                                         
 before insert  ON cf_temp_agent_sort
 for each row 
    begin     
    	select somerandomsequence.nextval into :new.key from dual;                                
    end;                                                                                            
/
sho err



	------>
	
<cfinclude template="/includes/_header.cfm">
<script src="/includes/sorttable.js"></script>

<cfoutput>
	<cfform name="atts" method="post" enctype="multipart/form-data">
		<input type="hidden" name="Action" value="getFile">
		<label for="FiletoUpload">Upload file from agent loader feedback; will overwrite existing</label>
		<input type="file" name="FiletoUpload" size="45" onchange="checkCSV(this);">
		<input type="submit" value="Upload this file" class="savBtn">
	</cfform>
	<cfif isdefined("FiletoUpload")>
	<!--- put this in a temp table --->
		<cfquery name="killOld" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			delete from cf_temp_agent_sort
		</cfquery>
		
		<cfquery name="cols" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select * from cf_temp_agent_sort
		</cfquery>
		<cffile action="READ" file="#FiletoUpload#" variable="fileContent">
		
		
		<cfset  util = CreateObject("component","component.utilities")>
		<cfset q = util.CSVToQuery(CSV=fileContent)>
		
		
		<cfdump var=#q#>
		<cfset colNames=q.columnList>
		<cfloop list="#colNames#" index="c">
			<br>checking #c#
			<cfif not listfindnocase(cols.columnlist,c)>
				<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,c))>
			</cfif>
		</cfloop>
		
		
		
		
		
		
		<cfif listfindnocase(colNames,'key')>
			<cfset colNames=listdeleteat(colNames,listfindnocase(colNames,'key'))>
		</cfif>
		
			
		<p>#colNames#</p>
		
		<cfquery name="qclean" dbtype="query">
			select #colnames# from q
		</cfquery>
		<!--- for some crazy reason this is slow, so bypass for now ---->
		<cfset sql="insert all ">
		<cfloop query="qclean">		
			<cfset sql=sql & " into cf_temp_agent_sort (#colnames#) values (">
			<cfloop list="#colnames#" index="i">
				<cfset sql=sql & "'#escapeQuotes(evaluate("qClean." & i))#',">
			</cfloop>
			<cfset sql=sql & ")">
			<cfset sql=replace(sql,"',)","')","all")>
		</cfloop>
		
		
		<cfdump var=#sql#>
		
		
		
		<cfset sql=sql & "SELECT 1 FROM DUAL">
		<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			#preserveSingleQuotes(sql)#
		</cfquery>
		
		
		<!----------
		
		
		<cfset fileContent=replace(fileContent,"'","''","all")>
		<cfset arrResult = CSVToArray(CSV = fileContent.Trim()) />
		<cfset numberOfColumns = ArrayLen(arrResult[1])>
		<cfset colNames="">
		<cfloop from="1" to ="#ArrayLen(arrResult)#" index="o">
			<cfset colVals="">
				<cfloop from="1"  to ="#ArrayLen(arrResult[o])#" index="i">
					 <cfset numColsRec = ArrayLen(arrResult[o])>
					<cfset thisBit=arrResult[o][i]>
					<cfif #o# is 1>
						<cfset colNames="#colNames#,#thisBit#">
					<cfelse>
						<cfset colVals="#colVals#,'#thisBit#'">
					</cfif>
				</cfloop>
			<cfif #o# is 1>
				<cfset colNames=replace(colNames,",","","first")>
			</cfif>	
			<cfif len(colVals) gt 1>
				<cfset colVals=replace(colVals,",","","first")>
				<cfif numColsRec lt numberOfColumns>
					<cfset missingNumber = numberOfColumns - numColsRec>
					<cfloop from="1" to="#missingNumber#" index="c">
						<cfset colVals = "#colVals#,''">
					</cfloop>
				</cfif>
				<cfquery name="ins" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into cf_temp_agent_sort (#colNames#) values (#preservesinglequotes(colVals)#)				
				</cfquery>
			</cfif>
		</cfloop>
		
		



		---------->
		
						<cflocation url="agentPreload.cfm" addtoken="false">

	</cfif>
	<cfquery name="d" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from cf_temp_agent_sort order by preferred_name
	</cfquery>
	<cfif d.recordcount is 0>
		Load a file to begin.
		<cfabort>
	</cfif>
	<table border id="t" class="sortable">
		<tr>
			<th>preferred_name</th>
			<th>agent_type</th>
			<th>n1</th>
			<th>t1</th>
			<th>n2</th>
			<th>t2</th>
			<th>n3</th>
			<th>t3</th>
			<th>n4</th>
			<th>t4</th>
			<th>n5</th>
			<th>t5</th>
			<th>n6</th>
			<th>t6</th>
			<th>s1</th>
			<th>2d1</th>
			<th>s2</th>
			<th>2d2</th>
			<th>status</th>
		</tr>
		<cfloop query="d">
			<tr>
				<td>#preferred_name#</td>
				<td>#agent_type#</td>
				<td>#other_name_1#</td>
				<td>#other_name_type_1#</td>
				<td>#other_name_2#</td>
				<td>#other_name_type_2#</td>
				<td>#other_name_3#</td>
				<td>#other_name_type_3#</td>
				<td>#other_name_4#</td>
				<td>#other_name_type_4#</td>
				<td>#other_name_5#</td>
				<td>#other_name_type_5#</td>
				<td>#other_name_6#</td>
				<td>#other_name_type_6#</td>
				<td>#agent_status_1#</td>
				<td>#agent_status_date_1#</td>
				<td>#agent_status_2#</td>
				<td>#agent_status_date_2#</td>
				<td>#status#</td>
			</tr>
		</cfloop>

					
</cfoutput>
<cfinclude template="/includes/_footer.cfm">