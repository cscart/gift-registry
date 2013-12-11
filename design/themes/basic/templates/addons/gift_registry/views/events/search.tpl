{if $action != "today_events"}

{literal}
<script type="text/javascript">
//<![CDATA[
var fields = new Array('start_date[Date_Month]', 'start_date[Date_Day]' , 'start_date[Date_Year]', 'end_date[Date_Month]', 'end_date[Date_Day]' , 'end_date[Date_Year]');

function fn_disable_select_date(disable)
{
    for (i in fields) {
        document.events_search.elements[fields[i]].disabled = disable;
    }
}
//]]>
</script>
{/literal}
<div class="events-search">
    <div class="events-actions">
        <ul>
            <li><i class="icon-plus-circle"></i>{include file="buttons/button.tpl" but_text=__("event_add") but_href="events.add" but_role="text" but_meta="add"}</li>
            <li><i class="icon-lock"></i>{include file="buttons/button.tpl" but_text=__("private_events") but_href="events.access_key" but_role="text" but_meta="private"}</li>
        </ul>
    </div>
{capture name="section"}
<form action="{""|fn_url}" method="get" name="events_search">
{if $access_key}
<input type="hidden" name="access_key" value="{$access_key}" />
{/if}
{include file="common/period_selector.tpl" period=$smarty.request.period form_name="events_search"}
<div class="control-group">
    <label for="title">{__("title")}:</label>
    <input class="input-text" name="title" id="title" size="50" type="text" value="{$smarty.request.title}" />
</div>
<div class="control-group">
    <label for="owner">{__("owner")}:</label>
    <input class="input-text" name="owner" id="owner" size="25" type="text" value="{$smarty.request.owner}" />
</div>
<div class="control-group">
    <label for="subscriber">{__("subscriber")}:</label>
    <input class="input-text" name="subscriber" id="subscriber" size="25" type="text" value="{$smarty.request.subscriber}" />
</div>
<div class="control-group">
    <label for="status">{__("status")}:</label>
    <select name="status" id="status">
            <option value="">--</option>
            <option {if $smarty.request.status == "A"}selected="selected"{/if} value="A">{__("awaiting")}</option>
            <option {if $smarty.request.status == "P"}selected="selected"{/if} value="P">{__("in_progress")}</option>
            <option {if $smarty.request.status == "F"}selected="selected"{/if} value="F">{__("finished")}</option>
        </select>
</div>
<div class="control-group">
    <label for="type">{__("event_type")}:</label>
    <select name="type" id="type">
            <option value="">--</option>
            <option {if $smarty.request.type == "P"}selected="selected"{/if} value="P">{__("public")}</option>
            <option {if $smarty.request.type == "U"}selected="selected"{/if} value="U">{__("private")}</option>
            <option {if $smarty.request.type == "D"}selected="selected"{/if} value="D">{__("disabled")}</option>
        </select>
</div>
{foreach from=$event_fields item=field}
{assign var="f_id" value=$field.field_id}
<div class="control-group">
    <label {if $field.field_type != "V"}for="search_fields_{$field.field_id}"{/if}>{$field.description}:</label>
    {if $field.field_type == "S" || $field.field_type == "R"}
            <select name="search_fields[{$field.field_id}]" id="search_fields_{$field.field_id}">
            <option value=""> -- </option>
            {foreach from=$field.variants item=var}
            <option value="{$var.variant_id}" {if $smarty.request.search_fields.$f_id == $var.variant_id}selected="selected"{/if}>{$var.description}</option>
            {/foreach}
            </select>
        {elseif $field.field_type == "C"}
            <select name="search_fields[{$field.field_id}]" id="search_fields_{$field.field_id}">
            <option value=""> -- </option>
            <option value="Y" {if $smarty.request.search_fields.$f_id == "Y"}selected="selected"{/if}>{__("yes")}</option>
            <option value="N" {if $smarty.request.search_fields.$f_id == "N"}selected="selected"{/if}>{__("no")}</option>
            </select>
        {elseif $field.field_type == "I" || $field.field_type == "T"}
            <input class="input-text" size="50" type="text" name="search_fields[{$field.field_id}]" value="{$smarty.request.search_fields.$f_id}" id="search_fields_{$field.field_id}" />
        {elseif $field.field_type == "V"}
            {include file="common/calendar.tpl" date_id="search_date_`$field.field_id`" date_name="search_fields[`$field.field_id`]" date_val=$smarty.request.search_fields.$f_id start_year="1970" end_year="5"}
        {/if}
</div>
{/foreach}
<div class="buttons-container">
{include file="buttons/search.tpl" but_name="dispatch[events.search]"}
</div>
</form>
{/capture}
{include file="common/section.tpl" section_title=__("search") section_content=$smarty.capture.section}
{/if}
<form action="{""|fn_url}" method="post" name="delete_events_form">
{if $access_key}
<input type="hidden" name="access_key" value="{$access_key}" />
{/if}
{include file="common/pagination.tpl" save_current_url=true}
{foreach from=$events item=event}
    {if $auth.user_id && $auth.user_id == $event.user_id}{assign var="can_delete" value="Y"}{/if}
{/foreach}
<table class="table table-width">
<tr>
    {if $can_delete == "Y"}
    <th style="width: 1%">&nbsp;</th>
    {/if}
    <th>{__("title")}</th>
    <th>{__("start_date")}</th>
    <th>{__("end_date")}</th>
    <th>{__("status")}</th>
    <th>{__("event_type")}</th>
    <th>{__("action")}</th>
</tr>
{foreach from=$events item=event}
<tr {cycle values=",class=\"table-row\""}>
    {if $can_delete == "Y"}
    <td class="center">{if $auth.user_id && $auth.user_id == $event.user_id}<input class="checkbox" type="checkbox" name="event_ids[]" value="{$event.event_id}" />{else}&nbsp;{/if}</td>
    {/if}
    <td>
        {if $auth.user_id && $auth.user_id == $event.user_id}
            {assign var=event_mode value="update"}
        {else}
            {assign var=event_mode value="view"}
        {/if}
        <a href="{"events.`$event_mode`?event_id=`$event.event_id`"|fn_url}">{$event.title}</a>
    </td>
    <td>{$event.start_date|date_format:$settings.Appearance.date_format}</td>
    <td>{$event.end_date|date_format:$settings.Appearance.date_format}</td>
    <td>{if $event.status == "A"}{__("awaiting")}{elseif $event.status == "P"}{__("in_progress")}{else}{__("finished")}{/if}</td>
    <td>{if $event.type == "P"}{__("public")}{elseif $event.type == "U"}{__("private")}{else}{__("disabled")}{/if}</td>
    <td><a href="{"events.`$event_mode`?event_id=`$event.event_id`"|fn_url}">{if $event_mode == "view"}{__("view")}{else}{__("edit")}{/if}</a></td>
</tr>
{foreachelse}
<tr>
    <td colspan="6"><p class="no-items">{__("no_items_found")}</p></td>
</tr>
{/foreach}
</table>
{include file="common/pagination.tpl"}
{if $can_delete == "Y"}
<div class="events-search-action buttons-container">
{include file="buttons/button.tpl" but_text=__("delete_selected") but_name="dispatch[events.m_delete]" }
</div>
{/if}
</form>
{capture name="mainbox_title"}{__("search")}{/capture}
</div>