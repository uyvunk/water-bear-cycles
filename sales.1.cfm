<cf_varlist varlist="type.n, name.a, phone.a, email.a, make.a, model.a, condition.n, notes.a">
<cf_varlist varlist="errors.a, success.n, imageList.a">

<cfparam name="year" default="#year(now())#">

<!--- UploadImage button was clicked --->
<cfif isDefined("form.uploadImage")>
	<cfset destination = #bicycleImageDirectory#>
	<!---If the directory doesn't exist... create it! --->
	<cfif not directoryExists(destination)>
		<cfdirectory action="create" directory="#destination#">
	</cfif>
	<!---Check that the input file exists--->
	<cfif not isDefined("form.inputImage") or trim(form.inputImage) eq "">
		<cfset errors = listappend(errors,"Please select an image to be uploaded.",";")>
	<cfelse>
		<!--- Upload the file (try to anyway)--->
		<cftry>
			<cffile action="upload" filefield="inputImage" destination="#destination#" nameconflict="makeUnique" accept="image/*" result="uploadResult">
			<cfcatch>
				<cfset errors = listappend(errors,"Please select a valid image file to be uploaded. 10MB limit.",";")>
			</cfcatch>
		</cftry>
		<cfif isDefined("uploadResult") and uploadResult.fileWasSaved>
			<cfset newFile = uploadResult.serverdirectory & "\" & uploadResult.serverfile>
			<!--- If the file is over 10MB, delete it. --->
			<cfif uploadResult.fileSize gt (10 * 1048576)>
				<cfset errors = listappend(errors,"Images have a 10MB limit.",";")>
				<cffile action="delete" file="#newFile#">				
			<!--- If the file has an image's extension, but isn't a real image, we'll catch it here: --->
			<!--- Ex. "image3.jpg" which could actually be a txt file with its extension renamed to ".jpg" (or maybe something more malicious) --->
			<cfelseif not isImageFile(newFile)>
				<cfset errors = listappend(errors,"Please select a VALID image file to be uploaded.",";")>
				<cffile action="delete" file="#newFile#">
			<cfelse>
				<!--- At this point we have determined that we have a real image. --->
				<!--- If the uploaded file is over 1000px wide or tall, resize it and resave it. --->
				<cfimage action="INFO" source="#newFile#" structName="objImageInfo">
				<cfset maxSize = 1000>
				<cfif objImageInfo.width gt maxSize or objImageInfo.height gt maxSize>
					<cfimage action="read" name="myImage" source="#newFile#">
					<cfset ImageSetAntialiasing(myImage,"on")> <!---Set to off to increase performance--->
					<cfset ImageScaleToFit(myImage,maxSize,maxSize)>
					<cfimage action="WRITE" source="#myImage#" destination="#newFile#" overwrite="true">
				<cfelse>
					<!--- For all other files, call convert to recompress the image. Coldfusion's compression is dramatically reducing image sizes
						  (for jpegs anyway).--->
					<cfimage action="CONVERT" source="#newFile#" destination="#newFile#" overwrite="true">				
				</cfif>
				<cfset imageList = listAppend(imageList,uploadResult.serverfile,";")>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfif isDefined("btnSubmit")>
	<!--- Validation --->
	<cfif type neq 0 and type neq 1>
		<cfset errors = listAppend(errors, "Type is required.", ";")>
	</cfif>
	<cfif name eq "">
		<cfset errors = listAppend(errors, "Name is required.", ";")>
	</cfif>
	<cfif phone eq "" and email eq "">
		<cfset errors = listAppend(errors, "Phone or Email is required.", ";")>
	</cfif>
	<cfif condition neq 0 and condition neq 1 and condition neq 2>
		<cfset errors = listAppend(errors, "Condition is required.", ";")>
	</cfif>
	<!--- End Validation --->
	<cfif errors eq "">
		<cfset notes = Replace(notes, chr(10), "<br>", "ALL")>
		<cfset notes = Replace(notes, chr(13),"","ALL")>
		<!--- Insert record --->
		<!---
		<cfquery name="insertContactEmail" datasource="#dsn#">
			INSERT INTO contactEmail(name, email, subject, message, createDate, createIP)
			VALUES
			(
				<cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#email#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#subject#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#message#" cfsqltype="cf_sql_varchar">,
				getDate(),
				<cfqueryparam value="#REMOTE_ADDR#" cfsqltype="cf_sql_varchar">
			)
		</cfquery>--->
		<!--- Send mail --->
		<cfmail to="#waterBearEmail#" from="online@waterbearcycles.com" subject="Online Sales Order" type="html">
		  <table width="100%" border="0" cellspacing="0" cellpadding="4">
		  		<tr>
					<td width="150" align="right" valign="top"><b>Type:&nbsp;&nbsp;</b></td>
					<td valign="top"><cfif type eq 0>Get Cash<cfelseif type eq 1>Consign</cfif></td>
				</tr>
		  		<tr>
					<td colspan="2"><b>&nbsp;&nbsp;Contact Information</b></td>
				</tr>
				<tr>
					<td width="150" align="right" valign="top"><b>Name:&nbsp;&nbsp;</b></td>
					<td valign="top">#name#</td>
				</tr>
				<tr>
					<td width="150" align="right" valign="top"><b>Email:&nbsp;&nbsp;</b></td>
					<td valign="top">#email#</td>
				</tr>
				<tr>
					<td width="150" align="right" valign="top"><b>Phone:&nbsp;&nbsp;</b></td>
					<td valign="top">#phone#</td>
				</tr>
				<tr>
					<td colspan="2"><b>&nbsp;&nbsp;Bicycle Information</b></td>
				</tr>
				<tr>
					<td width="150" align="right" valign="top"><b>Make:&nbsp;&nbsp;</b></td>
					<td valign="top">#make#</td>
				</tr>
				<tr>
					<td width="150" align="right" valign="top"><b>Model:&nbsp;&nbsp;</b></td>
					<td valign="top">#model#</td>
				</tr>				
				<tr>
					<td width="150" align="right" valign="top"><b>Year:&nbsp;&nbsp;</b></td>
					<td valign="top">#year#</td>
				</tr>
				<tr>
					<td width="150" align="right" valign="top"><b>Condition:&nbsp;&nbsp;</b></td>
					<td valign="top"><cfif condition eq 0>Excellent<cfelseif condition eq 1>Good<cfelseif condition eq 2>Fair</cfif></td>
				</tr>
				<tr>
					<td width="150" align="right" valign="top"><b>Description:&nbsp;&nbsp;</b></td>
					<td valign="top">#notes#</td>
				</tr>
				<cfif imageList neq "">
					<tr>
						<td colspan="2"><b>&nbsp;&nbsp;Images:</b></td>
					</tr>
				</cfif>
			</table>
			<cfloop list="#imageList#" delimiters=";" index="listItem">
				<p>
					<img src="cid:#listItem#" width="350" height="263" alt="" /><br />
				</p>						
			</cfloop>
			<cfloop list="#imageList#" delimiters=";" index="listItem">
				<cfset loc = bicycleImageDirectory & "\" & listItem>
 				<cfmailparam file="#loc#" contentid="#listItem#" disposition="inline"/>		
			</cfloop>	
		</cfmail>
		<cfset success = 1>
		<!--- Reset fields --->
		<cfset type = 0>
		<cfset name = "">
		<cfset phone = "">
		<cfset email = "">
		<cfset make = "">
		<cfset model = "">
		<cfset year = year(now())>
		<cfset condition = 0>
		<cfset notes = "">
		<cfset imageList = "">
	</cfif>		
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta charset="utf-8">
<title>Sell you used bicycle | WaterBearCycles Trading</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css/style.css" rel="stylesheet" type="text/css">
</head>
<body>
<form name="form1" id="form1" action="sales.cfm" method="post" enctype="multipart/form-data">
	<input type="hidden" name="imageList" value="<cfoutput>#imageList#</cfoutput>">
<body bgcolor="#000000" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>&nbsp;</td>
    <td width="980"><cfinclude template="topnav.cfm"></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td width="980" bgcolor="#FFFFFF"><cfoutput>
      <table cellpadding="0" cellspacing="0" class="bodytext" width="50%" border="0">
        <tr>
          <td align="center"><table cellpadding="0" cellspacing="0" width="90%" align="center" class="bodytext" border="0">
              <tr>
                <th width="2%">     
                <th width="23%">     
                <th width="73%">     
                <th width="2%">     
              </tr>
			  <cfset i = 0>
			  <cfloop list="#errors#" index="e" delimiters=";">
				<tr>
					<td>&nbsp;</td>
					<td align="right"><cfif i eq 0><font size="2" face="Verdana, Arial, Helvetica, sans-serif" style="Color:Red">Errors: </font><cfelse>&nbsp;</cfif></td>
					<td align="left" colspan="2"><font size="2" face="Verdana, Arial, Helvetica, sans-serif" style="Color:Red">&nbsp;&nbsp;#e#</font></td>
				</tr>
				<cfset i +=1>
			  </cfloop>
			  <cfif success>
			  	<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
			  	<tr>
					<td colspan="4"><font size="2" face="Verdana, Arial, Helvetica, sans-serif" style="Color:Green"><b>Submission successful. <br>Your estimate should be returned within 48 hours. <br>Thank you.</font></b></td>
				</tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
			  <cfelse>
				  <tr>
					<td colspan="4" align="center">&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Type:</font></td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;
						  <input type="radio" name="type" value="0" <cfif type eq 0>checked="checked"</cfif> />
					  &nbsp; Get Cash</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right">&nbsp;</td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;
						  <input type="radio" name="type" value="1" <cfif type eq 1>checked="checked"</cfif>/>
					  &nbsp; Consign</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr><td colspan="4"><hr /></td></tr>			  		
				  <tr>
					<td colspan="4"><b>Contact Information</b></td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Name:<span style="Color:Red;">*</span></font></td>
					<td align="left">&nbsp;&nbsp;<font size="2" face="Verdana, Arial, Helvetica, sans-serif">
						<input type="text" name="name" size="20" value="#name#" /></font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Phone:<span style="Color:Red;">*</span></font></td>
					<td align="left">&nbsp;&nbsp;<font size="2" face="Verdana, Arial, Helvetica, sans-serif">
						<input type="text" name="phone" size="20" value="#phone#" /></font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Email:<span style="Color:Red;">*</span></font></td>
					<td align="left">&nbsp;&nbsp;<font size="2" face="Verdana, Arial, Helvetica, sans-serif">
						<input type="text" name="email" size="20" value="#email#" /></font></td>
					<td>&nbsp;</td>
				  </tr>	
				  <tr><td colspan="4"><hr /></td></tr>			  		
				  <tr>
					<td colspan="4"><b>Bicycle Information</b></td>
				  </tr>			  		  			  			  
				  <tr>
					<td>&nbsp;</td>
					<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Make:</font></td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp;
						  <input type="text" name="make" size="20" value="#make#" />
					</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Model:</font></td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp;
						  <input type="text" name="model" size="20" value="#model#" />
					</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Year:</font></td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;&nbsp;
						  <cfset yr = year(now()) + 1>
						  <select name="year">
							<option value="0" selected>-Select Year-</option>
							<cfloop condition="yr gte 1998">
							  <option value="#yr#" <cfif yr eq year> selected="selected"</cfif>>#yr#</option>
							  <cfset yr = yr - 1>
							</cfloop>
						  </select>
					</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Condition:</font></td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;
						  <input type="radio" name="condition" value="0" <cfif condition eq 0>checked="checked"</cfif> />
					  &nbsp; Excellent</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right">&nbsp;</td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;
						  <input type="radio" name="condition" value="1" <cfif condition eq 1>checked="checked"</cfif>/>
					  &nbsp; Good</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right">&nbsp;</td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;
						  <input type="radio" name="condition" value="2" <cfif condition eq 2>checked="checked"</cfif>/>
					  &nbsp; Fair</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td colspan="4">&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right">&nbsp;</td>
					<td align="left"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">Desciption, Approx. miles, Specs</font></td>
					<td>&nbsp;</td>
				  </tr>
				  <tr>
					<td>&nbsp;</td>
					<td align="right">&nbsp;</td>
					<td><textarea name="notes" rows="5" cols="32" id="notes">#notes#</textarea>
					</td>
					<td>&nbsp;</td>
				  </tr>
				  <tr><td colspan="4"><hr /></td></tr>			  		
				  <tr>
					<td colspan="4"><b>Image Uploads <br>(Optional. You can upload up to 3 images.)</b></td>
				  </tr>	
				<tr>
					<td>&nbsp;</td>
					<td align="left" style="vertical-align:top;" class="fontBold">Image:</td>
					<td align="left" class="font"><input type="file" name="inputImage" size="20"/>&nbsp;&nbsp;<input name="uploadImage" type="submit" value="Upload"></td>
					<td>&nbsp;</td>								
				</tr>
				<cfloop list="#imageList#" delimiters=";" index="listItem">
					<tr>
						<td>&nbsp;</td>
						<td>&nbsp;</td>
						<td>#listItem#</td>
						<td>&nbsp;</td>
					</tr>
				</cfloop>
				  <tr><td colspan="4"><hr /></td></tr>	
				  <tr>
					<td colspan="4" align="center">&nbsp;</td>
				  </tr>
				  <tr>
					<td colspan="4" align="center"><input type="submit" name="btnSubmit" value="Submit"></td>
				  </tr>
				  <tr>
					<td colspan="4" align="center">&nbsp;</td>
				  </tr>
			</cfif>
          </table></td>
        </tr>
      </table>
    </cfoutput></td>
            <td valign="top"><p>&nbsp;</p></td>
          </tr>
        </tbody>
      </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tbody>
    <tr>
      <td>&nbsp;</td>
      <td width="980"><img src="images/bottomofsite04.jpg" width="980" height="300" alt=""/></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="40">&nbsp;</td>
      <td width="980" height="40" align="center"><strong><font color="#CCCCCC" size="1" face="Verdana, Arial, Helvetica, sans-serif">Copyright &copy; 2016 WaterBear Cycles Trading</font></strong><BR>
      <a href="disclaimer.cfm"><font face="Verdana, Arial, Helvetica, sans-serif" color="#FFCC33" size="2"><strong>DISCLAIMER</strong></font></a></td>
      <td height="40">&nbsp;</td>
    </tr>
  </tbody>
</table>
</body>
</html>
