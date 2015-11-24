
<!--- 
	Param the FORM value that will contain the data posted from 
	the ColdFusion Builder extension. This will be in the form of
	the following XML file:
	
	<event>
		<ide>
			<projectview 
				projectname="SomeThing" 
				projectlocation="..." >
				
				<resource 
					path="C:/....txt" 
					type="file" 
					/>
				
			</projectview>
		</ide>
		<user>
			<input name="message" value="..." />
			<input name="name" value="..." />
		</user>
	</event>
--->
<cfparam 
	name="form.ideEventInfo"
	type="string"
	default=""
	/>

	
<!--- 
	Parse the posted XML string into a ColdFusion XML document
	so that we can access the nodes within it.
--->
<cfset requestXml = xmlParse( trim( form.ideEventInfo ) ) />

<!--- 
	Grab the resource node's PATH attribute from the XML post
	into the document we got from ColdFusion builder.
--->
<cfset resourceNodes = xmlSearch(
	requestXml,
	"//resource[ position() = 1 ]/@path"
	) />

<!--- 
	Store the file name into the request attributes (so that 
	we can reference it in the FORM page).
--->
<cfset request.attributes.filePath = resourceNodes[ 1 ].xmlValue />
	
	
<!--- Store the response xml. --->
<cfsavecontent variable="responseXml">
	<cfoutput>
	
		<response showresponse="true"> 
			<ide> 
				<dialog 
					height="800" 
					width="1000" title="Regular Expression Find And Replace"
				 	/> 
				
				<body>
					<![CDATA[
						
						<!--- 
							Include the form (which will start posting to itself 
							going forward).
						--->
						<cfinclude template="../form.cfm" />
					
					]]>
				</body>

			</ide> 
		</response>
		
	</cfoutput>
</cfsavecontent>

<!--- 
	Now, convert the response XML to binary and stream it 
	back to builder.
--->
<cfset responseBinary = toBinary( 
	toBase64( 
		trim( responseXml ) 
		) 
	) />

<!--- 
	Set response content data. This will reset the output 
	buffer, write the data, and then close the response.
--->
<cfcontent
	type="text/xml"
	variable="#responseBinary#"
	/>
	