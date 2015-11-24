
<cfcomponent
	output="false"
	hint="I provide find and replace services.">
	
	
	<cffunction 
		name="init" 
		access="public" 
		returntype="any" 
		output="false" 
		hint="I initialize this component.">
		
		<!--- 
			Set some constants for the preview spans. We have two different 
			sets of highlights so that we can alter the preview colors on
			our sets of matches.
		--->
		<cfset this.openHighlighter1 = "::::::1::::::" />
		<cfset this.closeHighlighter1 = "::::::/1::::::" />
		<cfset this.openHighlighter2 = "::::::2::::::" />
		<cfset this.closeHighlighter2 = "::::::/2::::::" />
			
		<!--- Return this object reference. --->
		<cfreturn this />
	</cffunction>
	
	
	<cffunction 
		name="commitReplace" 
		access="public" 
		returntype="string" 
		output="false" 
		hint="I commit the find and replace and return the updated content value.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="content" 
			type="string" 
			required="true" 
			hint="I am the content being searched."
			/>
		
		<cfargument 
			name="pattern" 
			type="string" 
			required="true" 
			hint="I am the regex pattern being matched."
			/>
		
		<cfargument 
			name="replaceWith" 
			type="string" 
			required="true" 
			hint="I am the text being replaced into the matches."
			/>
				
		<cfargument 
			name="isGlobal" 
			type="boolean" 
			required="true" 
			hint="I am flag to determine if the find and replace is a one-off or a global replace."
			/>
		
		<!--- Compile our pattern and get the matcher. --->
		<cfset local.matcher = this.getPatternMatcher( arguments.pattern, arguments.content ) />
		
		<!--- Create a string buffer to hold our replaced content. --->
		<cfset local.contentBuffer = this.getStringBuffer() />

		<!--- Keep looping while the matcher can find matches. --->
		<cfloop condition="local.matcher.find()">
		
			<!--- Append the replacement. --->
			<cfset local.matcher.appendReplacement(
				local.contentBuffer,
				javaCast( "string", arguments.replaceWith )
				) />
			
			<!--- Check to see if this is a global find and replace. --->
			<cfif !arguments.isGlobal>
				
				<!--- They only want to replace the first match, so break. --->
				<cfbreak />
							
			</cfif>
		
		</cfloop>
		
		<!--- 
			Now that we are done looping over the matches, we need to add the tail 
			content to the appropriate buffers.
		--->
		<cfset local.matcher.appendTail( local.contentBuffer ) />
		
		<!--- Serialize the buffer and return its value. --->
		<cfreturn local.contentBuffer.toString() />
	</cffunction>
	
	
	<cffunction 
		name="getHighlighter" 
		access="public" 
		returntype="struct" 
		output="false" 
		hint="I return a struct containing the appropriate open / close highlight elements.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="matchIndex" 
			type="numeric" 
			required="true" 
			hint="I am the current match index."
			/>
		
		<!--- If we can mod correctly, alternate highlighter. --->
		<cfif ((arguments.matchIndex % 2) eq 1)>
			
			<!--- Create the highlighter highlighter. --->
			<cfset local.highlighter = {
				open = this.openHighlighter1,
				close = this.closeHighlighter1
				} />
				
		<cfelse>
		
			<!--- Create the highlighter. --->
			<cfset local.highlighter = {
				open = this.openHighlighter2,
				close = this.closeHighlighter2
				} />
		
		</cfif>
		
		<!--- Return highlighter. --->
		<cfreturn local.highlighter />
	</cffunction>
	
	
	<cffunction 
		name="getPatternMatcher" 
		access="public" 
		returntype="any" 
		output="false" 
		hint="I create a Java regular expression pattern matcher based on the given content and pattern.">
		
		<!--- Define arguments. --->	
		<cfargument 
			name="pattern" 
			type="string" 
			required="true" 
			hint="I am the regular expression pattern."
			/>
		
		<cfargument 
			name="content" 
			type="string" 
			required="true" 
			hint="I am the content being searched."
			/>
		
		<!--- Compile the pattern. --->
		<cfset local.pattern = createObject( "java", "java.util.regex.Pattern" ).compile(
			javaCast( "string", arguments.pattern )
			) />
			
		<!--- Create the pattern matcher. --->
		<cfset local.matcher = local.pattern.matcher(
			javaCast( "string", arguments.content )
			) />
		
		<!--- Return the pattern matcher. --->
		<cfreturn local.matcher />
	</cffunction>
	
	
	<cffunction 
		name="getStringBuffer" 
		access="public" 
		returntype="any" 
		output="false" 
		hint="I return a Java string buffer.">
	
		<cfreturn createObject( "java", "java.lang.StringBuffer" ).init() />		
	</cffunction>
	
	
	<cffunction 
		name="highlight" 
		access="public" 
		returntype="string" 
		output="false" 
		hint="I wrap the given content in the appropriate highligheter (based on the match count).">
	
		<!--- Define arguments. --->
		<cfargument 
			name="content" 
			type="string" 
			required="true" 
			hint="I am the content being highlighted."
			/>
		
		<cfargument 
			name="matchIndex"
			type="numeric" 
			required="true" 
			hint="I am the index of the current match."
			/>
			
		<!--- Get the proper highlighter. --->
		<cfset local.highlighter = this.getHighlighter( arguments.matchIndex ) />
		
		<!--- Wrap the content in the highlighter. --->
		<cfreturn (local.highlighter.open & arguments.content & local.highlighter.close) />		
	</cffunction>
	
	
	<cffunction 
		name="prepareContentForPreview" 
		access="public" 
		returntype="string" 
		output="false" 
		hint="I prepare the content for preview by escaping HTML characters and un-espcaping the highlight characters.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="content" 
			type="string" 
			required="true" 
			hint="I am the content being displayed."
			/>
		
		<!--- Esacpe content so that it will display in the PRE tags fine. --->
		<cfset local.content = htmlEditFormat( arguments.content ) />
		
		<!--- Remove first set of highlights. --->
		<cfset local.content = local.content.replaceAll(
			javaCast( "string", this.openHighlighter1 ),
			javaCast( "string", "<span>" )
			) />
			
		<!--- Remove first set of highlights. --->
		<cfset local.content = local.content.replaceAll(
			javaCast( "string", this.closeHighlighter1 ),
			javaCast( "string", "</span>" )
			) />
			
		<!--- Remove second set of highlights. --->
		<cfset local.content = local.content.replaceAll(
			javaCast( "string", this.openHighlighter2 ),
			javaCast( "string", "<em>" )
			) />
			
		<!--- Remove second set of highlights. --->
		<cfset local.content = local.content.replaceAll(
			javaCast( "string", this.closeHighlighter2 ),
			javaCast( "string", "</em>" )
			) />			
			
		<!--- Return escaped, formatted content. --->
		<cfreturn local.content />
	</cffunction>
	
	
	<cffunction 
		name="previewReplace" 
		access="public" 
		returntype="struct" 
		output="false" 
		hint="I preview the replace, returning the original (with highlights), the new (with highlights), and the number of matches.">
		
		<!--- Define arguments. --->
		<cfargument 
			name="content" 
			type="string" 
			required="true" 
			hint="I am the content being searched."
			/>
		
		<cfargument 
			name="pattern" 
			type="string" 
			required="true" 
			hint="I am the regex pattern being matched."
			/>
		
		<cfargument 
			name="replaceWith" 
			type="string" 
			required="true" 
			hint="I am the text being replaced into the matches."
			/>
				
		<cfargument 
			name="isGlobal" 
			type="boolean" 
			required="true" 
			hint="I am flag to determine if the find and replace is a one-off or a global replace."
			/>
		
		<!--- Let's set up the default return value. --->
		<cfset local.result = {
			previewContent = "",
			originalContent = "",
			matchCount = 0
			} />
		
		<!--- Compile our pattern and get the matcher. --->
		<cfset local.matcher = this.getPatternMatcher( arguments.pattern, arguments.content ) />
		
		<!--- 
			Create two string buffers, one two hold the original content 
			and one to hold the preview content.
		--->
		<cfset local.originalContentBuffer = this.getStringBuffer() />
		<cfset local.previewContentBuffer = this.getStringBuffer() />
	
	
		<!--- 
			Before we start replacing, we need to keep track of the replace 
			offset. We need to do this since building our original buffer 
			doesn't provide any inherit offsets (like that matcher supplies).
		--->
		<cfset local.replaceOffset = 1 />
		
		<!--- Keep looping while the matcher can find matches. --->
		<cfloop condition="local.matcher.find()">
		
			<!--- Increment the match count. --->
			<cfset ++local.result.matchCount />
		
			
			<!--- Take care of the Original content. --->
			<!--- ---------------------------------- --->
			
			<!--- Get the content before this match. --->
			<cfset local.preMatchContent = mid( 
				arguments.content, 
				local.replaceOffset, 
				(local.matcher.start() - local.replaceOffset + 1) 
				) />
			
			<!--- Append the pre-match content to the buffer. --->
			<cfset local.originalContentBuffer.append(
				javaCast(
					"string",
					(local.preMatchContent & this.highlight( local.matcher.group(), local.result.matchCount ))
					)
				) />
			
			<!--- 
				Update the offset (to be one past the current match. 
				NOTE: Remember, matcher() start position is zero-based (hence the 
				adding of one).
			--->
			<cfset local.replaceOffset = (local.matcher.start() + len( local.matcher.group() ) + 1) />
			
			
			<!--- Take care of the Preview content. --->
			<!--- --------------------------------- --->
			
			<!--- Append the replace preview. --->
			<cfset local.matcher.appendReplacement(
				local.previewContentBuffer,
				javaCast( 
					"string",
					this.highlight( arguments.replaceWith, local.result.matchCount )
					)
				) />
			
			
			<!--- Check to see if this is a global find and replace. --->
			<cfif !arguments.isGlobal>
				
				<!--- They only want to replace the first match, so break. --->
				<cfbreak />
							
			</cfif>
		
		</cfloop>
		
		
		<!--- 
			Now that we are done looping over the matches, we need to add the tail 
			content to the appropriate buffers.
		--->
		
		<!--- Take care of the Original content. --->
		<!--- ---------------------------------- --->
		
		<!--- Add the rest of the original content. --->
		<cfset local.originalContentBuffer.append(
			javaCast(
				"string",
				mid( arguments.content, local.replaceOffset, (len( arguments.content ) - local.replaceOffset) )
				)
			) />
		
				
		<!--- Take care of the Preview content. --->
		<!--- --------------------------------- --->
		
		<!--- Append the preview tail. --->
		<cfset local.matcher.appendTail( local.previewContentBuffer ) />
		
		
		<!--- Serialize the content and store it into our results. --->
		<cfset local.result.originalContent = local.originalContentBuffer.toString() />
		<cfset local.result.previewContent = local.previewContentBuffer.toString() />
		
		<!--- Return result. --->
		<cfreturn local.result />
	</cffunction>
	
</cfcomponent>