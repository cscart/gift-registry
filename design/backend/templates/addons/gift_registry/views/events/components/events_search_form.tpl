<div class="sidebar-row">
<h6>{__("search")}</h6>
<form action="{""|fn_url}" method="get" name="events_search">

{capture name="simple_search"}
        <div class="sidebar-field">
            <label for="title">{__("title")}:</label>
            <input name="title" id="title" size="25" type="text" value="{$search.title}">
        </div>

        <div class="sidebar-field">
            <label for="owner">{__("owner")}:</label>
            <input name="owner" id="owner" size="25" type="text" value="{$search.owner}">
        </div>

        <div class="sidebar-field">
            <label for="subscriber">{__("subscriber")}:</label>
            <input name="subscriber" id="subscriber" size="25" type="text" value="{$search.subscriber}">
        </div>
{/capture}

{capture name="advanced_search"}

<div class="group form-horizontal">
    <div class="control-group">
        <label class="control-label">{__("period")}:</label>
        <div class="controls">
            {include file="common/period_selector.tpl" period=$search.period form_name="events_search"}
        </div>
    </div>
</div>

<div class="group form-horizontal">
    <div class="control-group">
        <label for="status" class="control-label">{__("status")}:</label>
        <div class="controls">
            <select name="status" id="status">
                <option value="">--</option>
                <option {if $search.status == "A"}selected="selected"{/if} value="A">{__("awaiting")}</option>
                <option {if $search.status == "P"}selected="selected"{/if} value="P">{__("in_progress")}</option>
                <option {if $search.status == "F"}selected="selected"{/if} value="F">{__("finished")}</option>
            </select>
        </div>
    </div>
    <div class="control-group">
        <label for="type" class="control-label">{__("type")}:</label>
        <div class="controls">
           <select name="type" id="type">
                <option value="">--</option>
                <option {if $search.type == "P"}selected="selected"{/if} value="P">{__("public")}</option>
                <option {if $search.type == "U"}selected="selected"{/if} value="U">{__("private")}</option>
                <option {if $search.type == "D"}selected="selected"{/if} value="D">{__("disabled")}</option>
            </select>
        </div>
    </div>
</div>

{foreach from=$event_fields item=field}
{assign var="f_id" value=$field.field_id}
<div class="control-group">
    <label for="search_fields_{$field.field_id}" class="control-label">{$field.description}:&nbsp;</label>
    <div class="controls">
    {if $field.field_type == "S" || $field.field_type == "R"}
        <select name="search_fields[{$field.field_id}]" id="search_fields_{$field.field_id}">
            <option value=""> -- </option>
            {foreach from=$field.variants item=var}
                <option value="{$var.variant_id}" {if $search.search_fields.$f_id == $var.variant_id}selected="selected"{/if}>{$var.description}</option>
            {/foreach}
        </select>
    {elseif $field.field_type == "C"}
        <select name="search_fields[{$field.field_id}]" id="search_fields_{$field.field_id}">
            <option value=""> -- </option>
            <option value="Y" {if $search.search_fields.$f_id == "Y"}selected="selected"{/if}>{__("yes")}</option>
            <option value="N" {if $search.search_fields.$f_id == "N"}selected="selected"{/if}>{__("no")}</option>
        </select>
    {elseif $field.field_type == "I" || $field.field_type == "T"}
        <input class="input-text" size="50" type="text" name="search_fields[{$field.field_id}]" value="{$search.search_fields.$f_id}" id="search_fields_{$field.field_id}" />
    {elseif $field.field_type == "V"}
        {include file="common/calendar.tpl" date_id="search_date_`$field.field_id`" date_name="search_fields[`$field.field_id`]" date_val=$search.search_fields.$f_id start_year="1970" end_year="5"}
    {/if}
    </div>
</div>
{/foreach}

{/capture}

{include file="common/advanced_search.tpl" advanced_search=$smarty.capture.advanced_search simple_search=$smarty.capture.simple_search dispatch="events.manage" view_type="events"}

</form>
</div>
{include file="common/section.tpl" section_content=$smarty.capture.section}