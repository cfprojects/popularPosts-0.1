<!--
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
-->
<style type="text/css">
<!--
fieldset {
	margin-bottom: 1em;
	border: 1px solid #E8E8E8;
}
legend {
	font-weight: bold;
	padding: 0 5px 0 5px;
}

label {
	display: block;
	width: 160px;
	float: left;
	padding-left: 5px;
}
-->
</style>
<cfoutput>
	<form method="post" action="#cgi.script_name#">
		<fieldset>
		<legend>Settings</legend>
		<div>
			<label for="strHeading">Pod Heading:</label>
			<input type="text" id="strHeading" name="strHeading" value="#variables.strHeading#" size="20"/>
			The text heading above the pod
		</div>
		<div>
			<label for="intPopularPostCount">## Posts to show:</label>
			<input type="text" id="intPopularPostCount" name="intPopularPostCount" value="#variables.intPopularPostCount#" size="20"/>
			A positive integer value
		</div>
		</fieldset>
		<div class="actions">
			<input type="submit" class="primaryAction" value="Submit"/>
			<input type="hidden" value="event" name="action" />
			<input type="hidden" value="#variables.configEvent#" name="event" />
			<input type="hidden" value="true" name="apply" />
			<input type="hidden" value="#variables.name#" name="selected" />
		</div>
	</form>
</cfoutput>