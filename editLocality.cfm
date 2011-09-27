<cfinclude template="includes/_header.cfm">
<cfoutput>
	<script>
		function useGL(glat,glon,gerr){
			showLLFormat('decimal degrees','');
			$("##accepted_lat_long_fg").val('1');
			$("##determined_by").val('#session.username#');
			$("##determined_by_agent_id").val('#session.myAgentId#');
			$("##determined_date").val('#dateformat(now(),"yyyy-mm-dd")#');
			$("##MAX_ERROR_DISTANCE").val(gerr);
			$("##MAX_ERROR_UNITS").val('m');
			$("##DATUM").val('World Geodetic System 1984');
			$("##georefMethod").val('GeoLocate');
			$("##extent").val('');
			$("##GpsAccuracy").val('');
			$("##VerificationStatus").val('unverified');
			$("##LAT_LONG_REF_SOURCE").val('GeoLocate');
			$("##dec_lat").val(glat);
			$("##dec_long").val(glon);
			$(document).scrollTo( $('##newLL'), 800 );
			closeGeoLocate();
		}
	</script>
</cfoutput>
					
<cfif action is "nothing">
<cfset title="Edit Locality">
<script language="JavaScript" src="/includes/jquery/scrollTo.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
	jQuery(document).ready(function() {
		$("select[id^='geology_attribute_']").each(function(e){
			populateGeology(this.id);			
		});
		$.each($("input[id^='determined_date']"), function() {
			$("#" + this.id).datepicker();
	    });
	    $.each($("input[id^='geo_att_determined_date_']"), function() {
			$("#" + this.id).datepicker();
	    });
	    if (window.addEventListener) {
			window.addEventListener("message", getGeolocate, false);
		} else {
			window.attachEvent("onmessage", getGeolocate);
		}
		showLLFormat('#orig_lat_long_units#','#i#');
	});
	function geolocate() {
		alert('This opens a map. There is a help link at the top. Use it. The save button will create a new determination.');
		var guri='http://www.museum.tulane.edu/geolocate/web/webgeoreflight.aspx?georef=run';
		guri+="&state=" + $("#state_prov").val();
		guri+="&country="+$("#country").val();
		guri+="&county="+$("#county").val().replace(" County", "");
		guri+="&locality="+$("#spec_locality").val();
		var bgDiv = document.createElement('div');
		bgDiv.id = 'bgDiv';
		bgDiv.className = 'bgDiv';
		bgDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
		document.body.appendChild(bgDiv);
		var popDiv=document.createElement('div');
		popDiv.id = 'popDiv';
		popDiv.className = 'editAppBox';
		document.body.appendChild(popDiv);	
		var cDiv=document.createElement('div');
		cDiv.className = 'fancybox-close';
		cDiv.id='cDiv';
		cDiv.setAttribute('onclick','closeGeoLocate("clicked closed")');
		$("#popDiv").append(cDiv);
		var hDiv=document.createElement('div');
		hDiv.className = 'fancybox-help';
		hDiv.id='hDiv';
		hDiv.innerHTML='<a href="https://arctosdb.wordpress.com/how-to/create/data-entry/geolocate/" target="blank">[ help ]</a>';
		$("#popDiv").append(hDiv);
		$("#popDiv").append('<img src="/images/loadingAnimation.gif" class="centeredImage">');
		var theFrame = document.createElement('iFrame');
		theFrame.id='theFrame';
		theFrame.className = 'editFrame';
		theFrame.src=guri;
		$("#popDiv").append(theFrame);
	}
	function getGeolocate(evt) {
		var message;
		if (evt.origin !== "http://www.museum.tulane.edu") {
	    	alert( "iframe url does not have permision to interact with me" );
	        closeGeoLocate('intruder alert');
	    }
	    else {
	    	var breakdown = evt.data.split("|");
			if (breakdown.length == 4) {
			    var glat=breakdown[0];
			    var glon=breakdown[1];
			    var gerr=breakdown[2];
			    useGL(glat,glon,gerr)
			} else {
				alert( "Whoa - that's not supposed to happen. " +  breakdown.length);
				closeGeoLocate('ERROR - breakdown length');
	 		}
	    }
	}
	function closeGeoLocate(msg) {
		$('#bgDiv').remove();
		$('#bgDiv', window.parent.document).remove();
		$('#popDiv').remove();
		$('#popDiv', window.parent.document).remove();
		$('#cDiv').remove();
		$('#cDiv', window.parent.document).remove();
		$('#theFrame').remove();
		$('#theFrame', window.parent.document).remove();
	}
	function populateGeology(id) {
		if (id=='geology_attribute') {
			var idNum='';
			var thisValue=$("#geology_attribute").val();
			var dataValue=$("#geo_att_value").val();
			var theSelect="geo_att_value";
		} else {
			var idNum=id.replace('geology_attribute_','');
			var thisValue=$("#geology_attribute_" + idNum).val();;
			var dataValue=$("#geo_att_value_" + idNum).val();
			var theSelect="geo_att_value_";
		}
		jQuery.getJSON("/component/functions.cfc",
			{
				method : "getGeologyValues",
				attribute : thisValue,
				returnformat : "json",
				queryformat : 'column'
			},
			function (r) {
				var s='';
				for (i=0; i<r.ROWCOUNT; ++i) {
					s+='<option value="' + r.DATA.ATTRIBUTE_VALUE[i] + '"';
					if (r.DATA.ATTRIBUTE_VALUE[i]==dataValue) {
						s+=' selected="selected"';
					}
					s+='>' + r.DATA.ATTRIBUTE_VALUE[i] + '</option>';
				}
				$("select#" + theSelect + idNum).html(s);
			}
		);
	}	
	function showLLFormat(orig_units,recID) {
		if (recID.length == 0) {
			var addNewLL = document.getElementById('addNewLL');
			addNewLL.style.display='none';
			var llMeta = document.getElementById('llMeta');
			llMeta.style.display='';
		}
		var dd = 'dd' + recID;
		var dd = document.getElementById(dd);
		var utm = 'utm' + recID;
		var utm = document.getElementById(utm);
		var dms = 'dms' + recID;
		var dms = document.getElementById(dms);
		var ddm = 'ddm' + recID;
		var ddm = document.getElementById(ddm);
		dd.style.display='none';
		utm.style.display='none';
		ddm.style.display='none';
		dms.style.display='none';
		if (orig_units.length > 0) {
			if (orig_units == 'decimal degrees') {
				dd.style.display='';
			} 
			else if (orig_units == 'UTM') {
				utm.style.display='';
			}
			else if (orig_units == 'degrees dec. minutes') {
				ddm.style.display='';
			}
			else if (orig_units == 'deg. min. sec.') {
				dms.style.display='';
			}
			else {
				alert('I have no idea what to do with ' + orig_units);
			}		
		}
		$("#ORIG_LAT_LONG_UNITS").val(orig_units);
	}
	function cloneLocality(locality_id) {
		if(confirm('Do you want to create a copy of this locality which you may then edit?')) {
			var rurl='editLocality.cfm?action=clone&locality_id=' + locality_id;
			if(confirm('Do you want to include accepted georeferences?')){
				rurl+='&keepAcc=1';
				if(confirm('Do you want to include unaccepted georeferences too?')){
					rurl+='&keepUnacc=1';
				}
			}
			document.location=rurl;
		}
	}
</script>
<cfoutput> 
	<cfquery name="locDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    	select 
			locality.locality_id,
			geog_auth_rec.GEOG_AUTH_REC_ID,
			higher_geog,
			state_prov,
			county,
			country,
			spec_locality,
			MIN_DEPTH,
			MAX_DEPTH,
			DEPTH_UNITS,
			LOCALITY_REMARKS,
			MINIMUM_ELEVATION,
			MAXIMUM_ELEVATION,
			ORIG_ELEV_UNITS,
			NOGEOREFBECAUSE,
			SPEC_LOCALITY
		from 
			locality, 
			geog_auth_rec 
		where 
			locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id and 
			locality.locality_id=#locality_id# 
	</cfquery>
	<cfif locDet.recordcount is not 1>
		<div class="error">locality not found</div><cfabort>
	</cfif>
	<cfquery name="geolDet" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
    	select 
			*
		from 
			geology_attributes,
			preferred_agent_name
		where 
			geology_attributes.geo_att_determiner_id = preferred_agent_name.agent_id (+) and
			geology_attributes.locality_id=#locality_id# 
	</cfquery>
	<cfquery name="whatSpecs" datasource="uam_god">
  		SELECT 
			count(cataloged_item.cat_num) numOfSpecs, 
			collection.collection
		from 
			cataloged_item, 
			collection,
			collecting_event 
		WHERE
			cataloged_item.collecting_event_id = collecting_event.collecting_event_id and
			cataloged_item.collection_id = collection.collection_id and
			collecting_event.locality_id=#locality_id# 
		GROUP BY 
			collection.collection
  	</cfquery>
	<cfquery name="getLL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
        select
			ACCEPTED_LAT_LONG_FG,
			DATUM,
			DEC_LAT,
			DEC_LAT_MIN,
			DEC_LONG,
			DEC_LONG_MIN,
			DETERMINED_BY_AGENT_ID,
			agent_name,
			DETERMINED_DATE,
			EXTENT,
			FIELD_VERIFIED_FG,
			GEOREFMETHOD,
			GPSACCURACY,
			LAT_DEG,
			LAT_DIR,
			LAT_LONG_FOR_NNP_FG,
			LAT_LONG_ID,
			LAT_LONG_REF_SOURCE,
			LAT_LONG_REMARKS,
			LAT_MIN,
			LAT_SEC,
			LOCALITY_ID,
			LONG_DEG,
			LONG_DIR,
			LONG_MIN,
			LONG_SEC,
			MAX_ERROR_DISTANCE,
			MAX_ERROR_UNITS,
			ORIG_LAT_LONG_UNITS,
			SPATIALFIT,
			UTM_EW,
			UTM_NS,
			UTM_ZONE,
			VERIFICATIONSTATUS
		from 
			lat_long,
			preferred_agent_name 
		where 
			determined_by_agent_id = agent_id and 
			locality_id=#locality_id# 
		order by 
			ACCEPTED_LAT_LONG_FG DESC, lat_long_id
     </cfquery>
     <cfquery name="ctdatum" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select datum from ctdatum order by datum
     </cfquery>
	<cfquery name="ctElevUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select orig_elev_units from ctorig_elev_units order by orig_elev_units
	</cfquery>
	<cfquery name="ctDepthUnit" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select depth_units from ctdepth_units order by depth_units
	</cfquery>
        <cfquery name="cterror" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select LAT_LONG_ERROR_UNITS from ctLAT_LONG_ERROR_UNITS order by LAT_LONG_ERROR_UNITS
     </cfquery>
     <cfquery name="ctGeorefMethod" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select georefMethod from ctgeorefmethod order by georefMethod 
	</cfquery>
	<cfquery name="ctVerificationStatus" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
		select VerificationStatus from ctVerificationStatus order by VerificationStatus
	</cfquery>
     <cfquery name="ctunits" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select ORIG_LAT_LONG_UNITS from ctLAT_LONG_UNITS order by ORIG_LAT_LONG_UNITS
     </cfquery>
	<cfquery name="ctgeology_attribute" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#" cachedwithin="#createtimespan(0,0,60,0)#">
        select geology_attribute from ctgeology_attribute order by geology_attribute
     </cfquery>
	<span style="padding:1em;margin-left:2em;margin-right:2em;border:2px solid red;">
		This locality contains
		<cfif whatSpecs.recordcount is 0>
 					no specimens. Please delete it if you don't have plans for it.
 			<cfelseif whatSpecs.recordcount is 1>
			#whatSpecs.numOfSpecs# #whatSpecs.collection# 
			<a href="SpecimenResults.cfm?locality_id=#locality_id#">specimens</a>
		<cfelse>
			 the following <a href="SpecimenResults.cfm?locality_id=#locality_id#">specimens</a>:  
			<ul>	
				<cfloop query="whatSpecs">
					<li><font color="##FF0000">#numOfSpecs# #collection#</font></li>
				</cfloop>			
			</ul>
			</cfif>
	</span>
	<p><strong>Higher Geography</strong></p>
	<form name="geog" action="editLocality.cfm" method="post">
		<input type="hidden" name="action" value="changeGeog">
           <input type="hidden" name="geog_auth_rec_id">
           <input type="hidden" name="locality_id" value="#locDet.locality_id#">
		<label for="higher_geog">Higer Geography</label>
        <input type="text" name="higher_geog" id="higher_geog" value="#locDet.higher_geog#" size="120" class="readClr" readonly="yes">
        <input type="hidden" name="state_prov" id="state_prov" value="#locDet.state_prov#">
		<input type="hidden" name="country" id="country" value="#locDet.country#">
		<input type="hidden" name="county" id="county" value="#locDet.county#">
		<input type="button" value="Change" class="picBtn" id="changeGeogButton"
			onclick="document.getElementById('saveGeogChangeButton').style.display='';document.getElementById('higher_geog').className='red';GeogPick('geog_auth_rec_id','higher_geog','geog'); return false;">
		<input type="submit" value="Save" class="savBtn" id="saveGeogChangeButton" style="display:none">
		<input type="button" value="Edit" class="lnkBtn"
			onClick="document.location='Locality.cfm?action=editGeog&geog_auth_rec_id=#locDet.geog_auth_rec_id#'">
	</form>
	<p><strong>Locality</strong></p>
       <form name="locality" method="post" action="editLocality.cfm">
       	<input type="hidden" name="action" value="saveLocalityEdit">
           <input type="hidden" name="locality_id" value="#locDet.locality_id#">
       	<label for="spec_locality" class="likeLink" onClick="getDocs('locality','specific_locality')">
			Specific Locality
		</label>
		<input type="text"id="spec_locality" name="spec_locality" value="#stripQuotes(locDet.spec_locality)#" size="120">
		<table>
			<tr>
				<td>
					<label for="minimum_elevation" onClick="getDocs('locality','elevation')" class="likeLink">
						Min. Elev.
					</label>
					<input type="text" name="minimum_elevation" id="minimum_elevation" value="#locDet.minimum_elevation#" size="3">
				</td>
				<td>TO</td>
				<td>
					<label for="maximum_elevation" onClick="getDocs('locality','elevation')" class="likeLink">
						Max. Elev.
					</label>
					<input type="text" name="maximum_elevation" id="maximum_elevation" value="#locDet.maximum_elevation#" size="3">
				</td>
				<td>
					<label for="orig_elev_units" onClick="getDocs('locality','elevation')" class="likeLink">
						Elev. Unit
					</label>
					<select name="orig_elev_units" size="1" id="orig_elev_units">
						<option value=""></option>
	                    <cfloop query="ctElevUnit">
	                    	<option <cfif ctelevunit.orig_elev_units is locdet.orig_elev_units> selected="selected" </cfif>value="#ctElevUnit.orig_elev_units#">#ctElevUnit.orig_elev_units#</option>
	                    </cfloop>
	                </select>
				</td>
			</tr>
		</table>
		<table>
			<tr>
				<td>
					<label for="min_depth" onClick="getDocs('locality','depth')" class="likeLink">
						Min. Depth.
					</label>
					<input type="text" name="min_depth" id="min_depth" value="#locDet.min_depth#" size="3">
				</td>
				<td>TO</td>
				<td>
					<label for="max_depth" class="likeLink" onClick="getDocs('locality','depth')">
						Max. Depth.
					</label>
					<input type="text" name="max_depth"  id="max_depth" value="#locDet.max_depth#" size="3">
				</td>
				<td>
					<label for="depth_units" class="likeLink" onClick="getDocs('locality','depth')">
						Depth Unit
					</label>
					<select name="depth_units" size="1" id="depth_units">
						<option value=""></option>
	                    <cfloop query="ctDepthUnit">
	                    	<option <cfif ctDepthUnit.depth_units is locdet.depth_units> selected="selected" </cfif>value="#ctDepthUnit.depth_units#">#ctDepthUnit.depth_units#</option>
	                    </cfloop>
	                </select>
				</td>
			</tr>
		</table>
		<label for="locality_remarks">Locality Remarks</label>
		<input type="text" name="locality_remarks" id="locality_remarks" value="#stripQuotes(locDet.locality_remarks)#"  size="120">
		<label for="NoGeorefBecause">
			Not Georeferenced Because
		</label>
		<input type="text" name="NoGeorefBecause" id="NoGeorefBecause" value="#locDet.NoGeorefBecause#"  size="120">
		<cfif getLL.recordcount gt 0 AND len(locDet.NoGeorefBecause) gt 0>
			<div style="background-color:red">
				NoGeorefBecause should be NULL for localities with georeferences.
				Please review this locality and update accordingly.
			</div>
		<cfelseif getLL.recordcount is 0 AND len(locDet.NoGeorefBecause) is 0>
			<div style="background-color:red">
				Please georeference this locality or enter a value for NoGeorefBecause.
			</div>
		</cfif>
		<br>
		<input type="button" value="Save" class="savBtn" onclick="locality.action.value='saveLocalityEdit';locality.submit();">
		<input type="button" value="Delete" class="delBtn" onClick="locality.action.value='deleteLocality';confirmDelete('locality');">
		<input type="button" value="Clone Locality" class="insBtn" onClick="cloneLocality(#locality_id#)">
		<input type="button" value="Add Collecting Event" class="insBtn" 
			onclick="document.location='Locality.cfm?action=newCollEvent&locality_id=#locDet.locality_id#'">
		<input type="button" value="GeoLocate" class="insBtn" onClick="geolocate();">
		<a href="/bnhmMaps/bnhmPointMapper.cfm?locality_id=#locDet.locality_id#" target="_blank">[ Map All Georeferences ]</a>
		<a href="Locality.cfm?action=findCollEvent&locality_id=#locDet.locality_id#" target="_blank">[ Find all Collecting Events ]</a>
	</form>
	<hr />
	<strong>Coordinates for this locality:</strong>
	&nbsp;&nbsp;&nbsp;
	<span style="font-size:smaller;">
		<span class="likeLink" onClick="getDocs('lat_long')">Help</span>
		&nbsp;~&nbsp;<a href="http://bg.berkeley.edu/latest/" target="_blank" class="external">BioGeoMancer</a>
		&nbsp;~&nbsp;<a href="http://manisnet.org/gci2.html" target="_blank" class="external">Georef Calculator</a>
		&nbsp;~&nbsp;<a href="http://www.museum.tulane.edu/geolocate/web/WebGeoref.aspx" target="_blank" class="external">GeoLocate</a>
	</span>	
	<cfset i=1>
	<cfloop query="getLL"> 
        <form name="latLong#i#" method="post" action="editLocality.cfm" onSubmit="return noenter();">
			<input type="hidden" name="locality_id" value="#locality_id#">
            <input type="hidden" name="action" value="editAccLatLong">
            <input type="hidden" name="lat_long_id" value="#lat_long_id#">
            <table border>
            	<tr> 		 
                	<td>
						<label for="ORIG_LAT_LONG_UNITS#i#" onClick="getDocs('lat_long','original_units')" class="likeLink">
							Original Units
						</label>
						<select name="ORIG_LAT_LONG_UNITS" id="ORIG_LAT_LONG_UNITS#i#" size="1" class="reqdClr"
							onchange="showLLFormat(this.value,'#i#');">
		                    <cfloop query="ctunits">
		                      <option 
							  	<cfif getLL.ORIG_LAT_LONG_UNITS is ctunits.ORIG_LAT_LONG_UNITS> selected="selected" </cfif>value="#ctunits.ORIG_LAT_LONG_UNITS#">#ctunits.ORIG_LAT_LONG_UNITS#</option>
		                    </cfloop>
		                  </select>
					</td>
					<td nowrap>
						<div style="border:3px solid <cfif accepted_lat_long_fg is 1>green<cfelse>red</cfif>;">
			                <label for="accepted_lat_long_fg#i#" onClick="getDocs('lat_long','accepted')" class="likeLink">
								Accepted?
							</label>
							<select name="accepted_lat_long_fg" id="accepted_lat_long_fg#i#" size="1" class="reqdClr">
								<option <cfif accepted_lat_long_fg is 1> selected="selected" </cfif>value="1">yes</option>
								<option <cfif accepted_lat_long_fg is 0> selected="selected" </cfif> value="0">no</option>
							</select>
						</div>
					</td>
					<td>
						<label for="determined_by#i#" onClick="getDocs('lat_long','determiner')" class="likeLink">
							Determiner
						</label>
						<input type="text" name="determined_by" id="determined_by#i#" class="reqdClr" value="#agent_name#" size="40"
							onchange="getAgent('determined_by_agent_id','determined_by','latLong#i#',this.value); return false;"
			 				onKeyPress="return noenter(event);">
			 			<input type="hidden" name="determined_by_agent_id" value="#determined_by_agent_id#">
					</td>
					<td>
						<label for="determined_date#i#" class="likeLink" onClick="getDocs('lat_long','date')">
							Determined Date
						</label>
						<input type="text" name="determined_date" id="determined_date#i#" value="#dateformat(determined_date,'yyyy-mm-dd')#" class="reqdClr"> 
					</td>
					<td rowspan="6">
						<cfif len(dec_lat) gt 0>
							<cfset iu="http://maps.google.com/maps/api/staticmap?key=#application.gmap_api_key#&center=#dec_lat#,#dec_long#">
							<cfset iu=iu & "&markers=color:red|size:tiny|#dec_lat#,#dec_long#&sensor=false&size=200x200&zoom=2">
							<cfset iu=iu & "&maptype=roadmap">
							<a href="/bnhmMaps/bnhmPointMapper.cfm?locality_id=#locality_id#" target="_blank">
	                        	<img src="#iu#" alt="Google Map">
	                        </a>
						</cfif>
					</td>
				</tr>
				<tr>
					<td>
						<table>
							<tr>
								<td>
									<label for="MAX_ERROR_DISTANCE#i#" class="likeLink" onClick="getDocs('lat_long','maximum_error')">Max Error</label>
									<input type="text" name="MAX_ERROR_DISTANCE" id="MAX_ERROR_DISTANCE#i#" value="#MAX_ERROR_DISTANCE#" size="6">
								</td>
								<td>
									<label for="MAX_ERROR_UNITS#i#" class="likeLink" onClick="getDocs('lat_long','maximum_error')">
										Max Error Units
									</label>
									<select name="MAX_ERROR_UNITS" size="1" id="MAX_ERROR_UNITS#i#">
					                    <option value=""></option>
					                    <cfloop query="cterror">
					                      <option <cfif cterror.LAT_LONG_ERROR_UNITS is getLL.MAX_ERROR_UNITS> selected="selected" </cfif>
											value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
					                    </cfloop>
					                  </select> 
								</td>
							</tr>
						</table>					
					</td>
					<td>
						<label for="DATUM#i#" class="likeLink" onClick="getDocs('lat_long','datum')">Datum</label>
						<select name="DATUM" id="DATUM#i#" size="1" class="reqdClr">
		                    <cfloop query="ctdatum">
		                      <option <cfif ctdatum.DATUM is getLL.DATUM> selected="selected" </cfif> 
								value="#ctdatum.DATUM#">#ctdatum.DATUM#</option>
		                    </cfloop>
		                  </select> 
					</td>
					<td>
						<label for="georefMethod#i#" class="likeLink" onClick="getDocs('lat_long','georefmethod')">Georeference Method</label>
						<select name="georefMethod" id="georefMethod#i#" size="1" class="reqdClr">
					   		<cfloop query="ctGeorefMethod">
								<option 
									<cfif getLL.georefMethod is ctGeorefMethod.georefMethod> selected="selected" </cfif>
									value="#ctGeorefMethod.georefMethod#">#ctGeorefMethod.georefMethod#</option>
							</cfloop>
					   </select>
					</td>
					<td>
						<label for="extent#i#" class="likeLink" onClick="getDocs('lat_long','extent')">Extent</label>
						<input type="text" name="extent" id="extent#i#" value="#extent#" size="7">
					</td>
				</tr>
				<tr>
					<td>
						<label for="GpsAccuracy#i#" class="likeLink" onClick="getDocs('lat_long','gpsaccuracy')">GPS Accuracy</label>
						<input type="text" name="GpsAccuracy" id="GpsAccuracy#i#" value="#GpsAccuracy#" size="7">
					</td>
					<td>
						<label for="VerificationStatus#i#" class="likeLink" onClick="getDocs('lat_long','verificationstatus')">Verification Status</label>
						<select name="VerificationStatus" id="VerificationStatus#i#" size="1" class="reqdClr">
						   	<cfset thisVerificationStatus = #VerificationStatus#>
						   		<cfloop query="ctVerificationStatus">
									<option 
										<cfif getLL.VerificationStatus is ctVerificationStatus.VerificationStatus> selected="selected" </cfif>
										value="#ctVerificationStatus.VerificationStatus#">#ctVerificationStatus.VerificationStatus#</option>
								</cfloop>
						   </select>
					</td>
					<td colspan="3">
						<label for="LAT_LONG_REMARKS#i#" class="likeLink" onClick="getDocs('lat_long','remarks')">Remarks</label>
						<input type="text" name="LAT_LONG_REMARKS" id="LAT_LONG_REMARKS#i#" value="#stripQuotes(LAT_LONG_REMARKS)#" size="60">
					</td>
				</tr>
				<tr>
					<td colspan="4">
						<label for="LAT_LONG_REF_SOURCE#i#" class="likeLink" onClick="getDocs('lat_long','reference')">Reference</label>
						<input type="text" name="LAT_LONG_REF_SOURCE" id="LAT_LONG_REF_SOURCE#i#" size="120" class="reqdClr" value='#preservesinglequotes(getLL.LAT_LONG_REF_SOURCE)#' />
					</td>
				</tr>
				<tr>
					<td colspan="4">
						<table id="dms#i#" style="display:none;">
							<tr> 
								<td>
									<label for="lat_deg#i#">Lat. Deg.</label>
									<input type="text" name="LAT_DEG" value="#LAT_DEG#" size="4" id="lat_deg#i#" class="reqdClr">
								</td>
								<td>
									<label for="lat_min#i#">Lat. Min.</label>
									<input type="text" name="LAT_MIN" value="#LAT_MIN#" size="4" id="lat_min#i#" class="reqdClr">
								</td>
								<td>
									<label for="lat_sec#i#">Lat. Sec.</label>
									<input type="text" name="LAT_SEC" value="#LAT_SEC#" id="lat_sec#i#" class="reqdClr">
								</td>
								<td>
									<label for="lat_dir#i#">Lat. Dir.</label>
									<select name="LAT_DIR" size="1" id="lat_dir#i#"  class="reqdClr">
										<option value=""></option>
								        <option <cfif LAT_DIR is "N"> selected </cfif>value="N">N</option>
								        <option <cfif LAT_DIR is "S"> selected </cfif>value="S">S</option>
								    </select>
								</td>
							</tr>
							<tr>
								<td>
									<label for="long_deg#i#">Long. Deg.</label>
									<input type="text" name="LONG_DEG" value="#LONG_DEG#" size="4" id="long_deg#i#" class="reqdClr">
								</td>
								<td>
									<label for="long_min#i#">Long. Min.</label>
									<input type="text" name="LONG_MIN" value="#LONG_MIN#" size="4" id="long_min#i#" class="reqdClr">
								</td>
								<td>
									<label for="long_sec#i#">Long. Sec.</label>
									<input type="text" name="LONG_SEC" value="#LONG_SEC#" id="long_sec#i#"  class="reqdClr">
								</td>
								<td>
									<label for="long_dir#i#">Long. Dir.</label>
									<select name="LONG_DIR" size="1" id="long_dir#i#" class="reqdClr">
								    	<option value=""></option>
								        <option <cfif #LONG_DIR# is "E"> selected </cfif>value="E">E</option>
								        <option <cfif #LONG_DIR# is "W"> selected </cfif>value="W">W</option>
								    </select>
								</td>
							</tr>
						</table>
						<table id="ddm#i#" style="display:none;">
							<tr> 
								<td>
									<label for="dmlat_deg#i#">Lat. Deg.<label>
									<input type="text" name="dmLAT_DEG" value="#LAT_DEG#" size="4" id="dmlat_deg#i#" class="reqdClr">
								</td>
								<td>
									<label for="dec_lat_min#i#">Lat. Dec. Min.<label>
									<input type="text" name="DEC_LAT_MIN" value="#DEC_LAT_MIN#" id="dec_lat_min#i#" class="reqdClr">
								</td>
								<td>
									<label for="dmlat_dir#i#">Lat. Dir.<label>
									<select name="dmLAT_DIR" size="1" id="dmlat_dir#i#" class="reqdClr">
					                	<option value=""></option>
					                   	<option <cfif #LAT_DIR# is "N"> selected </cfif>value="N">N</option>
					                   	<option <cfif #LAT_DIR# is "S"> selected </cfif>value="S">S</option>
					                 </select>
								</td>
							</tr>
							<tr>
								<td>
									<label for="dmlong_deg#i#">Long. Deg.<label>
									<input type="text" name="dmLONG_DEG" value="#LONG_DEG#" size="4" id="dmlong_deg#i#" class="reqdClr">
								</td>
								<td>
									<label for="dec_long_min#i#">Long. Dec. Min.<label>
									<input type="text" name="DEC_LONG_MIN" value="#DEC_LONG_MIN#" id="dec_long_min#i#" class="reqdClr">
								</td>
								<td>
									<label for="dmlong_dir#i#">Long. Dir.<label>
									<select name="dmLONG_DIR" size="1" id="dmlong_dir#i#" class="reqdClr">
										<option value=""></option>
									    <option <cfif #LONG_DIR# is "E"> selected </cfif>value="E">E</option>
									    <option <cfif #LONG_DIR# is "W"> selected </cfif>value="W">W</option>
									</select>
								</td>
							</tr>
						</table>
						<table id="dd#i#" style="display:none;">
							<tr> 
								<td>
									<label for="dec_lat#i#">Decimal Latitude</label>
									<input type="text" name="DEC_LAT" id="dec_lat#i#" value="#DEC_LAT#" class="reqdClr">
								</td>
								<td>
									<label for="dec_long#i#">Decimal Longitude</label>
									<input type="text" name="DEC_LONG" value="#DEC_LONG#" id="dec_long#i#" class="reqdClr">
								</td>
							</tr>
						</table>
						<table id="utm#i#" style="display:none;">
							<tr> 
								<td>
									<label for="utm_zone#i#">UTM Zone<label>
									<input type="text" name="UTM_ZONE" value="#UTM_ZONE#" id="utm_zone#i#" class="reqdClr">
								</td>
								<td>
									<label for="utm_ew#i#">UTM East/West<label>
									<input type="text" name="UTM_EW" value="#UTM_EW#" id="utm_ew#i#" class="reqdClr">
								</td>
								<td>
									<label for="utm_ns#i#">UTM North/South<label>
									<input type="text" name="UTM_NS" value="#UTM_NS#" id="utm_ns#i#" class="reqdClr">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr> 
                	<td colspan="4">
						<input type="button" value="Save Changes" class="savBtn" onClick="latLong#i#.action.value='editAccLatLong';submit();">
						<input type="button" value="Delete" class="delBtn" onClick="latLong#i#.action.value='deleteLatLong';confirmDelete('latLong#i#');">
					</td>
              </tr>
			</table>
          </form>
		<cfset i=i+1>
	</cfloop>
	<a name="newLL" id="newLL"></a>
	<form name="newlatLong" method="post" action="editLocality.cfm">
		<input type="hidden" name="action" value="AddLatLong">
		<input type="hidden" name="locality_id" value="#locDet.locality_id#">
		<table class="newRec">
			<tr>
				<td>
					Add Coordinate Determination
				</td>
			</tr>
			<tr>
				<td id="addNewLL">
					<label for="ORIG_LAT_LONG_UNITS" class="likeLink" onClick="getDocs('lat_long','original_units')">Original Units</label>
					<select name="ORIG_LAT_LONG_U" id="ORIG_LAT_LONG_U" size="1"  class="reqdClr"
						onchange="document.getElementById('ORIG_LAT_LONG_UNITS').value=this.value; showLLFormat(this.value,'')">
	                    <option selected="selected" value="">Pick one...</option>
	                    <cfloop query="ctunits">
	                      <option value="#ctunits.ORIG_LAT_LONG_UNITS#">#ctunits.ORIG_LAT_LONG_UNITS#</option>
	                    </cfloop>
	                </select>
				</td>
			</tr>
			<tr>
				<td>		
					<table border id="llMeta" style="display:none;">
              			<tr> 		 
                			<td>
								<label for="ORIG_LAT_LONG_UNITS" class="likeLink" onClick="getDocs('lat_long','original_units')">Original Units</label>
								<select name="ORIG_LAT_LONG_UNITS" id="ORIG_LAT_LONG_UNITS" size="1" class="reqdClr"
									onchange="showLLFormat(this.value,'')">
				                    <cfloop query="ctunits">
				                      <option value="#ctunits.ORIG_LAT_LONG_UNITS#">#ctunits.ORIG_LAT_LONG_UNITS#</option>
				                    </cfloop>
				                 </select>
							</td>
							<td nowrap>
				                <label for="accepted_lat_long_fg" class="likeLink" onClick="getDocs('lat_long','accepted')">Accepted?</label>
								<select name="accepted_lat_long_fg" id="accepted_lat_long_fg" size="1" class="reqdClr">
									<option selected value="1">yes</option>
									<option value="0">no</option>
								</select>
							</td>
							<td>
								<label for="determined_by" class="likeLink" onClick="getDocs('lat_long','determiner')">Determiner</label>
								<input type="text" name="determined_by" id="determined_by" class="reqdClr" size="40"
									onchange="getAgent('determined_by_agent_id','determined_by','newlatLong',this.value); return false;"
					 				onKeyPress="return noenter(event);">
					 			<input type="hidden" name="determined_by_agent_id" ID="determined_by_agent_id">
							</td>
							<td>
								<label for="determined_date" class="likeLink" onClick="getDocs('lat_long','date')">Determined Date</label>
								<input type="text" name="determined_date" id="determined_date" class="reqdClr"> 
							</td>
              			</tr>
           				<tr>
							<td>
								<table>
									<tr>
										<td>
											<label for="MAX_ERROR_DISTANCE" class="likeLink" onClick="getDocs('lat_long','maximum_error')">Maximum Error</label>
											<input type="text" name="MAX_ERROR_DISTANCE" id="MAX_ERROR_DISTANCE" size="6">
										</td>
										<td>
											<label for="MAX_ERROR_UNITS" class="likeLink" onClick="getDocs('lat_long','maximum_error')">Maximum Error Units</label>
											<select name="MAX_ERROR_UNITS" size="1" id="MAX_ERROR_UNITS">
							                    <option value=""></option>
							                    <cfloop query="cterror">
							                      <option value="#cterror.LAT_LONG_ERROR_UNITS#">#cterror.LAT_LONG_ERROR_UNITS#</option>
							                    </cfloop>
							                  </select> 
										</td>
									</tr>
								</table>					
							</td>
							<td>
								<label for="DATUM" class="likeLink" onClick="getDocs('lat_long','datum')">Datum</label>
								<select name="DATUM" id="DATUM" size="1" class="reqdClr">
				                    <option value=""></option>
				                    <cfloop query="ctdatum">
				                      <option value="#ctdatum.DATUM#">#ctdatum.DATUM#</option>
				                    </cfloop>
				                  </select> 
							</td>
							<td>
								<label for="georefMethod" class="likeLink" onClick="getDocs('lat_long','georefmethod')">Georeference Method</label>
								<select name="georefMethod" id="georefMethod" size="1" class="reqdClr">
							   		<cfloop query="ctGeorefMethod">
										<option value="#georefMethod#">#georefMethod#</option>
									</cfloop>
							   </select>
							</td>
							<td>
								<label for="extent" class="likeLink"  onClick="getDocs('lat_long','extent')">Extent</label>
								<input type="text" name="extent" id="extent" size="7">
							</td>
						</tr>
						<tr>
							<td>
								<label for="GpsAccuracy" class="likeLink" onClick="getDocs('lat_long','georefmethod')" >
									GPS Accuracy
								</label>
								<input type="text" name="GpsAccuracy" id="GpsAccuracy" size="7">
							</td>
							<td>
								<label for="VerificationStatus" class="likeLink" onClick="getDocs('lat_long','verificationstatus')">Verification Status</label>
								<select name="VerificationStatus" id="VerificationStatus" size="1" class="reqdClr">
								   		<cfloop query="ctVerificationStatus">
											<option value="#VerificationStatus#">#VerificationStatus#</option>
										</cfloop>
								   </select>
							</td>
							<td colspan="3">
								<label for="LAT_LONG_REMARKS" class="likeLink" onClick="getDocs('lat_long','remarks')">Remarks</label>
								<input type="text" name="LAT_LONG_REMARKS" id="LAT_LONG_REMARKS" size="60">
							</td>
						</tr>
						<tr>
							<td colspan="4">
								<label for="LAT_LONG_REF_SOURCE" class="likeLink" onClick="getDocs('lat_long','reference')">Reference</label>
								<input type="text" name="LAT_LONG_REF_SOURCE" id="LAT_LONG_REF_SOURCE" size="120" class="reqdClr" />
							</td>
						</tr>
						<tr>
							<td colspan="4">
					 			<table id="dms" style="display:none;">
									<tr> 
										<td>
											<label for="lat_deg">Lat. Deg.</label>
											<input type="text" name="LAT_DEG" size="4" id="lat_deg" class="reqdClr">
										</td>
										<td>
											<label for="lat_min">Lat. Min.</label>
											<input type="text" name="LAT_MIN" size="4" id="lat_min" class="reqdClr">
										</td>
										<td>
											<label for="lat_sec">Lat. Sec.</label>
											<input type="text" name="LAT_SEC" id="lat_sec" class="reqdClr">
										</td>
										<td>
											<label for="lat_dir">Lat. Dir.</label>
											<select name="LAT_DIR" size="1" id="lat_dir"  class="reqdClr">
										        <option value="N">N</option>
										        <option value="S">S</option>
										    </select>
										</td>
									</tr>
									<tr>
										<td>
											<label for="long_deg">Long. Deg.</label>
											<input type="text" name="LONG_DEG" size="4" id="long_deg" class="reqdClr">
										</td>
										<td>
											<label for="long_min">Long. Min.</label>
											<input type="text" name="LONG_MIN" size="4" id="long_min" class="reqdClr">
										</td>
										<td>
											<label for="long_sec">Long. Sec.</label>
											<input type="text" name="LONG_SEC" id="long_sec"  class="reqdClr">
										</td>
										<td>
											<label for="long_dir">Long. Dir.</label>
											<select name="LONG_DIR" size="1" id="long_dir" class="reqdClr">
										    	 <option value="E">E</option>
										        <option value="W">W</option>
										    </select>
										</td>
									</tr>
								</table>
								<table id="ddm" style="display:none;">
									<tr> 
										<td>
											<label for="dmlat_deg">Lat. Deg.<label>
											<input type="text" name="dmLAT_DEG" size="4" id="dmlat_deg" class="reqdClr">
										</td>
										<td>
											<label for="dec_lat_min">Lat. Dec. Min.<label>
											<input type="text" name="DEC_LAT_MIN" id="dec_lat_min" class="reqdClr">
										</td>
										<td>
											<label for="dmlat_dir">Lat. Dir.<label>
											<select name="dmLAT_DIR" size="1" id="dmlat_dir" class="reqdClr">
							                	<option value="N">N</option>
							                   	<option value="S">S</option>
							                 </select>
										</td>
									</tr>
									<tr>
										<td>
											<label for="dmlong_deg">Long. Deg.<label>
											<input type="text" name="dmLONG_DEG" size="4" id="dmlong_deg" class="reqdClr">
										</td>
										<td>
											<label for="dec_long_min">Long. Dec. Min.<label>
											<input type="text" name="DEC_LONG_MIN" id="dec_long_min" class="reqdClr">
										</td>
										<td>
											<label for="dmlong_dir">Long. Dir.<label>
											<select name="dmLONG_DIR" size="1" id="dmlong_dir" class="reqdClr">
											    <option value="E">E</option>
											    <option value="W">W</option>
											</select>
										</td>
									</tr>
								</table>
					 			<table id="dd" style="display:none;">
									<tr> 
										<td>
											<label for="dec_lat">Decimal Latitude</label>
											<input type="text" name="DEC_LAT" id="dec_lat"class="reqdClr">
										</td>
										<td>
											<label for="dec_long">Decimal Longitude</label>
											<input type="text" name="DEC_LONG" id="dec_long" class="reqdClr">
										</td>
									</tr>
								</table>
								<table id="utm" style="display:none;">
									<tr> 
										<td>
											<label for="utm_zone">UTM Zone<label>
											<input type="text" name="UTM_ZONE" id="utm_zone" class="reqdClr">
										</td>
										<td>
											<label for="utm_ew">UTM East/West<label>
											<input type="text" name="UTM_EW"  id="utm_ew" class="reqdClr">
										</td>
										<td>
											<label for="utm_ns">UTM North/South<label>
											<input type="text" name="UTM_NS" id="utm_ns" class="reqdClr">
										</td>
									</tr>
								</table>
							</td>
						</tr>
             			<tr> 
			                <td colspan="4">
								<input type="submit" value="Create Determination" class="insBtn">						
							</td>
             			</tr>
            		</table>
				</td>
			</tr>
		</table>
	</form>	
	<hr>
	<strong>Geology Attributes</strong>	
	<cfif geolDet.recordcount gt 0>
		<form name="editGeolAtt" method="post" action="editLocality.cfm">
			<input type="hidden" name="action" value="editGeol">
           	<input type="hidden" name="locality_id" value="#locDet.locality_id#">
			<input type="hidden" name="number_of_determinations" value="#geolDet.recordcount#">
			<cfset i=1>
			<table border>
				<cfloop query="geolDet">
					<input type="hidden" name="geology_attribute_id_#i#" value="#geology_attribute_id#">
					<tr	#iif(i MOD 2,DE("class='evenRow'"),DE("class='oddRow'"))#>
						<td>
							<label for="geology_attribute_#i#">Geology Attribute</label>
							<select name="geology_attribute_#i#" id="geology_attribute_#i#" class="reqdClr" onchange="populateGeology(this.id)">
								<option value="delete" class="red">Delete This</option>
								<cfloop query="ctgeology_attribute">
									<option <cfif #geology_attribute# is geolDet.geology_attribute> selected="selected" </cfif>value="#geology_attribute#">#geology_attribute#</option>
								</cfloop>
							</select>
							<span class="infoLink" onclick="document.getElementById('geology_attribute_#i#').value='delete'">Delete This</span>	
							<label for="geo_att_value">Value</label>
							<select name="geo_att_value_#i#" id="geo_att_value_#i#" class="reqdClr">
								<option value="#geo_att_value#">#geo_att_value#</option>
							</select>
							<label for="geo_att_determiner_#i#">Determiner</label>
							<input type="text" name="geo_att_determiner_#i#"  size="40"
								onchange="getAgent('geo_att_determiner_id_#i#','geo_att_determiner_#i#','editGeolAtt',this.value); return false;"
			 					onKeyPress="return noenter(event);"
			 					value="#agent_name#">
							<input type="hidden" name="geo_att_determiner_id_#i#" id="geo_att_determiner_id" value="#geo_att_determiner_id#">
							<label for="geo_att_determined_date_#i#">Date</label>
							<input type="text" name="geo_att_determined_date_#i#" id="geo_att_determined_date_#i#" value="#dateformat(geo_att_determined_date,'yyyy-mm-dd')#">
							<label for="geo_att_determined_method_#i#">Method</label>
							<input type="text" name="geo_att_determined_method_#i#" size="60"  value="#geo_att_determined_method#">
							<label for="geo_att_remark_#i#">Remark</label>
							<input type="text" name="geo_att_remark_#i#" size="60" value="#geo_att_remark#">
						</td>
					</tr>
					<cfset i=i+1>
				</cfloop>
				<tr>
					<td colspan="2">
						<input type="submit" value="Save Changes"  class="savBtn">
					</td>
				</tr>
			</table>
		</form>
	</cfif>
	<table class="newRec">
		<tr>
			<td>
				<strong>Create Geology Determination</strong>
				<form name="newGeolDet" method="post" action="editLocality.cfm">
		            <input type="hidden" name="action" value="AddGeol">
		            <input type="hidden" name="locality_id" value="#locDet.locality_id#">
					<label for="geology_attribute">Geology Attribute</label>
					<select name="geology_attribute" id="geology_attribute" class="reqdClr" onchange="populateGeology(this.id)">
						<option value=""></option>
						<cfloop query="ctgeology_attribute">
							<option value="#geology_attribute#">#geology_attribute#</option>
						</cfloop>
					</select>
					<label for="geo_att_value">Value</label>
					<select name="geo_att_value" id="geo_att_value" class="reqdClr"></select>
					<label for="geo_att_determiner">Determiner</label>
					<input type="text" name="geo_att_determiner" id="geo_att_determiner" size="40"
								onchange="getAgent('geo_att_determiner_id','geo_att_determiner','newGeolDet',this.value); return false;"
				 				onKeyPress="return noenter(event);">
					<input type="hidden" name="geo_att_determiner_id" id="geo_att_determiner_id">
					<label for="geo_att_determined_date">Determined Date</label>
					<input type="text" name="geo_att_determined_date" id="geo_att_determined_date">
					<label for="geo_att_determined_method">Determination Method</label>
					<input type="text" name="geo_att_determined_method" id="geo_att_determined_method" size="60">
					<label for="geo_att_remark">Remark</label>
					<input type="text" name="geo_att_remark" id="geo_att_remark" size="60">
					<br>
					<input type="submit" 
							value="Create Determination" 
							class="insBtn"
							onmouseover="this.className='insBtn btnhov'"
							onmouseout="this.className='insBtn'">
				</form>
			</td>
		</tr>
	</table>
</cfoutput> 
<cfinclude template="/includes/_footer.cfm">
</cfif>
<!------------------------------------------------------------------------------------------------------>
<cfif action is "editGeol">
<cfoutput>
	<cfloop from="1" to="#number_of_determinations#" index="n">
		<cfset deleteThis="">
		<cfset thisID = #evaluate("geology_attribute_id_" & n)#>
		<cfset thisAttribute = #evaluate("geology_attribute_" & n)#>
		<cfset thisValue = #evaluate("geo_att_value_" & n)#>
		<cfset thisDate = #evaluate("geo_att_determined_date_" & n)#>
		<cfset thisMethod = #evaluate("geo_att_determined_method_" & n)#>
		<cfset thisDeterminer = #evaluate("geo_att_determiner_id_" & n)#>
		<cfset thisRemark = #evaluate("geo_att_remark_" & n)#>
		
		<cfif #thisAttribute# is "delete">
			<cfquery name="deleteGeol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				delete from geology_attributes where geology_attribute_id=#thisID#
			</cfquery>
		<cfelse>
			<cfquery name="upGeol" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				update 
					geology_attributes 
				set 
					geology_attribute='#thisAttribute#',
					geo_att_value='#stripQuotes(thisValue)#'
					<cfif len(#thisDeterminer#) gt 0>
						,geo_att_determiner_id=#thisDeterminer#
					<cfelse>
						,geo_att_determiner_id=NULL
					</cfif>
					<cfif len(#thisDate#) gt 0>
						,geo_att_determined_date='#dateformat(thisDate,"yyyy-mm-dd")#'
					<cfelse>
						,geo_att_determined_date=NULL
					</cfif>
					<cfif len(#thisMethod#) gt 0>
						,geo_att_determined_method='#stripQuotes(thisMethod)#'
					<cfelse>
						,geo_att_determined_method=NULL
					</cfif>
					<cfif len(#thisRemark#) gt 0>
						,geo_att_remark='#stripQuotes(thisRemark)#'
					<cfelse>
						,geo_att_remark=NULL
					</cfif>
				where
					geology_attribute_id=#thisID#
			</cfquery>
		</cfif>
	</cfloop>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
</cfoutput>
</cfif>
<!------------------------------------------------------------------------------------------------------>
<cfif action is "AddGeol">
<cfoutput>
		<cfquery name="changeGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			insert into geology_attributes (
    			locality_id,
			    geology_attribute,
			    geo_att_value
			    <cfif len(#geo_att_determiner_id#) gt 0>
					,geo_att_determiner_id
				</cfif>
				<cfif len(#geo_att_determined_date#) gt 0>
					,geo_att_determined_date
				</cfif>
			   	<cfif len(#geo_att_determined_method#) gt 0>
					,geo_att_determined_method
				</cfif>
			   	<cfif len(#geo_att_remark#) gt 0>
					,geo_att_remark
				</cfif>			    
			   ) values (
			   #locality_id#,
			   '#geology_attribute#',
			   '#stripQuotes(geo_att_value)#'
			   <cfif len(#geo_att_determiner_id#) gt 0>
					,#geo_att_determiner_id#
				</cfif>
				<cfif len(#geo_att_determined_date#) gt 0>
					,'#dateformat(geo_att_determined_date,"yyyy-mm-dd")#'
				</cfif>
				<cfif len(#geo_att_determined_method#) gt 0>
					,'#stripQuotes(geo_att_determined_method)#'
				</cfif>
				<cfif len(#geo_att_remark#) gt 0>
					,'#stripQuotes(geo_att_remark)#'
				</cfif>
			 )
		</cfquery>
		<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "changeGeog">
	<cfoutput>
		<cfquery name="changeGeog" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			UPDATE locality SET geog_auth_rec_id=#geog_auth_rec_id# where locality_id=#locality_id#
		</cfquery>	
		<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "saveLocalityEdit">
	<cfoutput>
	<cfif len(MINIMUM_ELEVATION) gt 0 OR 
			len(MAXIMUM_ELEVATION) gt 0>
		<cfif len(ORIG_ELEV_UNITS) is 0>
			You must provide elevation units if you provide elevation data!
			<cfabort>
		</cfif>
	</cfif>
	<cfif len(ORIG_ELEV_UNITS) gt 0>
		<cfif len(MINIMUM_ELEVATION) is 0 AND 
			len(MAXIMUM_ELEVATION) is 0>
			You can't provide elevation units if you don't provide elevation data!
			<cfabort>
		</cfif>
	</cfif>
	<cfset sql = "UPDATE locality SET locality_id = #locality_id#">
	<cfif len(#spec_locality#) gt 0>
		<cfset sql = "#sql#,spec_locality = '#escapeQuotes(spec_locality)#'">
	  <cfelse>
		<cfset sql = ",spec_locality=null">
	</cfif>
	<cfif len(#MINIMUM_ELEVATION#) gt 0>
		<cfset sql = "#sql#,MINIMUM_ELEVATION = #MINIMUM_ELEVATION#">
	<cfelse>
		<cfset sql = "#sql#,MINIMUM_ELEVATION = null">
	</cfif>
	<cfif len(#MAXIMUM_ELEVATION#) gt 0>
		<cfset sql = "#sql#,MAXIMUM_ELEVATION = #MAXIMUM_ELEVATION#">
	<cfelse>
		<cfset sql = "#sql#,MAXIMUM_ELEVATION = null">
	</cfif>
	<cfif len(#ORIG_ELEV_UNITS#) gt 0>
		<cfset sql = "#sql#,ORIG_ELEV_UNITS = '#ORIG_ELEV_UNITS#'">
	<cfelse>
		<cfset sql = "#sql#,ORIG_ELEV_UNITS = null">
	</cfif>
	<cfif len(#min_depth#) gt 0>
		<cfset sql = "#sql#,min_depth = #min_depth#">
	<cfelse>
		<cfset sql = "#sql#,min_depth = null">
	</cfif>
	<cfif len(#max_depth#) gt 0>
		<cfset sql = "#sql#,max_depth = #max_depth#">
	<cfelse>
		<cfset sql = "#sql#,max_depth = null">
	</cfif>
	<cfif len(#depth_units#) gt 0>
		<cfset sql = "#sql#,depth_units = '#depth_units#'">
	<cfelse>
		<cfset sql = "#sql#,depth_units = null">
	</cfif>
	<cfif len(#LOCALITY_REMARKS#) gt 0>
		<cfset sql = "#sql#,LOCALITY_REMARKS = '#escapeQuotes(LOCALITY_REMARKS)#'">
	<cfelse>
		<cfset sql = "#sql#,LOCALITY_REMARKS = null">
	</cfif>
	<cfif len(#NoGeorefBecause#) gt 0>
		<cfset sql = "#sql#,NoGeorefBecause = '#escapeQuotes(NoGeorefBecause)#'">
	<cfelse>
		<cfset sql = "#sql#,NoGeorefBecause = null">
	</cfif>
	<cfset sql = "#sql# where locality_id = #locality_id#">
	<cfquery name="edLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#		
	</cfquery>
	<cflocation addtoken="no" url="editLocality.cfm?locality_id=#locality_id#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif action is "deleteLocality">
<cfoutput>
	<cfdump var=#form#>
	<cfquery name="isColl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select collecting_event_id from collecting_event where locality_id=#locality_id#
	</cfquery>
	<cfif len(isColl.collecting_event_id) gt 0>
		There are active collecting events for this locality. It cannot be deleted.
		<br><a href="editLocality.cfm?locality_id=#locality_id#">Return</a> to editing.
		<cfabort>
	</cfif>
	<cftransaction>
		<cfquery name="deleLatLong" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from lat_long where locality_id=#locality_id#
		</cfquery>
		<cftransaction action="commit">
		<cfquery name="deleLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from locality where locality_id=#locality_id#
		</cfquery>
	</cftransaction>
	You deleted it.
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #action# is "clone">
	<cfoutput>
		<cftransaction>
			<cfquery name="nLocId" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select sq_locality_id.nextval nv from dual
			</cfquery>
			<cfset lid=nLocId.nv>
			<cfquery name="oldLoc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				select * from locality where locality_id=#locality_id#
			</cfquery>
			<cfquery name="newLocality" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
				INSERT INTO locality (
					LOCALITY_ID,
					GEOG_AUTH_REC_ID
					,MAXIMUM_ELEVATION
					,MINIMUM_ELEVATION
					,ORIG_ELEV_UNITS
					,SPEC_LOCALITY
					,LOCALITY_REMARKS,					
					DEPTH_UNITS,
					MIN_DEPTH,
					MAX_DEPTH,
					NOGEOREFBECAUSE
				) VALUES (
					#lid#,
					#oldLoc.GEOG_AUTH_REC_ID#
					<cfif len(#oldLoc.MAXIMUM_ELEVATION#) gt 0>
						,#oldLoc.MAXIMUM_ELEVATION#
					<cfelse>
						,NULL
					</cfif>
					<cfif len(#oldLoc.MINIMUM_ELEVATION#) gt 0>
						,#oldLoc.MINIMUM_ELEVATION#
					<cfelse>
						,NULL
					</cfif>
					<cfif len(#oldLoc.orig_elev_units#) gt 0>
						,'#oldLoc.orig_elev_units#'
					<cfelse>
						,NULL
					</cfif>
					<cfif len(#oldLoc.SPEC_LOCALITY#) gt 0>
						,'#oldLoc.SPEC_LOCALITY#'
					<cfelse>
						,NULL
					</cfif>
					<cfif len(#oldLoc.LOCALITY_REMARKS#) gt 0>
						,'#oldLoc.LOCALITY_REMARKS#'
					<cfelse>
						,NULL
					</cfif>
					<cfif len(#oldLoc.DEPTH_UNITS#) gt 0>
						,'#oldLoc.DEPTH_UNITS#'
					<cfelse>
						,NULL
					</cfif>
					<cfif len(#oldLoc.MIN_DEPTH#) gt 0>
						,#oldLoc.MIN_DEPTH#
					<cfelse>
						,NULL
					</cfif>
					<cfif len(#oldLoc.MAX_DEPTH#) gt 0>
						,#oldLoc.MAX_DEPTH#
					<cfelse>
						,NULL
					</cfif>
					<cfif len(#oldLoc.NOGEOREFBECAUSE#) gt 0>
						,'#oldLoc.NOGEOREFBECAUSE#'
					<cfelse>
						,NULL
					</cfif>
				)
			</cfquery>
			<cfif isdefined("keepAcc") and keepAcc is 1>
				<cfquery name="accCoord" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select * from lat_long where locality_id=#locality_id# and accepted_lat_long_fg=1
				</cfquery>
				<cfloop query="accCoord">
					<cfquery name="newLL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO lat_long (
							LAT_LONG_ID,
							LOCALITY_ID
							,LAT_DEG
							,DEC_LAT_MIN
							,LAT_MIN
							,LAT_SEC
							,LAT_DIR
							,LONG_DEG
							,DEC_LONG_MIN
							,LONG_MIN
							,LONG_SEC
							,LONG_DIR
							,DEC_LAT
							,DEC_LONG
							,DATUM
							,UTM_ZONE
							,UTM_EW
							,UTM_NS
							,ORIG_LAT_LONG_UNITS
							,DETERMINED_BY_AGENT_ID
							,DETERMINED_DATE
							,LAT_LONG_REF_SOURCE
							,LAT_LONG_REMARKS
							,MAX_ERROR_DISTANCE
							,MAX_ERROR_UNITS
							,NEAREST_NAMED_PLACE
							,LAT_LONG_FOR_NNP_FG
							,FIELD_VERIFIED_FG
							,ACCEPTED_LAT_LONG_FG
							,EXTENT
							,GPSACCURACY
							,GEOREFMETHOD
							,VERIFICATIONSTATUS)
						VALUES (
							sq_lat_long_id.nextval,
							#lid#
							<cfif len(#LAT_DEG#) gt 0>
								,#LAT_DEG#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#DEC_LAT_MIN#) gt 0>
								,#DEC_LAT_MIN#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LAT_MIN#) gt 0>
								,#LAT_MIN#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LAT_SEC#) gt 0>
								,#LAT_SEC#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LAT_DIR#) gt 0>
								,'#LAT_DIR#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LONG_DEG#) gt 0>
								,#LONG_DEG#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#DEC_LONG_MIN#) gt 0>
								,#DEC_LONG_MIN#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LONG_MIN#) gt 0>
								,#LONG_MIN#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LONG_SEC#) gt 0>
								,#LONG_SEC#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LONG_DIR#) gt 0>
								,'#LONG_DIR#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#DEC_LAT#) gt 0>
								,#DEC_LAT#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#DEC_LONG#) gt 0>
								,#DEC_LONG#
							<cfelse>
								,NULL
							</cfif>
							,'#DATUM#'
							<cfif len(#UTM_ZONE#) gt 0>
								,'#UTM_ZONE#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#UTM_EW#) gt 0>
								,'#UTM_EW#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#UTM_NS#) gt 0>
								,'#UTM_NS#'
							<cfelse>
								,NULL
							</cfif>
							,'#ORIG_LAT_LONG_UNITS#'
							,#DETERMINED_BY_AGENT_ID#
							,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#'
							,'#LAT_LONG_REF_SOURCE#'
							<cfif len(#LAT_LONG_REMARKS#) gt 0>
								,'#LAT_LONG_REMARKS#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
								,#MAX_ERROR_DISTANCE#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#MAX_ERROR_UNITS#) gt 0>
								,'#MAX_ERROR_UNITS#'
							<cfelse>
								,NULL
							</cfif>			
							<cfif len(#NEAREST_NAMED_PLACE#) gt 0>
								,'#NEAREST_NAMED_PLACE#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LAT_LONG_FOR_NNP_FG#) gt 0>
								,#LAT_LONG_FOR_NNP_FG#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#FIELD_VERIFIED_FG#) gt 0>
								,#FIELD_VERIFIED_FG#
							<cfelse>
								,NULL
							</cfif>
							,#ACCEPTED_LAT_LONG_FG#
							<cfif len(#EXTENT#) gt 0>
								,#EXTENT#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#GPSACCURACY#) gt 0>
								,#GPSACCURACY#
							<cfelse>
								,NULL
							</cfif>
							,'#GEOREFMETHOD#'
							,'#VERIFICATIONSTATUS#')
					</cfquery>
				</cfloop>
			</cfif>
			<cfif isdefined("keepUnacc") and keepUnacc is 1>
				<cfquery name="uaccCoord" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
					select * from lat_long where locality_id=#locality_id# and accepted_lat_long_fg=0
				</cfquery>
				<cfloop query="uaccCoord">
					<cfquery name="newLL" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
						INSERT INTO lat_long (
							LAT_LONG_ID,
							LOCALITY_ID
							,LAT_DEG
							,DEC_LAT_MIN
							,LAT_MIN
							,LAT_SEC
							,LAT_DIR
							,LONG_DEG
							,DEC_LONG_MIN
							,LONG_MIN
							,LONG_SEC
							,LONG_DIR
							,DEC_LAT
							,DEC_LONG
							,DATUM
							,UTM_ZONE
							,UTM_EW
							,UTM_NS
							,ORIG_LAT_LONG_UNITS
							,DETERMINED_BY_AGENT_ID
							,DETERMINED_DATE
							,LAT_LONG_REF_SOURCE
							,LAT_LONG_REMARKS
							,MAX_ERROR_DISTANCE
							,MAX_ERROR_UNITS
							,NEAREST_NAMED_PLACE
							,LAT_LONG_FOR_NNP_FG
							,FIELD_VERIFIED_FG
							,ACCEPTED_LAT_LONG_FG
							,EXTENT
							,GPSACCURACY
							,GEOREFMETHOD
							,VERIFICATIONSTATUS)
						VALUES (
							sq_lat_long_id.nextval,
							#lid#
							<cfif len(#LAT_DEG#) gt 0>
								,#LAT_DEG#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#DEC_LAT_MIN#) gt 0>
								,#DEC_LAT_MIN#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LAT_MIN#) gt 0>
								,#LAT_MIN#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LAT_SEC#) gt 0>
								,#LAT_SEC#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LAT_DIR#) gt 0>
								,'#LAT_DIR#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LONG_DEG#) gt 0>
								,#LONG_DEG#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#DEC_LONG_MIN#) gt 0>
								,#DEC_LONG_MIN#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LONG_MIN#) gt 0>
								,#LONG_MIN#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LONG_SEC#) gt 0>
								,#LONG_SEC#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LONG_DIR#) gt 0>
								,'#LONG_DIR#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#DEC_LAT#) gt 0>
								,#DEC_LAT#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#DEC_LONG#) gt 0>
								,#DEC_LONG#
							<cfelse>
								,NULL
							</cfif>
							,'#DATUM#'
							<cfif len(#UTM_ZONE#) gt 0>
								,'#UTM_ZONE#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#UTM_EW#) gt 0>
								,'#UTM_EW#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#UTM_NS#) gt 0>
								,'#UTM_NS#'
							<cfelse>
								,NULL
							</cfif>
							,'#ORIG_LAT_LONG_UNITS#'
							,#DETERMINED_BY_AGENT_ID#
							,'#dateformat(DETERMINED_DATE,"yyyy-mm-dd")#'
							,'#LAT_LONG_REF_SOURCE#'
							<cfif len(#LAT_LONG_REMARKS#) gt 0>
								,'#LAT_LONG_REMARKS#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
								,#MAX_ERROR_DISTANCE#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#MAX_ERROR_UNITS#) gt 0>
								,'#MAX_ERROR_UNITS#'
							<cfelse>
								,NULL
							</cfif>			
							<cfif len(#NEAREST_NAMED_PLACE#) gt 0>
								,'#NEAREST_NAMED_PLACE#'
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#LAT_LONG_FOR_NNP_FG#) gt 0>
								,#LAT_LONG_FOR_NNP_FG#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#FIELD_VERIFIED_FG#) gt 0>
								,#FIELD_VERIFIED_FG#
							<cfelse>
								,NULL
							</cfif>
							,#ACCEPTED_LAT_LONG_FG#
							<cfif len(#EXTENT#) gt 0>
								,#EXTENT#
							<cfelse>
								,NULL
							</cfif>
							<cfif len(#GPSACCURACY#) gt 0>
								,#GPSACCURACY#
							<cfelse>
								,NULL
							</cfif>
							,'#GEOREFMETHOD#'
							,'#VERIFICATIONSTATUS#')
					</cfquery>
				</cfloop>
			</cfif>
		</cftransaction>
		<cflocation url="editLocality.cfm?locality_id=#lid#">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #action# is "editAccLatLong">

<cfoutput>

<!--- update things that we're allowing changes to. Set non-original units to null and 
	get them once we have an Oracle procedure in place to handle conversions --->
<cftransaction>
<cfif ACCEPTED_LAT_LONG_FG is 1>
	<cfquery name="flagAllZero" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		update lat_long set ACCEPTED_LAT_LONG_FG=0 where 
		locality_id = #locality_id#
	</cfquery>
</cfif>
<cfset sql = "
	UPDATE lat_long SET
		DATUM = '#DATUM#'
		,ACCEPTED_LAT_LONG_FG = #ACCEPTED_LAT_LONG_FG#	
		,orig_lat_long_units = '#orig_lat_long_units#'
		,determined_date = '#dateformat(determined_date,'yyyy-mm-dd')#'
		,lat_long_ref_source = '#stripQuotes(lat_long_ref_source)#'
		,determined_by_agent_id = #determined_by_agent_id#
		,georefMethod='#georefMethod#'
		,VerificationStatus='#VerificationStatus#'">
		<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
			<cfset sql = "#sql#,MAX_ERROR_DISTANCE = #MAX_ERROR_DISTANCE#">
		  <cfelse>
			<cfset sql = "#sql#,MAX_ERROR_DISTANCE = NULL">
		</cfif>
		<cfif len(#MAX_ERROR_UNITS#) gt 0>
			<cfset sql = "#sql#,MAX_ERROR_UNITS = '#MAX_ERROR_UNITS#'">
		  <cfelse>
			<cfset sql = "#sql#,MAX_ERROR_UNITS = NULL">
		</cfif>
		<cfif len(#LAT_LONG_REMARKS#) gt 0>
			<cfset sql = "#sql#,LAT_LONG_REMARKS = '#stripQuotes(LAT_LONG_REMARKS)#'">
		  <cfelse>
			<cfset sql = "#sql#,LAT_LONG_REMARKS = null">
		</cfif>
		<cfif len(#extent#) gt 0>
			<cfset sql = "#sql#,extent=#extent#">
		<cfelse>
			<cfset sql = "#sql#,extent=null">
		</cfif>
		<cfif len(#GpsAccuracy#) gt 0>
			<cfset sql = "#sql#,GpsAccuracy=#GpsAccuracy#">
		<cfelse>
			<cfset sql = "#sql#,GpsAccuracy=null">
		</cfif>
		<cfif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
			<cfset sql = "#sql#
				,LAT_DEG = #LAT_DEG#
				,LAT_MIN = #LAT_MIN#
				,LAT_SEC = #LAT_SEC#
				,LAT_DIR = '#LAT_DIR#'
				,LONG_DEG = #LONG_DEG#
				,LONG_MIN = #LONG_MIN#
				,LONG_SEC = #LONG_SEC#
				,LONG_DIR = '#LONG_DIR#'
				,DEC_LAT = null
				,DEC_LONG = null
				,UTM_ZONE = null
				,UTM_EW = null
				,UTM_NS = null
				,DEC_LAT_MIN = null
				,DEC_LONG_MIN = null">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
			<cfset sql = "#sql#
				,LAT_DEG = #dmLAT_DEG#
				,LAT_MIN = null
				,LAT_SEC = null
				,LAT_DIR = '#dmLAT_DIR#'
				,LONG_DEG = #dmLONG_DEG#
				,LONG_MIN = null
				,LONG_SEC = null
				,LONG_DIR = '#dmLONG_DIR#'
				,DEC_LAT = null
				,DEC_LONG = null
				,UTM_ZONE = null
				,UTM_EW = null
				,UTM_NS = null				
				,DEC_LAT_MIN = #DEC_LAT_MIN#
				,DEC_LONG_MIN = #DEC_LONG_MIN#
				">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
			<cfset sql = "#sql#
				,LAT_DEG = null
				,LAT_MIN = null
				,LAT_SEC = null
				,LAT_DIR = null
				,LONG_DEG = null
				,LONG_MIN = null
				,LONG_SEC = null
				,LONG_DIR = null
				,DEC_LAT = #DEC_LAT#
				,DEC_LONG = #DEC_LONG#
				,UTM_ZONE = null
				,UTM_EW = null
				,UTM_NS = null				
				,DEC_LAT_MIN = null
				,DEC_LONG_MIN = null
				">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
			<cfset sql = "#sql#
				,LAT_DEG = null
				,LAT_MIN = null
				,LAT_SEC = null
				,LAT_DIR = null
				,LONG_DEG = null
				,LONG_MIN = null
				,LONG_SEC = null
				,LONG_DIR = null
				,DEC_LAT = null
				,DEC_LONG = null
				,UTM_ZONE = '#UTM_ZONE#'
				,UTM_EW = #UTM_EW#
				,UTM_NS = #UTM_NS#				
				,DEC_LAT_MIN = null
				,DEC_LONG_MIN = null
				">
		<cfelse>
			<div class="error">
			You really can't load #ORIG_LAT_LONG_UNITS#. Really. I wouldn't lie to you! Clean up the code table!
			Use your back button or	
			<br><a href="editLocality.cfm?locality_id=#locality_id#">continue editing</a>.
			</div>
			<cfabort>
		</cfif>
		<cfset sql = "#sql#	where lat_long_id=#lat_long_id#">
<cfquery name="upLatLong" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	#preservesinglequotes(sql)#
</cfquery>
</cftransaction>
<cfquery name="getAcc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
	select lat_long_id from lat_long where locality_id=#locality_id#
	and accepted_lat_long_fg = 1
</cfquery>
<cfif #getAcc.recordcount# is 1>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
<cfelseif #getAcc.recordcount# gt 1>
	<div class="error">
	There are more than one accepted lat_longs for this locality. Please change all but one
	of them to unaccepted. A better fix is coming soon.
	
	<br><a href="editLocality.cfm?locality_id=#locality_id#">continue</a>
	</div>
	<cfabort>
<cfelseif #getAcc.recordcount# lt 1>
	<div class="error">
	There are no accepted lat_longs for this locality. Is that what you meant to do?
	<br><a href="editLocality.cfm?locality_id=#locality_id#">continue</a>
	</div>
		<cfabort>
</cfif>
</cfoutput>		
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #action# is "AddLatLong">
<cfoutput>	
	<cfquery name="notAcc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		UPDATE lat_long SET accepted_lat_long_fg = 0 where
		locality_id=#locality_id#
	</cfquery>	
	<cfset sql = "
	INSERT INTO lat_long (
		LAT_LONG_ID
		,LOCALITY_ID
		,ACCEPTED_LAT_LONG_FG
		,lat_long_ref_source
		,determined_by_agent_id
		,determined_date
		,ORIG_LAT_LONG_UNITS
		,georefmethod
		,verificationstatus
		,DATUM
		">
		<cfif len(#extent#) gt 0>
			<cfset sql = "#sql#,extent">
		</cfif>
		<cfif len(#gpsaccuracy#) gt 0>
			<cfset sql = "#sql#,gpsaccuracy">
		</cfif>
		<cfif len(#LAT_LONG_REMARKS#) gt 0>
			<cfset sql = "#sql#,LAT_LONG_REMARKS">
		</cfif>
		<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
			<cfset sql = "#sql#,MAX_ERROR_DISTANCE">
		</cfif>
		<cfif len(#MAX_ERROR_UNITS#) gt 0>
			<cfset sql = "#sql#,MAX_ERROR_UNITS">
		</cfif>
		<cfif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
			<cfset sql="#sql#
			,LAT_DEG
			,LAT_MIN
			,LAT_SEC
			,LAT_DIR
			,LONG_DEG
			,LONG_MIN
			,LONG_SEC
			,LONG_DIR">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
			<cfset sql="#sql#
				,LAT_DEG
				,DEC_LAT_MIN
				,LAT_DIR
				,LONG_DEG
				,DEC_LONG_MIN
				,LONG_DIR
				">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
			<cfset sql="#sql#
				,DEC_LAT
				,DEC_LONG">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
			 <cfset sql="#sql#
			 	,UTM_ZONE
			 	,UTM_EW
			 	,UTM_NS">
		<cfelse>
			<div class="error">
			You really can't load #ORIG_LAT_LONG_UNITS#. Really. I wouldn't lie to you! Clean up the code table!
			Use your back button or	
			<br><a href="editLocality.cfm?locality_id=#locality_id#">continue editing</a>.
			</div>
			<cfabort>
		</cfif>
		<cfset sql="#sql#
		)
	VALUES (
		sq_lat_long_id.nextval,
		#LOCALITY_ID#
		,#ACCEPTED_LAT_LONG_FG#
		,'#stripQuotes(lat_long_ref_source)#'
		,#determined_by_agent_id#
		,'#dateformat(determined_date,'yyyy-mm-dd')#'
		,'#ORIG_LAT_LONG_UNITS#'
		,'#georefmethod#'
		,'#verificationstatus#'
		,'#DATUM#'">
		<cfif len(#extent#) gt 0>
			<cfset sql="#sql#,'#extent#'">
		</cfif>
		<cfif len(#gpsaccuracy#) gt 0>
			<cfset sql = "#sql#,#gpsaccuracy#">
		</cfif>
		<cfif len(#LAT_LONG_REMARKS#) gt 0>
			<cfset sql="#sql#,'#stripQuotes(LAT_LONG_REMARKS)#'">
		</cfif>
		<cfif len(#MAX_ERROR_DISTANCE#) gt 0>
			<cfset sql="#sql#,#MAX_ERROR_DISTANCE#">
		</cfif>
		<cfif len(#MAX_ERROR_UNITS#) gt 0>
			<cfset sql="#sql#,'#MAX_ERROR_UNITS#'">
		</cfif>
		<cfif #ORIG_LAT_LONG_UNITS# is "deg. min. sec.">
		<cfset sql="#sql#			
			,#LAT_DEG#
			,#LAT_MIN#
			,#LAT_SEC#
			,'#LAT_DIR#'
			,#LONG_DEG#
			,#LONG_MIN#
			,#LONG_SEC#
			,'#LONG_DIR#'">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "degrees dec. minutes">
		<cfset sql="#sql#
			,#dmLAT_DEG#
			,#DEC_LAT_MIN#
			,'#dmLAT_DIR#'
			,#dmLONG_DEG#
			,#DEC_LONG_MIN#
			,'#dmLONG_DIR#'">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "decimal degrees">
		<cfset sql="#sql#
			,#DEC_LAT#
			,#DEC_LONG#">
		<cfelseif #ORIG_LAT_LONG_UNITS# is "UTM">
			 <cfset sql="#sql#
			 	,'#UTM_ZONE#'
			 	,#UTM_EW#
			 	,#UTM_NS#">
		</cfif>
		<cfset sql="#sql# )">
	<cfquery name="newLatLong" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		#preservesinglequotes(sql)#
	</cfquery>
	<cfquery name="getAcc" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
		select lat_long_id from lat_long where locality_id=#locality_id#
		and accepted_lat_long_fg = 1
	</cfquery>
<cfif #getAcc.recordcount# is 1>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
<cfelseif #getAcc.recordcount# gt 1>
	<div class="error">
	There are more than one accepted lat_longs for this locality. Please change all but one
	of them to unaccepted. A better fix is coming soon.
	
	<br><a href="editLocality.cfm?locality_id=#locality_id#">continue</a>
	</div>
	<cfabort>
<cfelseif #getAcc.recordcount# lt 1>
	<div class="error">
	There are no accepted lat_longs for this locality. Is that what you meant to do?
	<br><a href="editLocality.cfm?locality_id=#locality_id#">continue</a>
	</div>
		<cfabort>
</cfif>
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
</cfoutput>		
</cfif>
<!---------------------------------------------------------------------------------------------------->
<cfif #action# is "deleteLatLong">
	<cfoutput>
		<cfif #ACCEPTED_LAT_LONG_FG# is "1">
			<div class="error">
			I can't delete the accepted lat/long!
			<cfabort>
			</div>
		</cfif>
		<cfquery name="killLatLong" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,cfid)#">
			delete from lat_long where lat_long_id = #lat_long_id#
		</cfquery>
		
	<cflocation url="editLocality.cfm?locality_id=#locality_id#" addtoken="no">
	</cfoutput>
</cfif>
<!---------------------------------------------------------------------------------------------------->	  