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
				<cfset loc = bicycleImageDirectory & "\" & listItem>
 				<cfmailparam file="#loc#" contentID="#listItem#" disposition="inline">
				 <p>
					<img src="cid:#listItem#" width="350" height="263" alt="" /><br />
				</p>
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
  <cfif type eq 0>
    <title>Cash for Bicycles | WaterBear Cycles Trading</title>
  <cfelse>
    <title>Bicycle Consignments | WaterBear Cycles Trading</title>
  </cfif>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <link href="https://fonts.googleapis.com/css?family=Lato" rel="stylesheet" type="text/css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  <link href="css/style.css" rel="stylesheet" type="text/css">
</head>
<body>
	<div class="header">
		<a href="./#myPage"><img id="brandLogo" src="images/logo.png" alt="Water Bear Cycles Trading"></a>
	</div>
	<nav id="navBar" class="navbar navbar-default navbar-fixed-top" data-spy="affix" data-offset-top="100">
		<div class="container-fluid">
			<div class="navbar-header">
				<button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span> 
				</button>
			</div>
			<div class="collapse navbar-collapse" id="myNavbar">
				<ul class="nav navbar-nav navbar-right">
					<li><a href="./#myPage">HOME</a></li>
					<li><a href="./#howitworks">HOW IT WORKS</a></li>
					<li><a href="./#about">ABOUT</a></li>
					<li><a href="./#contact">CONTACT US</a></li>
					<li><a href="./#shipping">BICYCLE PACKING &amp; SHIPPING SERVICES</a></li>
					<li><a href="./#consignmentfees">COSIGNMENT FEE</a></li>
				</ul>
			</div>
		</div>
	</nav>
	<div class="container">
		<form name="form1" id="form1" action="sales.cfm" method="post" enctype="multipart/form-data">
			<input type="hidden" name="imageList" value="<cfoutput>#imageList#</cfoutput>">
			<cfoutput>
				<cfset i = 0>
				<cfloop list="#errors#" index="e" delimiters=";">
					<div class="alert alert-danger">
						<strong>Errors:</strong>#e#
					</div>
					<cfset i +=1>
				</cfloop>
				<cfif success>
					<div class="alert alert-success">
						<strong>Submission successful.</strong>
						<br>Your estimate should be returned within 48 hours.
						<br>Thank you.
					</div>
				<cfelse>
					<h3>Type</h3>
					<div class="checkbox">
						<label><input type="radio" name="type" value="0" <cfif type eq 0>checked</cfif>> Get Cash</label>
					</div>
					<div class="checkbox">
						<label><input type="radio" name="type" value="1" <cfif type eq 1>checked="checked"</cfif>> Consign</label>
					</div>
					<h3>Contact Information</h3>
					<div class="form-group">
						<label for="name">Name:</label>
						<input type="text" name="name" size="20" class="form-control" value="#name#" placeholder="Enter name">
					</div>
					<div class="form-group">
						<label for="phone">Phone:</label>
						<input type="text" name="phone" class="form-control" size="20" value="#phone#" placeholder="Enter phone number">
					</div>
					<div class="form-group">
						<label for="email">Email:</label>
						<input type="email" name="email" size="20" class="form-control" value="#email#" placeholder="Enter email">
					</div>

					<h3>Bicycle Information</h3>
					<div class="form-group">
						<label for="make">Make:</label>
						<input type="text" name="make" size="20" class="form-control" value="#make#" placeholder="Enter make">
					</div>
					<div class="form-group">
						<label for="model">Model:</label>
						<input type="text" name="model" size="20" class="form-control" value="#model#" placeholder="Enter model">
					</div>
					<div class="form-group">
						<label for="year">Year:</label>
						<cfset yr = year(now()) + 1>
						  <select name="year">
								<option value="0" selected>-Select Year-</option>
								<cfloop condition="yr gte 1998">
									<option value="#yr#" <cfif yr eq year> selected="selected"</cfif>>#yr#</option>
									<cfset yr = yr - 1>
								</cfloop>
						  </select>
					</div>
					<div class="form-group">
						<label for="condition">Condition:</label><br>
						<input type="radio" name="condition" value="0" <cfif condition eq 0>checked="checked"</cfif> /> Excellent<br>
						<input type="radio" name="condition" value="1" <cfif condition eq 1>checked="checked"</cfif> /> Good<br>
						<input type="radio" name="condition" value="2" <cfif condition eq 2>checked="checked"</cfif> /> Fair<br>
					</div>
					<div class="form-group">
						<label for="notes">Desciption, Approx. miles, Specs:</label>
						<textarea class="form-control" name="notes" rows="5" cols="32" id="notes">#notes#</textarea>
					</div>
					<h3>Image Uploads</h3>
					<p>(Optional. You can upload up to 3 images.)</p>
					<ol>
						<li>Click on "Browse" to select an image</li>
						<li>Click on "Upload" to upload the image to our server</li>
						<li>Once image is finished uploading click "Submit" to upload form</li>
					</ol>
					<div class="form-group">
						<input type="file" name="inputImage" size="20"/>
						<input name="uploadImage" type="submit" value="Upload"/>
					</div>
					<ul>
						<cfloop list="#imageList#" delimiters=";" index="listItem">
							<li>#listItem#</li>
						</cfloop>
					</ul>
					<div class="text-center">
						<input class="btn btn-success" type="submit" name="btnSubmit" value="Submit"/>
					</div>
				</cfif>
			</cfoutput>
		</form>
	</div>
  <div><cfinclude template="footer.cfm"></div>
</body>
</html>
