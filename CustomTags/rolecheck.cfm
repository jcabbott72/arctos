<cfif (isdefined("session.roles") and 
	session.roles contains "coldfusion_user") and 
	(isdefined("session.force_password_change") and 
	session.force_password_change is "yes" and 
	cgi.script_name is not "/ChangePassword.cfm")>
	<cflocation url="/ChangePassword.cfm">	
</cfif>	
<cfif fileexists(application.webDirectory & cgi.script_name)>
	<cfquery name="isValid" datasource="uam_god" cachedWithin="#CreateTimeSpan(0,1,0,0)#">
		select ROLE_NAME from cf_form_permissions 
		where form_path = '#cgi.script_name#'
	</cfquery>
	<cfif isValid.recordcount is 0>
		<cfset bad=true>
	<cfelseif valuelist(isValid.role_name) is not "public">
		<cfloop query="isValid">
			<cfif not listfindnocase(session.roles,role_name)>
				<cfset bad=true>
			</cfif>
		</cfloop>
	</cfif>
	<cfif isdefined("bad") and bad is true>
	    <cfoutput>
		    <cfmail subject="Access Violation" to="#Application.technicalEmail#" from="Security@#Application.fromEmail#" type="html">
				IP address (#cgi.HTTP_X_Forwarded_For# - #remote_host#) tried to access
				#cgi.script_name#
				
				
				<br>This message was generated by /CustomTags/rolecheck.cfm.
			</cfmail>
			<!--- make sure they're really logged out --->
			<img src="/images/oops.gif" alt="[ unauthorized access ]">
			<div style="color:red;font-size:large;">
				You tried to visit a form for which you are not authorized, or your login has expired. 
				<br>
				If this message is in error, please <a href="/contact.cfm">contact us</a>.
				<br>
			</div>
			<cfheader statuscode="403" statustext="Forbidden">
			<cfabort>
		</cfoutput>
	</cfif>	
</cfif>