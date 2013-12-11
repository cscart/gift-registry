{** block-description:events **}

{if $today_events}
<div><strong>{__("today_events")}</strong>:</div>
<ul class="bullets-list">
{foreach from=$today_events item=event}
    <li><a href="{"events.view?event_id=`$event.event_id`"|fn_url}">{$event.title}</a></li>
{/foreach}
</ul>

{if $additional_link}
<div class="right"><a href="{"events.search?today_events=Y"|fn_url}">{__("more_w_ellipsis")}</a></div>
{/if}
<div class="delim"></div>
{/if}
<ul class="bullets-list">
    <li><a href="{"events.search"|fn_url}">{__("search")}</a></li>
    <li><a href="{"events.add"|fn_url}">{__("add_new")}</a></li>
    <li><a href="{"events.access_key"|fn_url}">{__("private_events")}</a></li>
</ul>