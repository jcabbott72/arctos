<cfoutput>
<cfif not isdefined("collection_object_id")>
    Need a random collection object ID to test?
   <br> <a href="label_report.cfm?action=listReports&collection_object_id=12">Try this one</a>
    <br>aborting....<cfabort>
</cfif>	
<cfinclude template="/includes/_header.cfm">
<cfinclude template="/includes/functionLib.cfm">
<!-------------------------------------------------------------->
<cfif #action# is "delete">
    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        delete from cf_report_sql 
        where report_id=#report_id#
    </cfquery>
    <cflocation url="label_report.cfm?action=listReports&collection_object_id=#collection_object_id#">
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "saveEdit">
    <cfif unsafeSql(sql_text)>
        Your SQL is not acceptable.
        <cfabort>
    </cfif>
    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        update cf_report_sql set     
        report_name ='#report_name#',
        report_template  ='#report_template#',
        sql_text ='#escapeQuotes(sql_text)#'
        where report_id=#report_id#
    </cfquery>
    <cflocation url="label_report.cfm?action=edit&report_id=#report_id#&collection_object_id=#collection_object_id#">
</cfif>



<cfif #action# is "edit">
    <cfif not isdefined("report_id")>
	    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	        select report_id from cf_report_sql where report_name='#report_name#'
	    </cfquery>
        <cflocation url="label_report.cfm?action=edit&report_id=#e.report_id#">
    </cfif>

    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        select * from cf_report_sql where report_id='#report_id#'
    </cfquery>
    <cfdirectory action="list" directory="#Application.webDirectory#/Reports/templates" filter="*.cfr" name="reportList">
   
    <form method="get" action="label_report.cfm" enctype="text/plain">
        <input type="hidden" name="action" value="saveEdit">
        <input type="hidden" name="collection_object_id" value="#collection_object_id#">
        <input type="hidden" name="report_id" value="#e.report_id#">
        <label for="report_name">Report Name</label>
        <input type="text" name="report_name" id="report_name" value="#e.report_name#">
        <label for="report_template">Report Template</label>
        <select name="report_template" id="report_template">
            <option value="-notfound-">ERROR: Not found!</option>
            <cfloop query="reportList">
                <option <cfif name is e.report_template> selected="selected" </cfif>value="#name#">#name#</option>
            </cfloop>
        </select>
        <label for="sql_text">SQL</label>
        <textarea name="sql_text" id="sql_text" rows="40" cols="120" wrap="soft"></textarea>
        <br>
        <input type="submit" value="save handler" class="savBtn">
    </form>
    <cfset j=JSStringFormat(e.sql_text)>
    <script>
        var a = escape("#j#");
        alert(a);
        var b=document.getElementById('sql_text');
        b.value=unescape(a);
    </script>
       <form method="post" action="label_report.cfm" target="_blank">
           <input type="hidden" name="action" value="testSQL">           
            <input type="hidden" name="collection_object_id" value="#collection_object_id#">
	       <input type="hidden" name="test_sql" id="test_sql">
           <input type="hidden" name="format" id="format" value="table">
           <input type="button" value="Test SQL" onclick="document.getElementById('test_sql').value=document.getElementById('sql_text').value;
                submit();" class="lnkBtn">
    </form>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "newHandler">
     <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        insert into cf_report_sql (
            report_name,
            report_template,
            sql_text)
        values (
            '[ New Report ]',
            '#report_template#',
            'select 1 from dual')
    </cfquery>
    <cflocation url="label_report.cfm?action=edit&report_name=[ New Report ]&collection_object_id=#collection_object_id#">
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "clone">
    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        select * from cf_report_sql where report_id='#report_id#'
    </cfquery>
    <cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
        insert into cf_report_sql (
            report_name,
            report_template,
            sql_text)
        values (
            'Clone Of #e.report_name#',
            '#e.report_template#',
            '#e.sql_text#')
    </cfquery>
    <cflocation url="label_report.cfm?action=listReports&collection_object_id=#collection_object_id#">
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "testSQL">
    <cfif unsafeSql(test_sql)>
        <div class="error">
             The code you submitted contains illegal characters.
         </div>
         <cfabort>
    </cfif>

         <cfset sql=replace(test_sql,"##collection_object_id##",#collection_object_id#)>
         <cfquery name="user_sql" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
             #preservesinglequotes(sql)#
         </cfquery>
         <cfdump var=#user_sql#>
        
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "listReports">
    <cfdirectory action="list" directory="#Application.webDirectory#/Reports/templates" filter="*.cfr" name="reportList">
    Existing Reports:<br>
    <table border>
         <tr>
            <td>Report Template</td>
            <td>Handler Name</td>
        </tr>
    <cfloop query="reportList">
		<cfquery name="h" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
	        select * from cf_report_sql where report_template='#name#'
	    </cfquery>
        <cfif h.recordcount is 0>
            <cfquery name="h" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
		        select 0 report_id,
                '#reportList.name#' report_template,
                ' ' report_name
                from dual
		    </cfquery>
        </cfif>
	    <cfloop query="h">
             <tr>
	            <td>#report_template#</td>
	            <td>#report_name#</td>
	            <cfif report_id gt 1>
	                <td><a href="label_report.cfm?action=edit&report_id=#report_id#&collection_object_id=#collection_object_id#">Edit Handler</a></td>
	                <td><a href="label_report.cfm?action=clone&report_id=#report_id#&collection_object_id=#collection_object_id#">Clone Handler</a></td>
                    <td><a href="label_report.cfm?action=delete&report_id=#report_id#&collection_object_id=#collection_object_id#">Delete Handler</a></td>
	            <cfelse>
	                <td><a href="label_report.cfm?action=newHandler&report_template=#report_template#&collection_object_id=#collection_object_id#">Create Handler</a></td>
	            </cfif>
	            <td><a href="label_report.cfm?action=download&name=#report_name#&collection_object_id=#collection_object_id#">Download Report</a></td>
	        </tr>
        </cfloop>
      
    </cfloop>
    </table>
</cfif>
<!-------------------------------------------------------------->
<cfif #action# is "nothing">
<!----

    drop table cf_report_sql;
    
    create table cf_report_sql (
        report_id number not null,
        report_name varchar2(38) not null,
        report_template  varchar2(38) not null,
        sql_text varchar2(4000) not null
    );
    create or replace public synonym cf_report_sql for cf_report_sql;

    create unique index u_cf_report_sql_name on cf_report_sql(report_name);
    
    ALTER TABLE cf_report_sql
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
  grant all on cf_report_sql to coldfusion_user;
---->


<a href="label_report.cfm?action=listReports&collection_object_id=#collection_object_id#" target="_blank">Manage Reports</a>
<cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
    select * from cf_report_sql order by report_name
</cfquery>
 
<form name="print" method="post" action="label_report.cfm">
    <input type="hidden" name="action" value="print">
    <input type="hidden" name="collection_object_id" value="#collection_object_id#">
    <label for="report_id">Print....</label>
        <select name="report_id" id="report_id">
            <cfloop query="e">
                <option value="#report_id#">#report_name# (#report_template#)</option>
            </cfloop>
        </select>
         <input type="submit" value="Print Report">
</form>
</cfif>
<cfif #action# is "print">
<cfquery name="e" datasource="user_login" username="#client.username#" password="#decrypt(client.epw,cfid)#">
    select * from cf_report_sql where report_id=#report_id#
</cfquery>
 <hr>
 #preservesinglequotes(e.sql_text)#
 <hr>
 <cfset sql=replace(e.sql_text,"##collection_object_id##",#collection_object_id#)>
 <hr>
 #preservesinglequotes(sql)#
 <hr>
	<cfquery name="d" datasource="#Application.web_user#">
		#preservesinglequotes(sql)#
	</cfquery>
    
    <cfreport
        format = "flashPaper"
        query="d"
        template = "#Application.webDirectory#/Reports/templates/#e.report_template#"
        encryption = "none"
        filename = "#Application.webDirectory#/temp/#e.report_name#.pdf"
        overwrite = "yes">
    </cfreport>

<a href="/temp/alaLabel.pdf">Download the PDF</a>

<cfdump var="#d#">
</cfif>
</cfoutput>
<cfinclude template="/includes/_footer.cfm">
