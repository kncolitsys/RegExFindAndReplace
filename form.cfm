
<!--- Param the form variables. --->
<cfparam name="request.attributes.filePath" type="string" /> <!--- default="C:/ColdFusion9/wwwroot/extensions/rereplace/test.cfm" --->
<cfparam name="request.attributes.isCommitting" type="boolean" default="false" />
<cfparam name="request.attributes.pattern" type="string" default="" />
<cfparam name="request.attributes.patternFlags" type="string" default="" />
<cfparam name="request.attributes.globalReplace" type="boolean" default="false" />
<cfparam name="request.attributes.replaceWith" type="string" default="" />


<!--- Create an instance of our replacer. --->
<cfset replacer = new Replacer() />

<!--- Read the file content. --->
<cfset fileContent = fileRead( request.attributes.filePath ) />


<!--- 
	By default, create a preview result in which the preview content and 
	the file content are the same.
--->
<cfset previewResult = {
	originalContent = fileContent,
	previewContent = fileContent,
	matchCount = 0
	} />
	

<!--- Check to see if we have a pattern. --->
<cfif len( request.attributes.pattern )>
	
	<!--- Try to apply the find and replace. --->	
	<cftry>
	
		<!--- Strip out any non-characrtes from the pattern flags. --->
		<cfset patternFlags = reReplace(
			request.attributes.patternFlags,
			"[^\w]",
			"",
			"all"
			) />
			
		<!--- Check to see if we have any content left over. --->
		<cfif len( patternFlags )>
			
			<!--- Fix syntax for flags. --->
			<cfset patternFlags = "(?#patternFlags#)" />
		
		</cfif>
		
		
		<!--- Check to see if we are committing this find and replace or if we are just previewing it. --->
		<cfif request.attributes.isCommitting>
		
		
			<!--- We are performing the actual replace on the content. --->
		
			<!--- Get the new file content. --->
			<cfset newContent = replacer.commitReplace(
				fileContent,
				(patternFlags & request.attributes.pattern),
				request.attributes.replaceWith,
				request.attributes.globalReplace
				) />
		
			<!--- Write the file back to thd disk. --->
			<cfset fileWrite(
				request.attributes.filePath,
				newContent
				) />
				
			<!--- Redirect to confirmation page. --->
			<cflocation
				url="#application.rootURL#confirm.cfm?filePath=#urlEncodedFormat( request.attributes.filePath )#"
				addtoken="false"
				/>
		
		
		<cfelse>
		
		
			<!--- We are previewing the find and replace. --->
			
			<!--- Get the results of the preview. --->
			<cfset previewResult = replacer.previewReplace(
				fileContent,
				(patternFlags & request.attributes.pattern),
				request.attributes.replaceWith,
				request.attributes.globalReplace
				) />

			
		</cfif>
		
		
		<!--- Catch any errors. --->
		<cfcatch>
			
			<!--- Set the preview data to be the error. --->
			<cfset previewResult.previewContent = "ERROR: Problem with pattern or replace (#cfcatch.message#)." />
		
		</cfcatch>
	
	</cftry>	

</cfif>


<cfoutput>

	<!DOCTYPE HTML>
	<html>
	<head>
		<link rel="stylesheet" type="text/css" href="#application.rootURL#linked/styles.css"></link>
		<script type="text/javascript" src="#application.rootURL#linked/jquery-1.3.2.min.js"></script>
		<script type="text/javascript">
		
			$(function(){
				// Get a reference to the form.
				var form = $( "form:first" );
				
				// Get a reference to the preview tab and content.
				var previewContentTab = $( "##content-tabs a:first" );
				var previewContent = $( "##content-value pre:first" );
				
				// Get a reference to the original tab and content.
				var originalContentTab = $( "##content-tabs a:last" );
				var originalContent = $( "##content-value pre:last" );
				
				
				// Bind to window resize.
				$( window ).resize(
					function(){
						// Get the new body height.
						var bodyHeight = $( document.body ).height();
						
						// Get the height of the form.
						var formHeight = form.height();
					
						// Get the difference.
						// The 40 is for the padding on the form.
						var deltaHeight = (bodyHeight - formHeight - 40);
						
						// Get the content container.
						var contentValue = $( "##content-value" );
					
						// Get the new content value height.
						var newHeight = Math.max( (contentValue.height() + deltaHeight), 200 );
						
						// Set the new height.
						contentValue.height( newHeight );
					}
				)
				// Invoke window resize handler so that we resize immediately.
				.triggerHandler( "resize" )
				;
								
				// Bind clicks on flags to toggle label highlight.
				$( "##pattern-options input" ).click(
					function(){
						var label = $( this ).closest( "label" );
						
						if (this.checked){
							label.addClass( "active" );
						} else {
							label.removeClass( "active" );
						}
					}
				);
				
				// Make sure all appropriate option labels are on (at page load).
				$( "##pattern-options input:checked" )
					.parents( "label" )
						.addClass( "active" )
				;
				
				// Bind to the preview content tab.
				previewContentTab
					.attr( "href", "javascript:void( 0 )" )
					.click(
						function( event ){
							// Toggle tabs.
							originalContentTab.removeClass( "active" );
							previewContentTab.addClass( "active" );
							
							// Toggle content.
							originalContent.hide();
							previewContent.show();
											
							// Cancel default event.
							return( false );
						}
					)
				;
				
				// Bind to the oritinal content tab.
				originalContentTab
					.attr( "href", "javascript:void( 0 )" )
					.click(
						function( event ){
							// Toggle tabs.
							originalContentTab.addClass( "active" );
							previewContentTab.removeClass( "active" );
							
							// Toggle content.
							originalContent.show();
							previewContent.hide();
											
							// Cancel default event.
							return( false );
						}
					)
				;
								
				// Bind the click on the commit button.
				$( "##commit-replace" ).click(
					function(){
						if (confirm( "Are you sure you want to commit the replace?\n\nThis will overwrite your file contents." )){
							// Set the commit flag in the form.
							$( "input[ name = 'isCommitting' ]" ).val( "true" );
							
							// Submit the form.
							form.submit();
						}
					}
				);
			
			});
		
		</script>
	</head>
	<body>
	
		<form action="#application.rootURL#form.cfm?noCache=#randRange( 1, 9999 )#" method="post">
			
			<!---
				Post the name of the file with the form (this is the file we 
				will eventually have to update).
			--->
			<input type="hidden" name="filePath" value="#request.attributes.filePath#" />
			
			<!--- This is a flag to signal commitment of the replace. --->
			<input type="hidden" name="isCommitting" value="false" />
			
			
			<div id="pattern-container">
				
				<label id="pattern-label">
					Regular Expression <em>(full Java support)</em>:
				</label>	
				
				<textarea id="pattern-input" name="pattern">#htmlEditFormat( request.attributes.pattern )#</textarea>
				
				<ul id="pattern-options" class="clear">
					<li>
						<label title="Makes your pattern case-insensitive.">
							<input type="checkbox" name="patternFlags" value="i" 
								<cfif listFind( request.attributes.patternFlags, "i" )>checked="true"</cfif>
								/>
							<strong>(i)</strong> Case Insensitive
						</label>
					</li>
					<li>
						<label title="Makes your replace global (replaces all matches).">
							<input type="checkbox" name="globalReplace" value="true" 
								<cfif request.attributes.globalReplace>checked="true"</cfif>
								/>
							<strong>(g)</strong> Global
						</label>
					</li>
					<li>
						<label title="Standard white-space is ignored. Requires explicit white space.">
							<input type="checkbox" name="patternFlags" value="x" 
								<cfif listFind( request.attributes.patternFlags, "x" )>checked="true"</cfif>
								/>
							<strong>(x)</strong> Verbose
						</label>
					</li>
					<li>
						<label title="Lets ^ and $ match line start and end respectively.">
							<input type="checkbox" name="patternFlags" value="m" 
								<cfif listFind( request.attributes.patternFlags, "m" )>checked="true"</cfif>
								/>
							<strong>(m)</strong> Multiline
						</label>
					</li>
					<li>
						<label title="Let's the dot (.) match the line delimiters.">
							<input type="checkbox" name="patternFlags" value="s" 
								<cfif listFind( request.attributes.patternFlags, "s" )>checked="true"</cfif>
								/>
							<strong>(s)</strong> Singleline / Dot-All
						</label>
					</li>
				</ul>
				
			</div>
			
			
			<div id="replace-with-container">
				
				<label id="replace-with-label">
					Replace With:
				</label>	
				
				<textarea id="replace-with-input" name="replaceWith">#htmlEditFormat( request.attributes.replaceWith )#</textarea>
				
				<div id="replace-with-caption">
					<strong>NOTE:</strong> Use <strong>$N</strong> to reference captured groups.
				</div>
				
			</div>

			
			<div id="content-container">
			
				<div id="content-tabs" class="clear">
					
					<a href="##" class="active">Replace Preview (#previewResult.matchCount# Matches)</a>
					
					<a href="##">Original Content</a>
					
				</div>
				
				<div id="content-value">
				
					<pre>#replacer.prepareContentForPreview( previewResult.previewContent )#</pre>
					
					<pre style="display: none ;">#replacer.prepareContentForPreview( previewResult.originalContent )#</pre>
				
				</div>
			
			</div>
			
			
			<div id="form-actions">
				
				<input id="preview-replace" type="submit" name="previewReplace" value="Preview Replace" />
				
				<input id="commit-replace" type="button" name="commitReplace" value="Commit Replace " />
				
			</div>
		
		</form>
	
	</body>
	</html>

</cfoutput>
