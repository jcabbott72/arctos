<!--- no security --->
<cfinclude template="../includes/_pickHeader.cfm">
<cfif action is "nothing">

<script>
	jQuery(document).ready(function() {
		$(".reqdClr:visible").each(function(e){
		    $(this).prop('required',true);
		});
	});
	 function fileSelected() {
        var file = document.getElementById('fileToUpload').files[0];
        if (file) {
          var fileSize = 0;
          if (file.size > 1024 * 1024)
            fileSize = (Math.round(file.size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
          else
            fileSize = (Math.round(file.size * 100 / 1024) / 100).toString() + 'KB';

          document.getElementById('fileName').innerHTML = 'Name: ' + file.name;
          document.getElementById('fileSize').innerHTML = 'Size: ' + fileSize;
          document.getElementById('fileType').innerHTML = 'Type: ' + file.type;
        }
      }

      function uploadFile() {
        var fd = new FormData();
        fd.append("fileToUpload", document.getElementById('fileToUpload').files[0]);
        var xhr = new XMLHttpRequest();
        xhr.upload.addEventListener("progress", uploadProgress, false);
        xhr.addEventListener("load", uploadComplete, false);
        xhr.addEventListener("error", uploadFailed, false);
        xhr.addEventListener("abort", uploadCanceled, false);
        xhr.open("POST", "/component/utilities.cfc?method=loadFile&returnFormat=json");
        xhr.send(fd);
      }

      function uploadProgress(evt) {
        if (evt.lengthComputable) {
          var percentComplete = Math.round(evt.loaded * 100 / evt.total);
          document.getElementById('progressNumber').innerHTML = percentComplete.toString() + '%';
        }
        else {
          document.getElementById('progressNumber').innerHTML = 'unable to compute';
        }
      }

      function uploadComplete(evt) {
        /* This event is raised when the server send back a response */


		var result = JSON.parse(evt.target.responseText);


        if (result.STATUSCODE=='200'){

        	$("#uploadtitle").html('File Uploaded: You MUST now fill in this form and and click the "create" button to finish.');
        	$("#uploadmediaform").hide();
        	var h='<form name="nm" method="post" action="specimenMedia.cfm">';
        	h+='<input type="hidden" name="collection_object_id"  value="' + $("#collection_object_id").val() + '">';
        	h+='<input type="hidden" name="action"  value="createNewMedia">';


        	h+='<label for="media_uri">Media URI</label>';
        	h+='<input type="text" name="media_uri" class="reqdClr" id="media_uri" size="80" value="' + result.MEDIA_URI + '">';
        	h+='<a href="' + result.MEDIA_URI + '" target="_blank" class="external">open</a>';
        	h+='<label for="preview_uri">Preview URI</label>';
        	h+='<input type="text" name="preview_uri" id="preview_uri" size="80" value="' + result.PREVIEW_URI + '">';
        	h+='<a href="' + result.PREVIEW_URI + '" target="_blank" class="external">open</a>';

        	h+='<label for="media_license_id">License</label>';
        	h+='<select name="media_license_id" id="media_license_id"></select>';

			h+='<label for="mime_type">MIME Type</label>';
        	h+='<select name="mime_type" id="mime_type" class="reqdClr"></select>';


			h+='<label for="media_type">Media Type</label>';
        	h+='<select name="media_type" id="media_type" class="reqdClr"></select>';


        	h+='<label for="creator">Created By</label>';
        	h+='<input type="hidden" name="created_agent_id" id="created_agent_id">';

        	h+='<input type="text" name="creator" id="creator"';
			h+='onchange="pickAgentModal(\'creator\',this.id,this.value); return false;"';
			h+='onKeyPress="return noenter(event);" placeholder="pick creator" class="minput">';

			h+='<label for="description">Description</label>';
        	h+='<input type="text" name="description" id="description" size="80">';


			h+='<label for="made_date">Made Date</label>';
        	h+='<input type="text" name="made_date" id="made_date">';





			h+='<br><input type="submit" value="create media">';
			h+='</form>';




			$("#newMediaUpBack").html(h);




			$('#ctmedia_license').find('option').clone().appendTo('#media_license_id');
			$('#ctmime_type').find('option').clone().appendTo('#mime_type');
			$('#ctmedia_type').find('option').clone().appendTo('#media_type');

			$("#made_date").datepicker();
			// guess mime/media type
			var fext=result.MEDIA_URI.split('.').pop().toLowerCase();


			if (fext=='jpg' || fext=='jpeg'){
				$("#mime_type").val('image/jpeg');
				$("#media_type").val('image');
			} else if (fext=='pdf'){
				$("#mime_type").val('application/pdf');
				$("#media_type").val('text');
			} else if (fext=='png'){
				$("#mime_type").val('image/png');
				$("#media_type").val('image');
			} else if (fext=='txt'){
				$("#mime_type").val('text/plain');
				$("#media_type").val('text');
			} else if (fext=='txt'){
				$("#mime_type").val('text/html');
				$("#media_type").val('text');
			}

			$("#created_agent_id").val($("#myAgentID").val());
			$("#creator").val($("#username").val());
			$(".reqdClr:visible").each(function(e){
			    $(this).prop('required',true);
			});
        } else {
        	alert('ERROR: ' + result.MSG);
        	$("#progressNumber").html('');
        }
      }

      function uploadFailed(evt) {
        alert("There was an error attempting to upload the file.");
        	$("#progressNumber").html('');
      }

      function uploadCanceled(evt) {
        alert("The upload has been canceled by the user or the browser dropped the connection.");
        	$("#progressNumber").html('');
      }



</script>

<cfoutput>
	<cfquery name="ctmedia_license" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ctmedia_license order by DISPLAY
	</cfquery>
	<cfquery name="ctmime_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ctmime_type order by mime_type
	</cfquery>
	<cfquery name="ctmedia_type" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select * from ctmedia_type order by media_type
	</cfquery>
	<div style="display:none">
		<!--- easy way to get stuff for new media - just clone from here ---->
		<select name="ctmedia_type" id="ctmedia_type">
			<option></option>
			<cfloop query="ctmedia_type">
				<option value="#media_type#">#media_type#</option>
			</cfloop>
		</select>
		<select name="ctmedia_license" id="ctmedia_license">
			<option></option>
			<cfloop query="ctmedia_license">
				<option value="#MEDIA_LICENSE_ID#">#DISPLAY#</option>
			</cfloop>
		</select>
		<select name="ctmime_type" id="ctmime_type">
			<option></option>
			<cfloop query="ctmime_type">
				<option value="#mime_type#">#mime_type#</option>
			</cfloop>
		</select>
		<input type="hidden" id="myAgentID" value="#session.myAgentID#">
		<input type="hidden" id="username" value="#session.username#">
	</div>



	<div id="uploadtitle">Upload Media Files</div>

	<div id="uploadmediaform">
		<form id="form1" enctype="multipart/form-data" method="post" action="">
			<div class="row">
			<label for="fileToUpload">Select a File to Upload</label>
			<input type="file" name="fileToUpload" id="fileToUpload" onchange="fileSelected();"/>
			</div>
			<div id="fileName"></div>
			<div id="fileSize"></div>
			<div id="fileType"></div>
			<div class="row">
			<input type="button" onclick="uploadFile()" value="Upload" />
			</div>
			<div id="progressNumber"></div>
		</form>
	</div>
	<div id="newMediaUpBack"></div>

	<hr>Link specimen to existing Arctos Media.
	<span class="likeLink" onclick="findMedia('p_media_uri','p_media_id');">Click here to pick</span> or enter Media ID and save.
	<form id="picklink" method="post" action="specimenMedia.cfm">
		<input type="hidden" name="action" value="linkpicked">
		<input type="hidden" id="collection_object_id" name="collection_object_id" value="#collection_object_id#">
		<label for="">Media ID</label>
		<input type="number" class="reqdClr" name="p_media_id" id="p_media_id">
		<label for="p_media_uri">Picked MediaURI</label>
		<input type="text" size="80" name="p_media_uri" id="p_media_uri" class="readClr">
		<br><input type="submit" value="link specimen to picked media">
	</form>
	<hr>
	<a target="_blank" href="/media.cfm?action=newMedia&collection_object_id=#collection_object_id#">Create Media</a>
	 for more options (<em>e.g.</em>, link to YouTube, relate to Events).
	<hr>
	Existing Media for this specimen


	<cfquery name="smed" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
		select distinct
			media.media_id,
			media.MEDIA_URI,
			media.MIME_TYPE,
			media.MEDIA_TYPE,
			media.PREVIEW_URI,
			media.MEDIA_LICENSE_ID,
			media.MEDIA_URI,
			ctmedia_license.DISPLAY,
			ctmedia_license.DESCRIPTION,
			ctmedia_license.URI
		from
			media_relations,
			media,
			ctmedia_license
		where
			media_relations.media_relationship='shows cataloged_item' and
			media_relations.related_primary_key=#collection_object_id# and
			media_relations.media_id=media.media_id and
			media.MEDIA_LICENSE_ID=ctmedia_license.MEDIA_LICENSE_ID (+)
		order by
			media_id
	</cfquery>
	<style>
		.tbl{
			display: table;
			width:80%;
			border:1px solid black;
			margin:1em;
			padding:1em;}
		.tr{display: table-row;}
		.td-left{
			display: table-cell;
			width:30%;
		}
		.td-right{
			display: table-cell;
			width:68%;
			vertical-align: middle;
			padding:0 0 0 1em;
		}
	</style>
	<cfset  func = CreateObject("component","component.functions")>
	<cfloop query="smed">
		<cfset relns=func.getMediaRelations(media_id=#media_id#)>
		<cfset mp = func.getMediaPreview(preview_uri="#preview_uri#",media_type="#media_type#")>
		<cfquery name="lbl" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			select MEDIA_LABEL,LABEL_VALUE from media_labels where media_id=#media_id# order by media_label,label_value
		</cfquery>
		<div class="tbl">
			<div class="tr">
				<div class="td-left">
					<a target="_blank" href="#MEDIA_URI#"><img src="#mp#" style="max-width:150px;max-height:150px;"></a>
					<a target="_blank" href="/media.cfm?action=edit&media_id=#media_id#">Edit Media</a>
					<cfif len(DISPLAY) gt 0>
						<a style="font-size:x-small" href="#media_id#" class="external" target="_blank">#DISPLAY# (#DESCRIPTION#)</a>
					</cfif>
				</div>
				<div class="td-right">
					<div style="font-size:small">
						<cfloop query="relns">
							<br>#MEDIA_RELATIONSHIP#
							<cfif len(LINK) gt 0>
								<a href="#LINK#" target="_blank">#SUMMARY#</a>
							<cfelse>
								#SUMMARY#
							</cfif>
						</cfloop>

						<cfloop query="lbl">
							<br>#MEDIA_LABEL#: #LABEL_VALUE#
						</cfloop>
					</div>
				</div>
			</div>
		</div>
	</cfloop>

</cfoutput>
</cfif>
<cfif action is "linkpicked">
	<cfoutput>
		<cfquery name="linkpicked" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
			insert into media_relations (
				MEDIA_ID,
				MEDIA_RELATIONSHIP,
				CREATED_BY_AGENT_ID,
				RELATED_PRIMARY_KEY
			) values (
				#p_media_id#,
				'shows cataloged_item',
				#session.myAgentId#,
				#collection_object_id#
			)
		</cfquery>
		<cflocation url="specimenMedia.cfm?collection_object_id=#collection_object_id#">
	</cfoutput>
</cfif>
<cfif action is "createNewMedia">
	<cfoutput>
		<cftransaction>
			<cfquery name="mid" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				select sq_media_id.nextval mid from dual
			</cfquery>
			<cfquery name="newmedia" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into media (
					MEDIA_ID,
					MEDIA_URI,
					MIME_TYPE,
					MEDIA_TYPE,
					PREVIEW_URI,
					MEDIA_LICENSE_ID
				) values (
					#mid.mid#,
					'#media_uri#',
					'#mime_type#',
					'#MEDIA_TYPE#',
					'#PREVIEW_URI#',
					<cfif len(media_license_id) gt 0>
						#media_license_id#
					<cfelse>
						NULL
					</cfif>
				)
			</cfquery>
			<cfquery name="linkpicked" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
				insert into media_relations (
					MEDIA_ID,
					MEDIA_RELATIONSHIP,
					CREATED_BY_AGENT_ID,
					RELATED_PRIMARY_KEY
				) values (
					#mid.mid#,
					'shows cataloged_item',
					#session.myAgentId#,
					#collection_object_id#
				)
			</cfquery>
			<cfif len(created_agent_id) gt 0>
				<cfquery name="created_agent_id" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into media_relations (
						MEDIA_ID,
						MEDIA_RELATIONSHIP,
						CREATED_BY_AGENT_ID,
						RELATED_PRIMARY_KEY
					) values (
						#mid.mid#,
						'created by agent',
						#session.myAgentId#,
						#created_agent_id#
					)
				</cfquery>
			</cfif>
			<cfif len(description) gt 0>
				<cfquery name="description" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into media_labels (
						MEDIA_ID,
						MEDIA_LABEL,
						LABEL_VALUE,
						ASSIGNED_BY_AGENT_ID
					) values (
						#mid.mid#,
						'description',
						'#escapeQuotes(description)#',
						#session.myAgentId#
					)
				</cfquery>
			</cfif>
			<cfif len(made_date) gt 0>
				<cfquery name="made_date" datasource="user_login" username="#session.dbuser#" password="#decrypt(session.epw,session.sessionKey)#">
					insert into media_labels (
						MEDIA_ID,
						MEDIA_LABEL,
						LABEL_VALUE,
						ASSIGNED_BY_AGENT_ID
					) values (
						#mid.mid#,
						'made date',
						'#escapeQuotes(made_date)#',
						#session.myAgentId#
					)
				</cfquery>
			</cfif>
		</cftransaction>
		<cflocation url="specimenMedia.cfm?collection_object_id=#collection_object_id#">
	</cfoutput>
</cfif>




<!----
<form action="/component/utilities.cfc?method=loadFile&returnFormat=json" class="dropzone" id="demo-upload">

  <div class="dz-message">
    Drop files here or click to upload.<br />
    <span class="note">(This is just a demo dropzone. Selected files are <strong>not</strong> actually uploaded.)</span>
  </div>

</form>

<form name="m">
	<input type="text" name="media_uri" id="media_uri">
	<input type="text" name="media_id" id="media_id">
</form>
---->
</p>

<cfinclude template="../includes/_pickFooter.cfm">