<cfcomponent
	output="false"
	hint="I define the application settings and event handlers.">

	<!--- Set up application properties. --->
	<cfset this.name = hash( getCurrentTemplatePath() ) />
	<cfset this.applicationTimeout = createTimeSpan( 0, 0, 30, 0 ) />

	<!--- Set up request level properties. --->
	<cfsetting showdebugoutput="false" />
	
	
	<cffunction 
		name="onApplicationStart" 
		access="public" 
		returntype="boolean" 
		output="false" 
		hint="I initialize the application.">
		
		<!--- The root of the application. --->
		<cfset application.rootDirectory = getDirectoryFromPath(
			getCurrentTemplatePath()
			) />
			
		<!--- The log directory. --->
		<cfset application.logDirectory = (
			application.rootDirectory & 
			"log/"
			) />
			
		<!--- Get the base script for our application. --->
		<cfset application.rootScriptName = getDirectoryFromPath( cgi.script_name ) />
			
		<!--- 
			Let's figure out how deep the current request is. We 
			will need this to figure out the root URL.
		--->
		<cfset local.scriptDepth = (
			listLen( expandPath( application.rootScriptName ), "\/" ) - 
			listLen( application.rootDirectory, "\/" )
			) />
			
		<!--- 
			Based on the depth, remove as many directories from 
			the end of the root script as is needed.
		--->
		<cfset application.rootScriptName = reReplace(
			application.rootScriptName,
			"([^\\/]+[\\/]){#local.scriptDepth#}$",
			"",
			"one"			
			) />
			
		<!--- 
			Now that we have the root script name, we can figure 
			out the root URL.
		--->
		<cfset application.rootURL = (
			"http://" & 
			cgi.server_name & ":" &
			cgi.server_port &
			application.rootScriptName
			) />
			
		<!--- Return true so the application can load. --->
		<cfreturn true />
	</cffunction>
	
	
	<cffunction 
		name="onRequestStart" 
		access="public" 
		returntype="boolean" 
		output="false" 
		hint="I initialize the request.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="template" 
			type="string" 
			required="true" 
			hint="I am the template being requested."
			/>
		
		<!--- Check to see if the application needs to be initialized. --->
		<cfif !isNull( url.reset )>
			<cfset this.onApplicationStart() />	
		</cfif>
		
		
		<!--- Merge the URL and FORM into a single scope. --->
		<cfset request.attributes = duplicate( url ) />
		<cfset structAppend( request.attributes, form ) />
		
		<!--- Log the request attributes for debugging. --->
		<!--- <cfset this.logData( request.attributes ) /> --->
		
		<!--- Retur true so request can run. --->
		<cfreturn true />
	</cffunction>
	
	
	<cffunction 
		name="onRequest" 
		access="public" 
		returntype="void" 
		output="true" 
		hint="I execute the requested template.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="template" 
			type="string" 
			required="true" 
			hint="I am the template being requested."
			/>
			
		<!--- 
			Include the requested template.
		
			NOTE: It is important that we manually execute the 
			requested template because that creates an include-
			based mixin, which gives the executing template 
			access to the Application.cfc-scope method, logData().
		--->
		<cfinclude template="#arguments.template#" />
		
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
	
	
	<cffunction 
		name="onError" 
		access="public" 
		returntype="void" 
		output="true" 
		hint="I log the error to a log file.">
		
		<!--- Log this error. --->
		<cfset this.logData( argumentCollection = arguments ) />
		
		<p>
			An error occurred. <em>Check log files.</em>
		</p>
		
		<!--- Return out. --->	
		<cfreturn />
	</cffunction>
	
	
	<!--- ------------------------------------------------- --->
	<!--- ------------------------------------------------- --->
	
	
	<cffunction 
		name="logData" 
		access="public" 
		returntype="void" 
		output="false" 
		hint="I log the argument collection to a log file.">
		
		<!--- Output arguments to a new log file. --->
		<cfdump 
			var="#arguments#" 
			label="Log Data Arguments"
			format="html"
			output="#application.logDirectory##createUUID()#.htm"
			/>
			
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
	
</cfcomponent>