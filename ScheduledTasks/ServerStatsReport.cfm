<cfoutput>
	<cfexecute
	    name = "/bin/df"
	    arguments = "-h #application.webDirectory#"
	    variable = "x">
	</cfexecute>

	<cfdump var=#x#>


</cfoutput>