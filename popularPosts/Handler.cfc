<!---
LICENSE INFORMATION:

Copyright 2008, Adam Tuttle
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not 
use this file except in compliance with the License. 

You may obtain a copy of the License at 

	http://www.apache.org/licenses/LICENSE-2.0 
	
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
CONDITIONS OF ANY KIND, either express or implied. See the License for the 
specific language governing permissions and limitations under the License.

VERSION INFORMATION:

This file is part of Popular Posts Mango Blog Plugin Beta1 (0.1).
--->
<cfcomponent>

	<cfset variables.name = "PopularPosts">
	<cfset variables.displayName = "Popular Posts">
	<cfset variables.id = "com.tuttle.mango.plugins.popularPosts">
	<cfset variables.package = "com/tuttle/mango/plugins/PopularPosts"/>
	<cfset variables.configEvent = "popularPostsSettings" />
	
	<cffunction name="init" 	access="public"		output="false" 		returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />
		
		<cfset var blogid = arguments.mainManager.getBlog().getId() />
		<cfset var path = blogid & "/" & variables.package />
		<cfset variables.preferencesManager = arguments.preferences />
		<cfset variables.manager = arguments.mainManager />
		<cfset variables.intPopularPostCount = variables.preferencesManager.get(path,"popularCount","5") />
		<cfset variables.strHeading = variables.preferencesManager.get(path,"popularHeading","Popular Posts") />

		<cfreturn this/>
	</cffunction>
	<cffunction name="getName"	access="public" 	output="false" 		returntype="string">
		<cfreturn variables.name />
	</cffunction>
	<cffunction name="setName" 	access="public" 	output="false" 		returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>
	<cffunction name="getId" 	access="public" 	output="false" 		returntype="any">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" 	access="public" 	output="false" 		returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>
	<cffunction name="setup"	access="public" 	output="false" 		returntype="any" 		hint="This is run when the plugin is activated">
		<cfreturn "#variables.name# plugin activated. Would you like to <a href='generic_settings.cfm?event=#variables.configEvent#&amp;owner=#variables.name#&amp;selected=#variables.configEvent#'>configure it</a> now?" />
	</cffunction>
	<cffunction name="unsetup"	access="public"		output="false"		returntype="any"		hint="This is run when the plugin is de-activated">
		<cfreturn "Plugin de-activated." />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="remove" hint="This is run when the plugin is removed" access="public" output="false" returntype="any">
		<cfset var blogid = arguments.mainManager.getBlog().getId() />
		<cfset variables.preferencesManager.removeNode(blogid & "/" & variables.package) />
		<cfreturn "Removed #variables.name#" />
	</cffunction>

	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />		
		<cfreturn />
	</cffunction>

	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

			<cfset var link = "" />
			<cfset var pod = "" />
			<cfset var path = "" />
			<cfset var page = "" />
			<cfset var eventName = arguments.event.name />
			<cfset var data = ""/>
			<cfset var result = 0 />

			<cfif eventName EQ "getPods">
				<cfset pod = cacheCallback("com.tuttle.PopularPosts", CreateTimeSpan(0,0,5,0), this.getPopularPosts)/>
				<!--- <cfset pod = getPopularPosts() /> --->
				<cfset result = arguments.event.addPod(pod) />

			<!--- admin nav event --->
			<cfelseif eventName EQ "settingsNav">
				<cfset link = structnew() />
				<cfset link.page = "settings" />
				<cfset link.title = "Popular Posts" />
				<cfset link.owner = variables.name>
				<cfset link.eventName = variables.configEvent />
				<cfset arguments.event.addLink(link)>

			<!--- admin event --->
			<cfelseif eventName IS variables.configEvent AND variables.manager.isCurrentUserLoggedIn()>
				<cfset data = arguments.event.getData() />
				<cfif structkeyexists(data.externaldata,"apply")>
					
					<cfset path = variables.manager.getBlog().getId() & "/" & variables.package />

					<cfset variables.intPopularPostCount = data.externaldata.intPopularPostCount />
					<cfset variables.preferencesManager.put(path,"popularCount",variables.intPopularPostCount) />

					<cfset variables.strHeading = data.externaldata.strHeading />
					<cfset variables.preferencesManager.put(path,"popularHeading",variables.strHeading) />

					<cfset data.message.setstatus("success") />
					<cfset data.message.setType("settings") /> 
					<cfset data.message.settext("#variables.displayName# settings updated successfully")/>
				</cfif>
				
				<cfsavecontent variable="page">
					<cfinclude template="admin/settingsForm.cfm">
				</cfsavecontent>
					
				<!--- change message --->
				<cfset data.message.setTitle("#variables.displayName# Settings") />
				<cfset data.message.setData(page) />
			
			<!--- no content, just title and id --->
			<cfelseif eventName EQ "getPodsList">
				<cfset pod = structnew() />
				<cfset pod.title = variables.name />
				<cfset pod.id = variables.name />
				<cfset arguments.event.addPod(pod)>
			</cfif>
		
		<cfreturn arguments.event />
	</cffunction>

	<cffunction name="getPopularPosts" output="false" returntype="struct">
		<cfset var pod = StructNew() />
		<cfset var qData = "" />
		<cfset var objPost = "" />
		<cfset var objPostMgr = variables.manager.getPostsManager() /> <!--- .getPostById('3F7E3EE2-A43E-D298-43FC9734E3FDC2B8') --->
		<cfset var objQryAdapter = application.blogManager.getQueryInterface() />
		<cfset var strTablePrefix = objQryAdapter.getTablePrefix() />
		<cfset var sqlPopularPosts = "SELECT TOP #variables.intPopularPostCount# 
						count(#strTablePrefix#comment.id) as CommentCount, #strTablePrefix#entry.id 
						FROM #strTablePrefix#comment INNER JOIN #strTablePrefix#entry 
						ON #strTablePrefix#comment.entry_id=#strTablePrefix#entry.id 
						GROUP BY entry.id
						ORDER BY CommentCount DESC"/>
		<cfset var qryPopularPosts = objQryAdapter.makeQuery(sqlPopularPosts) />

		<cfsavecontent variable="pod.content">
			<cfoutput>
			<ul id="popular">
			<cfloop query="qryPopularPosts">
				<cfset objPost = objPostMgr.getPostById(qryPopularPosts.id) />
				<li<cfif currentRow eq 1> class="first"<cfelseif currentRow eq qryPopularPosts.recordCount> class="last"</cfif>>
					<a href="#variables.manager.getBlog().getBasePath()##objPost.getUrl()#" rel="follow">#objPost.getTitle()#</a>
				</li>
			</cfloop>
			</ul>
			</cfoutput>		
		</cfsavecontent>
		
		<cfset pod.title = variables.strHeading />
		<cfset pod.id = variables.name />
		
		<cfreturn pod />
	</cffunction>

<cfscript>
	function cacheCallback(cacheKey, duration, callback){
		var data = "";
		//optional argument: forceRefresh
		if (arrayLen(arguments) eq 4){arguments.forceRefresh=arguments[4];}else{arguments.forceRefresh=false;}
		//clean cachekey of periods that will cause errors
		arguments.cacheKey = replace(arguments.cacheKey, ".", "_", "ALL");
		//ensure cache structure is setup
		if (not structKeyExists(application, "CCBCache")){application.CCBCache = StructNew();}
		if (not structKeyExists(application.CCBCache, arguments.cacheKey)){application.CCBCache[arguments.cacheKey] = StructNew();}
		if (not structKeyExists(application.CCBCache[arguments.cacheKey], "timeout")){application.CCBCache[arguments.cacheKey].timeout = dateAdd('yyyy',-10,now());}
		if (not structKeyExists(application.CCBCache[arguments.cacheKey], "data")){application.CCBCache[arguments.cacheKey].data = '';}
		//update cache if expired
		if (arguments.forceRefresh or dateCompare(now(), application.CCBCache[arguments.cacheKey].timeout) eq 1){
			data = arguments.callback();
			application.CCBCache[arguments.cacheKey].data = data;
			application.CCBCache[arguments.cacheKey].timeout = arguments.duration;
		}
		return application.CCBCache[arguments.cacheKey].data;
	}
</cfscript>

</cfcomponent>