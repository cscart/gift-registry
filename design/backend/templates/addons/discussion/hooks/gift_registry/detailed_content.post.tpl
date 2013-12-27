{if $runtime.company_id && "ULTIMATE"|fn_allowed_for || "MULTIVENDOR"|fn_allowed_for}
<div class="control-group">
    <label for="discussion_type" class="control-label">{__("discussion_title_giftreg")}:</label>
    <div class="controls">
    	{assign var="discussion" value=$event_data.event_id|fn_get_discussion:"G"}
    	<select name="event_data[discussion_type]" id="discussion_type">
    	    <option {if $discussion.type == "C"}selected="selected"{/if} value="C">{__("enabled")}</option>
    	    <option {if $discussion.type == "D" || !$discussion}selected="selected"{/if} value="D">{__("disabled")}</option>
    	</select>
    </div>
</div>
{/if}