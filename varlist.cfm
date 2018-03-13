<cfset callers = 0>
<cfif ParameterExists(attributes.varlist)>
	<cfset callers = 1>
	<cfset varlist = attributes.varlist>
<cfelseif ParameterExists(varlist)>
<cfelse>
	<cfset varlist = "">
</cfif>

<cfif ParameterExists(attributes.query)>
	<cfset quer = attributes.query>
<cfelseif parameterExists(query)>
	<cfset quer = query>
<cfelse>
	<cfset quer = "">
</cfif>

<cfif ParameterExists(attributes.updateTable)>
	<cfset updateTable = -5>
	<!--- you can't read this out of an attribute and then expect it
		to accurately pull in variable values from another attribute --->
<cfelseif parameterExists(updatetable)>
<cfelse>
	<cfset updateTable = -5>
</cfif>

<cfif ParameterExists(attributes.updateDatasource)>
	<cfset updateDatasource = -5>
<cfelseif parameterExists(updateDatasource)>
<cfelse>
	<cfset updateDatasource = -5>
</cfif>

<cfif ParameterExists(attributes.whereClause)>
	<cfset updateDatasource = -5>
<cfelseif parameterExists(whereClause)>
<cfelse>
	<cfset updateDatasource = -5>
</cfif>

<cfif (updateDatasource is -5) or (updateTable is -5) or (whereClause is -5)>
	<cfset updateDatasource = -5>
	<cfset updateTable = -5>
	<cfset whereClause = -5>
</cfif>

<!--- <cfset varlist = "EMAIL_ADDRESS.a, FIRST_NAME.a, LAST_NAME.a, PHONE.a, FAX.a, send_by_email.a, send_by_fax.a, search_id.n, moo.a"> --->

<cfset varlist = Replace(varlist, " ", "", "ALL")>

<cfset loopcount = 0>
<cfset varsonly = "">

<cfif updateTable is -5>
  <cfloop list="#varlist#" index="alvin">
	<cfset loopcount = loopcount + 1>

	<cfset simonloopcount = 0>
	<cfset thisvar = "">
	<cfset thisvartype = "n">
	<cfset thisvarlength = "">
	<cfloop list="#alvin#" index="simon" delimiters=".">
		<cfset simonloopcount = simonloopcount + 1>
		<cfif simonloopcount is  1>
			<cfset thisvar = simon>
		<cfelseif simonloopcount is 2>
		  <cfif simon is "">
		  	<cfset thisvartype = "n">
		  <cfelse>
			<cfset thisvartype = simon>
		  </cfif>
		<cfelseif simonloopcount is 3>
		  <cfif simon is "">
		  	<cfset thisvarlength = "">
		  <cfelse>
			<cfset thisvarlength = simon>
		  </cfif>
		 </cfif>
	</cfloop>
	
	
<!--- 	<cfset thisvartype = right(alvin, 1)>
	<cfset thisvar = left(alvin, (len(alvin) - 2))> --->

	<cfset formvar = "form." & trim(thisvar)>
	<cfset urlvar = "url." & trim(thisvar)>
	<cfset callervar = "caller." & trim(thisvar)>
	<cfif callers is 0>
		<cfset callervar = trim(thisvar)>
	</cfif>
	<cfif quer is not "">
		<cfset queryvar = quer & "." & trim(thisvar)>
	<cfelse>
		<cfset queryvar = "blarg.blarg">
	</cfif>
	
	<cfset varsonly = ListAppend(varsonly, thisvar)>

	<cfset bob = Evaluate("ParameterExists(#queryvar#)")>
	
	<cfif IsDefined("#thisvar#")>
		<cfset thisvarval = evaluate("#thisvar#")>
		<!--- deal with lengths --->
		<cfif isNumeric(thisvarlength) and (thisvarlength is not "") and (thisvartype is "a")>
			<cfif thisvarlength - int(thisvarlength) is not 0>
				<cfset thisvarlength = int(thisvarlength)>
			</cfif>
			
			<cfif len(thisvarval) is 0>
				<cfset thisvarval = "">
				<cfset "#callervar#" = "">
			<cfelseif len(thisvarval) gt (thisvarlength)>
				<cfset thisvarval = left(thisvarval, thisvarlength)>
				<cfset "#callervar#" = thisvarval>
			</cfif>				
		</cfif>
	<cfelseif IsDefined("#formvar#")>
		<cfset thisvarval = evaluate("#formvar#")>
		<cfif isNumeric(thisvarlength) and (thisvarlength is not "") and (thisvartype is "a")>
			<cfif thisvarlength - int(thisvarlength) is not 0>
				<cfset thisvarlength = int(thisvarlength)>
			</cfif>
			
			<cfif len(thisvarval) is 0>
				<cfset thisvarval = "">
			<cfelseif len(thisvarval) gt (thisvarlength)>
				<cfset thisvarval = left(thisvarval, thisvarlength)>
			</cfif>				
		</cfif>

		<cfparam name="#callervar#" default="#thisvarval#">
	<cfelseif IsDefined("#urlvar#")>
		<cfset thisvarval = evaluate("#urlvar#")>
		<cfif isNumeric(thisvarlength) and (thisvarlength is not "") and (thisvartype is "a")>
			<cfif thisvarlength - int(thisvarlength) is not 0>
				<cfset thisvarlength = int(thisvarlength)>
			</cfif>
			
			<cfif len(thisvarval) is 0>
				<cfset thisvarval = "">
			<cfelseif len(thisvarval) gt (thisvarlength)>
				<cfset thisvarval = left(thisvarval, thisvarlength)>
			</cfif>				
		</cfif>

		<cfparam name="#callervar#" default="#thisvarval#">
	<cfelseif IsDefined("#queryvar#")>
		<cfset "#callervar#" = Evaluate("#queryvar#")>
	<cfelse>
<!--- 		<cfif remote_addr is "209.151.254.241">
			<cfoutput>#queryvar#, #bob#</cfoutput>
		</cfif> --->
	  <cfif thisvartype is "n">
		<cfparam name="#callervar#" default="0">
	  <cfelseif thisvartype is "y">
		<cfparam name="#callervar#" default="0">
	  <cfelse>
		<cfparam name="#callervar#" default="">
	  </cfif>
	</cfif>
	
  </cfloop>
</cfif>

<cfif updateTable is not -5>

 <cfquery name="make_update" datasource="#updateDatasource#">
  update #updateTable#
  set 
  <cfloop list="#varlist#" index="alvin">
	<cfset loopcount = loopcount + 1>
	<cfset thisvartype = right(alvin, 1)>
	<cfset thisvar = left(alvin, (len(alvin) - 2))>
	
	<cfset varsonly = ListAppend(varsonly, thisvar)>
	  <cfif loopcount is not 1>, </cfif>
	  #thisvar# = 
	  <cfif (thisvartype is "n") or (thisvartype is "y")><cfelse>'</cfif>#Evaluate('#thisvar#')#<cfif (thisvartype is "n") or (thisvartype is "y")><cfelse>'</cfif>

  </cfloop>
  #whereClause#
 </cfquery>
</cfif>

<cfif callers is not 0>
	<cfset caller.varsonly = varsonly>
</cfif>


