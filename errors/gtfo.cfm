<cffunction name="makeRandomString" returnType="string" output="false">
    <cfset var chars = "23456789ABCDEFGHJKMNPQRS">
    <cfset var length = randRange(4,7)>
    <cfset var result = "">
    <cfset var i = "">
    <cfset var char = "">
    <cfscript>
    for(i=1; i <= length; i++) {
        char = mid(chars, randRange(1, len(chars)),1);
        result&=char;
    }
    </cfscript>
    <cfreturn result>
</cffunction>
<cfif not isdefined("action") or action is not "p">
	Oops. Looks like you are on our blacklist. If this is in error, please tell us why.
	<cfset captcha = makeRandomString()>
	<cfset captchaHash = hash(captcha)>
	<cfform name="g" method="post" action="/errors/gtfo.cfm">
		<input type="hidden" name="action" value="p">
		<label for="c">Explain yourself</label>
		<textarea name="c" id="c" rows="6" cols="50"></textarea>
		<br>
	    <cfimage action="captcha" width="300" height="50" text="#captcha#">
	   	<br>
	    <label for="captcha">Enter the text above</label>
	    <input type="text" name="captcha" id="captcha">
	    <cfoutput>
	    <input type="hidden" name="captchaHash" value="#captchaHash#">
	    </cfoutput>
		<br><input type="submit" value="go">
	</cfform>
</cfif>

<cfif isdefined("action") and action is "p">
	<cfoutput>
		<cfif hash(ucase(form.captcha)) neq form.captchaHash>
			You did not enter the right text.
			<cfabort>
		</cfif>
	
		<cfmail subject="BlackList Objection" to="#Application.PageProblemEmail#" from="blacklist@#application.fromEmail#" type="html">
			IP #cgi.REMOTE_ADDR# had this to say:
			<p>
				#c#
			</p>
		</cfmail>
		Your message has been delivered.
	</cfoutput>
</cfif>