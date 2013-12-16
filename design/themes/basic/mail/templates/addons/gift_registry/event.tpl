{include file="common/letter_header.tpl"}

{__("hello")} {$recipient.name},<br /><br />

{__("text_event_subscriber", ["[owner]" => $event.owner])}<br /><br />
{assign var="recipient_email" value=$recipient.email|escape:url}
{if $access_key}
<a href="{"events.view?access_key=`$access_key`"|fn_url:'C':'http'}">{__("view_event_details")}</a><br />
<a href="{"events.unsubscribe?access_key=`$access_key`&email=`$recipient_email`"|fn_url:'C':'http'}">{__("gift_registry_unsubscribe")}</a><br /><br />
{else}
<a href="{"events.view?event_id=`$event.event_id`"|fn_url:'C':'http'}">{__("view_event_details")}</a><br />
<a href="{"events.unsubscribe?event_id=`$event.event_id`&email=`$recipient_email`"|fn_url:'C':'http'}">{__("gift_registry_unsubscribe")}</a><br /><br />
{/if}
{include file="common/letter_footer.tpl"}