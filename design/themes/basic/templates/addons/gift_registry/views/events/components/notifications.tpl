<div class="events-notifications" id="content_notifications">
<p class="events-help"><i class="icon-help-circle"></i>{__("text_notification_to_inviteees")}</p>
{include file="common/subheader.tpl" title=__("events_list")}
<form action="{""|fn_url}" method="post" name="event_notifications_form" >
<input type="hidden" name="event_id" value="{$event_id}" />
{if $access_key}
<input type="hidden" name="access_key" value="{$access_key}" />
{/if}
<table class="table table-width">
    <thead>
        <tr>
            <th style="width: 1%">
            <input type="checkbox" name="check_all" value="Y" title="{__("check_uncheck_all")}" class="checkbox cm-check-items" /></th>
            <th>{__("name")}</th>
            <th>{__("email")}</th>
        </tr>
    </thead>
{foreach from=$event_data.subscribers item=s}
<tr {cycle values=",class=\"table-row\""}>
    <td class="center">
        <input type="checkbox" name="event_recipients[]" value="{$s.email}" class="checkbox cm-item" /></td>
    <td class="nowrap">{$s.name}</td>
    <td class="nowrap"><a href="mailto:{$s.email|escape:url}">{$s.email}</a></td>
</tr>
{foreachelse}
<tr>
    <td colspan="3"><p class="no-items">{__("no_invitees_found")}</p></td>
</tr>
{/foreach}
</table>
{if $event_data.subscribers}
    <div class="buttons-container">
        {include file="buttons/button.tpl" but_text=__("send_notification") but_name="dispatch[events.send_notifications]" but_meta="cm-process-items"}
    </div>
{/if}
</form>
</div>