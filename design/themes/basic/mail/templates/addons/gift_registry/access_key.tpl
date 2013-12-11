{include file="common/letter_header.tpl"}

{__("hello")},<br /><br />

<table border="0" cellspacing="1" cellpadding="2">
<tr>
    <td class="table-head">{__("event")}</td>
    <td class="table-head">{__("owner")}</td>
    <td class="table-head">{__("access_key")}</td>
    <td class="table-head">{__("link")}</td>
</tr>
{if $owner_events}
<tr>
    <td colspan="4">
        <b>{__("text_your_events")}:</b></td>
</tr>
{foreach from=$owner_events item=e}
<tr {cycle values='class="table-row", '}>
    <td>{$e.title}</td>
    <td>{$e.owner}</td>
    <td>{$e.ekey}</td>
    <td><a href="{"events.update?access_key=`$e.ekey`"|fn_url:'C':'http'}">{__("open_action")}</a></td>
</tr>
{/foreach}
{/if}
{if $subscriber_events}
<tr>
    <td colspan="4">
        <b>{__("text_events_you_subscribed")}:</b></td>
</tr>
{foreach from=$subscriber_events item=e}
<tr {cycle values='class="table-row", '}>
    <td>{$e.title}</td>
    <td>{$e.owner}</td>
    <td>{$e.ekey}</td>
    <td><a href="{"events.view?access_key=`$e.ekey`"|fn_url:'C':'http'}">{__("open_action")}</a></td>
</tr>
{/foreach}
{/if}
</table>

{include file="common/letter_footer.tpl"}