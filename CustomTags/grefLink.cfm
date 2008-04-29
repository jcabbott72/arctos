<!---
Author: Peter DeVore
Purpose: to give a subquery to get a GReF link to be put into another query

Puts the variable "grefLink" into the calling page.
--->
<cfset Application.gref_base_url = "http://bg.berkeley.edu/gref/">
<cfif isdefined('Application.gref_base_url') and len(Application.gref_base_url) gt 0>
	<cfset oid = caller.oid>
	<cfset oidtype = "#caller.oidtype#_id">
	<cfset sql = 
	"(select
		'#Application.gref_base_url#Client.html?pageid=' || gref_roi_ng.page_id 
	  || '&publicationid=' || book_section.publication_id 
	  || '&otherid=' || #oid#
	  || '&otheridtype=' || gref_roi_value_ng.#oidtype# as the_link
		from
		  gref_roi_ng, gref_roi_value_ng, book_section
		where
		  book_section.book_id = gref_roi_ng.publication_id
		  and gref_roi_value_ng.id = gref_roi_ng.ROI_VALUE_NG_ID
		  and gref_roi_ng.section_number = book_section.book_section_order
		  and gref_roi_value_ng.#oidtype# = #oid#)">
	<cfset caller.grefLink = sql>
<cfelse>
	<cfset caller.grefLink = "">
</cfif>