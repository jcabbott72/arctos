<cfif not isdefined("agent_id")>
	<cfset agent_id=-1>
</cfif>
<cfinclude template="/includes/_header.cfm">
<cfset title='Manage Agents'>




<!---------------
<script type="text/javascript">




/***********************************************
* IFrame SSI script II- � Dynamic Drive DHTML code library (http://www.dynamicdrive.com)
* Visit DynamicDrive.com for hundreds of original DHTML scripts
* This notice must stay intact for legal use
***********************************************/

//Input the IDs of the IFRAMES you wish to dynamically resize to match its content height:
//Separate each ID with a comma. Examples: ["myframe1", "myframe2"] or ["myframe"] or [] for none:
var iframeids=["_search","_person","_pick"]

//Should script hide iframe from browsers that don't support this script (non IE5+/NS6+ browsers. Recommended):
var iframehide="yes"

var getFFVersion=navigator.userAgent.substring(navigator.userAgent.indexOf("Firefox")).split("/")[1]
var FFextraHeight=parseFloat(getFFVersion)>=0.1? 60 : 0 //extra height in px to add to iframe in FireFox 1.0+ browsers

function resizeCaller() {
var dyniframe=new Array()
for (i=0; i<iframeids.length; i++){
if (document.getElementById)
resizeIframe(iframeids[i])
//reveal iframe for lower end browsers? (see var above):
if ((document.all || document.getElementById) && iframehide=="no"){
var tempobj=document.all? document.all[iframeids[i]] : document.getElementById(iframeids[i])
tempobj.style.display="block"
}
}
}

function resizeIframe(frameid){
var currentfr=document.getElementById(frameid)
if (currentfr && !window.opera){
currentfr.style.display="block"
if (currentfr.contentDocument && currentfr.contentDocument.body.offsetHeight) //ns6 syntax
currentfr.height = currentfr.contentDocument.body.offsetHeight+FFextraHeight; 
else if (currentfr.Document && currentfr.Document.body.scrollHeight) //ie5+ syntax
currentfr.height = currentfr.Document.body.scrollHeight;
if (currentfr.addEventListener)
currentfr.addEventListener("load", readjustIframe, false)
else if (currentfr.attachEvent){
currentfr.detachEvent("onload", readjustIframe) // Bug fix line
currentfr.attachEvent("onload", readjustIframe)
}
}
}

function readjustIframe(loadevt) {
var crossevt=(window.event)? event : loadevt
var iframeroot=(crossevt.currentTarget)? crossevt.currentTarget : crossevt.srcElement
if (iframeroot)
resizeIframe(iframeroot.id);
}

function loadintoIframe(iframeid, url){
if (document.getElementById)
document.getElementById(iframeid).src=url
}

if (window.addEventListener)
window.addEventListener("load", resizeCaller, false)
else if (window.attachEvent)
window.attachEvent("onload", resizeCaller)
else
window.onload=resizeCaller


</script>

------------>
<style>


	#td_search {
		height:50%;
		width:30%;
	}
	
	#td_rslt {
		height:50%;
		width:30%;
	}
	
	#td_edit {
		height:100%;
		width:30%;
	}
	#olTabl {
		height:100%;
		width:100%;
	}
	
	
	


</style>
<script>
jQuery(document).ready(function() {
	var wh=$(window).height();

console.log('window height: ' + wh);

var sfmenuh = $('div.sf-mainMenuWrapper:first').height();
console.log('sfmenuh height: ' + sfmenuh);

var hh = $('#headerImageCell').height();

console.log('hh height: ' + hh);


	wh=wh - hh - sfmenuh;

	
	$("#olTabl").height(wh);
 
});


</script>
<cfoutput>



<table border id="olTabl">
	<tr>
		<td id="td_search">
			srch
		</td>
		<td id="td_rslt" rowspan="2">
			edit 
		</td>
	</tr>
	<tr>
		<td id="td_edit" valign="top">
			results
		</td>
	</tr>
</table>


<!-----------
<table border id="olTabl">
	<tr>
		<td id="td_search">
		srch
		<!----
			<iframe src="/AgentSearch.cfm" id="_search" name="_search"></iframe>
			<br>
			<iframe src="/AgentGrid.cfm" name="_pick" id="_pick" width="100%" height="200"></iframe>
			---->
		</td>
		<td id="td_rslt" rowspan="2">
			edit 
		</td>
		
	</tr>
		<tr>
		<td id="td_edit" valign="top">
		results
		
		<!----
			<iframe src="/editAllAgent.cfm?agent_id=#agent_id#" name="_person" id="_person" width="100%" height="600"></iframe>
			---->
		</td>
		</tr>
</table>


----------------->
</cfoutput>