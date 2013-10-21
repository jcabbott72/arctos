<cfinclude template="includes/_header.cfm">
<cfset title="You are now leaving Arctos.">
<cfoutput>
	<cfif not isdefined("target") or len(target) is 0>
		Improper call of this form.	
		<cfthrow detail="exit called without target" errorcode="9944" message="A call to the exit form was made without specifying a target.">
		<cfabort>
	</cfif>
	<cfif left(target,4) is not "http">
		<!--- hopefully a local resource and not some garbage ---->
		<cfif left(target,1) is "/">
			<cfset http_target=application.serverRootURL & target>
		<cfelse>
			<cfset http_target=application.serverRootURL & '/' & target>
		</cfif>
	<cfelse>
		<cfset http_target=target>
	</cfif>
	<cfhttp url="#http_target#" method="head"></cfhttp>
	<cfif isdefined("cfhttp.statuscode") and cfhttp.statuscode is "200 OK">
		<cfset status="200">
	<cfelse>
		<cfset isGoodLink=false>
		<cfif isdefined("cfhttp.statuscode")>
			<cfset status=cfhttp.statuscode>
		<cfelse>
			<cfset status='n/a'>
		</cfif>
	</cfif>
	<cfquery name="exit"  datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		insert into exit_link (
			username,
			ipaddress,
			from_page,
			target,
			http_target,
			when_date,
			status
		) values (
			'#session.username#',
			'
	</cfquery>
 
	exit_link_id number not null,
	username varchar2(255),
	ipaddress varchar2(255),
	from_page varchar2(255),
	target varchar2(255),
	http_target varchar2(255),
	when_date date,
	status varchar2(255);
	<cfif status is "200">
	
	</cfif>
</cfoutput>
create table exit_link (
exit_link_id number not null,
username varchar2(255),
ipaddress varchar2(255),
from_page varchar2(255),
to_page varchar2(255),
when_date date
  8  );


<cfinclude template="includes/_footer.cfm">