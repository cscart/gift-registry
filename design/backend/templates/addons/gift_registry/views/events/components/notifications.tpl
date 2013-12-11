<div class="cm-hide-save-button" id="content_notifications">

<p>{__("text_notification_to_inviteees")}</p>

{include file="common/subheader.tpl" title=__("list_of_event_invitees") notes=$smarty.capture.local_notes notes_id="event_invitees"}

<form action="{""|fn_url}" method="post" name="event_notifications_form" >
<input type="hidden" name="event_id" value="{$event_id}" />

{if $access_key}
<input type="hidden" name="access_key" value="{$access_key}" />
{/if}

{if $event_data.subscribers}
<table class="table table-middle">
<thead>
    <tr>
        <th width="6%" class="center">
            {include file="common/check_items.tpl"}</th>
        <th width="47%">{__("name")}</th>
        <th width="47%">{__("email")}</th>
    </tr>
</thead>
<tbody>
{foreach from=$event_data.subscribers item=s}
<tr>
    <td class="center">
        <input type="checkbox" name="event_recipients[]" id="notify_checkbox" value="{$s.email}" class="cm-item" /></td>    
    <td class="nowrap">{$s.name}</td>
    <td class="nowrap"><a href="mailto:{$s.email|escape:url}">{$s.email}</a></td>
</tr>
{/foreach}
</tbody>
</table>
{else}
    <p class="no-items">{__("no_data")}</p>
{/if}

{if $event_data.subscribers}
<div class="buttons-container buttons-bg">
    {include file="buttons/button.tpl" but_text=__("send_notification") but_name="dispatch[events.send_notifications]" but_meta="cm-process-items btn-primary" but_role="button_main"}
</div>
{/if}
</form>

</div>