{if $event_data.event_id}
    {assign var="id" value=$event_data.event_id}
{else}
    {assign var="id" value=0}
{/if}

<div class="events">
    <div class="events-actions">
        <ul>
            <li><i class="icon-th-list"></i>{include file="buttons/button.tpl" but_text=__("view_events") but_href="events.search" but_role="text"}</li>
            <li><i class="icon-lock"></i>{include file="buttons/button.tpl" but_text=__("private_events") but_href="events.access_key" but_role="text" but_meta="private"}</li>
        </ul>
    </div>
    {capture name="tabsbox"}
        <div class="events-general" id="content_general">
            <form action="{""|fn_url}" method="post" name="event_form">
                <input type="hidden" name="selected_section" value="" />
                <input type="hidden" name="event_id" value="{$id}" />

                {if $access_key}
                    <div class="events-key">
                        <input type="hidden" name="access_key" value="{$access_key}" />
                        <strong>{__("text_remember_access_key")}:</strong>
                        <p>{$access_key}</p>
                    </div>
                {/if}
                {if $auth.user_id}
                    {assign var="default_name" value="`$user_info.firstname` `$user_info.lastname`"}
                    {assign var="default_email" value=$user_info.email}
                {/if}
                <div class="control-group">
                    <label for="elm_title" class="cm-required">{__("title")}</label>
                    <input type="text" id="elm_title" class="input-text" size="70" name="event_data[title]" value="{$event_data.title}" />
                </div>
                <div class="control-group">
                    <label for="elm_owner" class="cm-required">{__("your_name")}</label>
                    <input type="text" id="elm_owner" class="input-text" size="70" name="event_data[owner]" value="{$event_data.owner|default:$default_name}" />
                </div>
                <div class="control-group">
                    <label for="elm_email" class="cm-required">{__("email")}</label>
                    <input type="text" id="elm_email" class="input-text" size="70" name="event_data[email]" value="{$event_data.email|default:$default_email}" />
                </div>
                <div class="control-group">
                    <div class="start-date">
                        <label for="elm_start_date" class="cm-required">{__("start_date")}</label>
                        <div class="cm-field-container">
                            {include file="common/calendar.tpl" date_id="elm_start_date" date_name="event_data[start_date]" date_val=$event_data.start_date  start_year=$settings.Company.company_start_year}
                        </div>
                    </div>
                    <div class="events-dash">–</div>
                    <div class="end-date">
                        <label for="elm_end_date" class="cm-required">{__("end_date")}</label>
                        <div class="cm-field-container">
                            {include file="common/calendar.tpl" date_id="elm_end_date" date_name="event_data[end_date]" date_val=$event_data.end_date   start_year=$settings.Company.company_start_year}
                        </div>
                    </div>
                </div>
                <div class="control-group">
                    <label for="elm_type" class="cm-required">{__("event_type")}</label>
                    <select id="elm_type" name="event_data[type]">
                        <option value="P" {if $event_data.type == "P"}selected="selected"{/if}>{__("public")}</option>
                        <option value="U" {if $event_data.type == "U"}selected="selected"{/if}>{__("private")}</option>
                    </select>
                </div>
                {hook name="events:fields"}
                    {foreach from=$event_fields item=field}
                        {assign var="f_id" value=$field.field_id}
                        <div class="control-group">
                            <label for="elm_{$field.field_id}" {if $field.required == "Y"}class="cm-required"{/if}>{$field.description}</label>
                            {if $field.field_type == "S"}
                                    <select id="elm_{$field.field_id}" name="event_data[fields][{$field.field_id}]">
                                    {if $field.required != "Y"}
                                    <option value="">--</option>
                                    {/if}
                                    {foreach from=$field.variants item=var name="vars"}
                                    <option value="{$var.variant_id}" {if $var.variant_id == $event_data.fields.$f_id}selected="selected"{/if}>{$var.description}</option>
                                    {/foreach}
                                    </select>
                                {elseif $field.field_type == "R"}
                                    {foreach from=$field.variants item=var name="vars"}
                                    <input {if $var.variant_id == $event_data.fields.$f_id || (!$id && $smarty.foreach.vars.first)}checked="checked"{/if} type="radio" name="event_data[fields][{$field.field_id}]" value="{$var.variant_id}" class="radio" />{$var.description}&nbsp;&nbsp;
                                    {/foreach}
                                {elseif $field.field_type == "C"}
                                    <input type="hidden" name="event_data[fields][{$field.field_id}]" value="N" />
                                    <input id="elm_{$field.field_id}" type="checkbox" name="event_data[fields][{$field.field_id}]" value="Y" {if $event_data.fields.$f_id == "Y"}checked="checked"{/if} class="checkbox" />
                                {elseif $field.field_type == "I"}
                                    <input id="elm_{$field.field_id}" class="input-text" size="50" type="text" name="event_data[fields][{$field.field_id}]" value="{$event_data.fields.$f_id}" />
                                {elseif $field.field_type == "T"}
                                    <textarea id="elm_{$field.field_id}"  class="input-textarea" cols="72" rows="10" name="event_data[fields][{$field.field_id}]">{$event_data.fields.$f_id}</textarea>
                                {elseif $field.field_type == "V"}
                                    {include file="common/calendar.tpl" date_id="elm_`$field.field_id`" date_name="event_data[fields][`$field.field_id`]" date_val=$event_data.fields.$f_id start_year="1970"}
                            {/if}
                    </div>
                    {/foreach}
                {/hook}
                <div class="event-envitees">
                    <label for="elm_invitees">{__("invitees")}</label>
                    <div id="elm_invitees">
                        <table class="table">
                            <thead>
                            <tr class="cm-first-sibling">
                                <th>{__("name")}</th>
                                <th>{__("email")}</th>
                                <th>&nbsp;</th>
                            </tr>
                            </thead>
                        {if $event_data.subscribers}
                        {strip}
                        {foreach from=$event_data.subscribers item=s name="s_fe"}
                        <tr id="box_subscriber_{$smarty.foreach.s_fe.iteration}">
                            <td><input class="input-text-auto" type="text" name="event_data[subscribers][{$smarty.foreach.s_fe.iteration}][name]" value="{$s.name}" size="18" /></td>
                            <td><input class="input-text-auto" type="text" name="event_data[subscribers][{$smarty.foreach.s_fe.iteration}][email]" value="{$s.email}" size="18" /></td>
                            <td><div class="event-invitees-actions">{include file="buttons/multiple_buttons.tpl" item_id="subscriber_`$smarty.foreach.s_fe.iteration`" only_delete="Y"}</div></td>
                        </tr>
                        {/foreach}
                        {/strip}
                        {/if}
                        <tr id="box_new_subscriber" class="cm-row-item">
                            <td><input class="input-text-auto" type="text" name="event_data[add_subscribers][0][name]" value="" size="18" /></td>
                            <td><input class="input-text-auto" type="text" name="event_data[add_subscribers][0][email]" value="" size="18" /></td>
                            <td><div class="event-invitees-actions">{include file="buttons/multiple_buttons.tpl" item_id="new_subscriber"}</div></td>
                        </tr>
                        </table>
                        {if $event_data.subscribers}
                            <span class="event-envitees-desc">{__("text_delete_recipients")}</span>
                        {/if}
                    </div>
                </div>
                <div class="buttons-container {if $id}events-update{/if}">
                    {if $id}
                        {include file="buttons/save.tpl" but_name="dispatch[events.update]"}
                        {include file="buttons/button.tpl" but_text=__("delete_this_event") but_href="events.delete?event_id=$id&access_key=$access_key" but_role="text"}
                    {else}
                        {include file="buttons/button.tpl" but_text=__("event_add") but_name="dispatch[events.update]"}
                    {/if}
                </div>
            </form>
        </div>
        {if $id}
            {hook name="events:update"}
                {include file="addons/gift_registry/views/events/components/event_products.tpl"}
                {include file="addons/gift_registry/views/events/components/notifications.tpl"}
            {/hook}
        {/if}

    {/capture}
    {include file="common/tabsbox.tpl" content=$smarty.capture.tabsbox active_tab=$smarty.request.selected_section track=true}
    {capture name="mainbox_title"}
        {if !$id}
            {__("add_event")}
        {else}
            {__("editing_event")}: {$event_data.title}
        {/if}
    {/capture}
</div>