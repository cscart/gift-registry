{if $event_data.event_id}
    {assign var="id" value=$event_data.event_id}
{else}
    {assign var="id" value=0}
{/if}

{capture name="mainbox"}

{capture name="sidebar"}
    {include file="addons/gift_registry/views/events/components/custom_event_fields_link.tpl"}
{/capture}

{capture name="tabsbox"}

<form action="{""|fn_url}" method="post" class=" form-horizontal form-edit" name="event_form">
<input type="hidden" name="event_id" value="{$id}" />
<input type="hidden" name="selected_section" id="selected_section" value="{$smarty.request.selected_section}" />
{if $access_key}
<input type="hidden" name="access_key" value="{$access_key}" />
{/if}

<div id="content_general">
<fieldset>

    <div class="control-group">
        <label for="elm_event_title" class="control-label cm-required">{__("title")}:</label>
        <div class="controls">
            <input type="text" id="elm_event_title" size="70" name="event_data[title]" value="{$event_data.title}" />
        </div>
    </div>
    
    <div class="control-group">
        <label for="elm_event_owner" class="control-label cm-required">{__("your_name")}:</label>
        <div class="controls">
            <input type="text" id="elm_event_owner" size="70" name="event_data[owner]" value="{$event_data.owner|default:"`$user_info.firstname` `$user_info.lastname`"}" />
        </div>
    </div>
    
    <div class="control-group">
        <label for="elm_event_email" class="control-label cm-required cm-email">{__("email")}:</label>
        <div class="controls">
            <input type="text" id="elm_event_email" size="70" name="event_data[email]" value="{$event_data.email|default:$user_info.email}" />
        </div>
    </div>
    
    <div class="control-group">
        <label class="control-label cm-required" for="from_event_date">{__("start_date")}:</label>
        <div class="controls">
            {include file="common/calendar.tpl" date_id="from_event_date" date_name="event_data[start_date]" date_val=$event_data.start_date|default:$smarty.const.TIME start_year=$settings.Company.company_start_year}
        </div>
    </div>
    
    <div class="control-group">
        <label class="control-label cm-required" for="to_event_date">{__("end_date")}:</label>
        <div class="controls">
            {include file="common/calendar.tpl" date_id="to_event_date" date_name="event_data[end_date]" date_val=$event_data.end_date|default:$smarty.const.TIME start_year=$settings.Company.company_start_year}
        </div>
    </div>
    
    <div class="control-group">
        <label for="elm_event_type" class="control-label cm-required">{__("type")}:</label>
        <div class="controls">
            <select id="elm_event_type" class="input-text" name="event_data[type]">
                <option value="P" {if $event_data.type == "P"}selected="selected"{/if}>{__("public")}</option>
                <option value="U" {if $event_data.type == "U"}selected="selected"{/if}>{__("private")}</option>
                <option value="D" {if $event_data.type == "D"}selected="selected"{/if}>{__("disabled")}</option>
            </select>
        </div>
    </div>
    
    {foreach from=$event_fields item=field}
    {assign var="f_id" value=$field.field_id}
    <div class="control-group">
        <label for="elm_event_fields_{$field.field_id}" class="control-label{if $field.required == "Y"} cm-required{/if}">{$field.description}:</label>
        <div class="controls">
            {if $field.field_type == "S"}
                <select id="elm_event_fields_{$field.field_id}" class="input-text" name="event_data[fields][{$field.field_id}]">
                    {if $field.required != "Y"}
                        <option value="">--</option>
                    {/if}
                    {foreach from=$field.variants item=var name="vars"}
                        <option value="{$var.variant_id}" {if $var.variant_id == $event_data.fields.$f_id}selected="selected"{/if}>{$var.description}</option>
                    {/foreach}
                </select>
            {elseif $field.field_type == "R"}
                {foreach from=$field.variants item=var name="vars"}
                    <label class="radio">
                        <input {if $var.variant_id == $event_data.fields.$f_id || (!$id && $smarty.foreach.vars.first)}checked="checked"{/if} type="radio" name="event_data[fields][{$field.field_id}]" value="{$var.variant_id}">
                        {$var.description}
                    </label>
                {/foreach}
            {elseif $field.field_type == "C"}
                <input type="hidden" name="event_data[fields][{$field.field_id}]" value="N" />
                <input id="elm_event_fields_{$field.field_id}" type="checkbox" name="event_data[fields][{$field.field_id}]" value="Y" {if $event_data.fields.$f_id == "Y"}checked="checked"{/if} />
            {elseif $field.field_type == "I"}
                <input id="elm_event_fields_{$field.field_id}" class="input-text" size="50" type="text" name="event_data[fields][{$field.field_id}]" value="{$event_data.fields.$f_id}" />
            {elseif $field.field_type == "T"}
                <textarea id="elm_event_fields_{$field.field_id}"  class="input-text" cols="70" rows="10" name="event_data[fields][{$field.field_id}]">{$event_data.fields.$f_id}</textarea>
            {elseif $field.field_type == "V"}
                {include file="common/calendar.tpl" date_id="elm_event_fields_`$field.field_id`" date_name="event_data[fields][`$field.field_id`]" date_val=$event_data.fields.$f_id start_year="1970" end_year="5"}
            {/if}
        </div>
    </div>
    {/foreach}
    
    <div class="control-group">
        <label class="control-label">{__("invitees")}:</label>
        <div class="controls">
            <table class="table">
            <thead>
                <tr class="cm-first-sibling">
                    <th>{__("name")}</th>
                    <th>{__("email")}</th>
                    <th>&nbsp;</th>
                </tr>
            </thead>
            {if $event_data.subscribers}
            <tbody class="cm-first-sibling">
            {strip}
            {foreach from=$event_data.subscribers item=s name="s_fe"}
            <tr id="box_subscriber_{$smarty.foreach.s_fe.iteration}" class="cm-row-item">
                <td><input class="input-text" type="text" name="event_data[subscribers][{$smarty.foreach.s_fe.iteration}][name]" value="{$s.name}" /></td>
                <td><input class="input-text" type="text" name="event_data[subscribers][{$smarty.foreach.s_fe.iteration}][email]" value="{$s.email}" /></td>
                <td>
                    <a class="cm-delete-row cm-tooltip fake-remove-item" title="{__("remove")}"><i class="icon-remove"></i></a>
                </td>
            </tr>
            {assign var="iteration" value=$smarty.foreach.s_fe.iteration}
            {/foreach}
            </tbody>
            {/strip}
            {/if}
            <tr id="box_new_subscriber" class="cm-row-item">
                <td><input class="input-text" type="text" name="event_data[add_subscribers][0][name]" value="" /></td>
                <td><input class="input-text" type="text" name="event_data[add_subscribers][0][email]" value="" /></td>
                <td>{include file="buttons/multiple_buttons.tpl" item_id="new_subscriber"}</td>
            </tr>
            </table>
            {if $event_data.subscribers}
                <p>{__("text_delete_recipients")}</p>
            {/if}
        </div>
    </div>
    
    {hook name="gift_registry:detailed_content"}
    {/hook}

</fieldset>
<!--content_general--></div>

{hook name="gift_registry:tabs_content"}
{/hook}

{if $id}
    {include file="addons/gift_registry/views/events/components/event_products.tpl"}
{/if}

{capture name="buttons"}
    {include file="buttons/save_cancel.tpl" but_name="dispatch[events.update]" save=$id but_target_form="event_form" but_role="submit-link"}
{/capture}

{capture name="adv_buttons"}
    {if $id}
        {btn type="add" title=__("add_event") href="events.add"}
    {/if}
{/capture}

</form>

{if $id}
    {include file="addons/gift_registry/views/events/components/notifications.tpl"}

    {hook name="gift_registry:tabs_extra"}
    {/hook}
{/if}

{/capture}
{include file="common/tabsbox.tpl" content=$smarty.capture.tabsbox active_tab=$smarty.request.selected_section track=true}

{/capture}
{if !$id}
    {assign var="title" value=__("new_event")}
{else}
    {assign var="title" value="{__("editing_event")}: `$event_data.title`"}
{/if}
{include file="common/mainbox.tpl" title=$title content=$smarty.capture.mainbox adv_buttons=$smarty.capture.adv_buttons buttons=$smarty.capture.buttons sidebar=$smarty.capture.sidebar}