
<!--- Param the request attributes. --->
<cfparam name="request.attributes.filePath" type="string" />

<!--- Read the live file content. --->
<cfset fileContent = fileRead( request.attributes.filePath ) />


<!DOCTYPE HTML>
<html>
<head>
	<style type="text/css">
		
		body {
			background-color: #F8F8F8 ;
			color: #333333 ;
			font-size: 12px ;
			font-family: verdana, arial ;
			margin: 20px 20px 20px 20px ;
			}
			
		h1 {
			border-bottom: 1px dotted #999999 ;
			font-size: 26px ;
			font-weight: 400 ;
			margin: 0px 0px 20px 0px ;
			padding: 0px 0px 10px 0px ;
			text-align: center ;
			}
			
		h1 span {
			font-size: 11px ;
			text-transform: uppercase ;
			vertical-align: middle ;
			}
			
		h1 a {
			color: #999999 ;
			}
		
	</style>
</head>
<body>
	
	<cfoutput>
	
		<h1>
			Regular Expression Find And Replace Complete
			
			<span>
				( <a href="#application.rootURL#form.cfm?filePath=#urlEncodedFormat( request.attributes.filePath )#&noCache=#randRange( 1, 9999 )#">Continue Replacing</a> )
			</span>
		</h1>
		
		<pre>#htmlEditFormat( fileContent )#</pre>	
		
	</cfoutput>

</body>
</html>
