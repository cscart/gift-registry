{capture name="mainbox"}
    <form action="{""|fn_url}" method="post" name="delete_events_form">

        {include file="common/pagination.tpl" save_current_url=true}
        {if $events}
        <table class="table table-middle">
            <thead>
            <tr>
                <th width="1%" class="center">
                    {include file="common/check_items.tpl"}</th>
                <th width="50%">{__("title")}</th>
                <th width="15%">{__("start_date")}</th>
                <th width="15%">{__("end_date")}</th>
                <th width="10%">{__("status")}</th>
                <th width="10%">{__("type")}</th>
                <th>&nbsp;</th>
            </tr>
            </thead>
            <tbody>

            {foreach from=$events item=event}
                <tr>
                    <td width="1%" class="center">
                        <input type="checkbox" name="event_ids[]" value="{$event.event_id}" class="checkbox cm-item"/>
                    </td>
                    <td><a href="{"events.update?event_id=`$event.event_id`"|fn_url}">{$event.title}</a></td>
                    <td>{$event.start_date|date_format:$settings.Appearance.date_format}</td>
                    <td>{$event.end_date|date_format:$settings.Appearance.date_format}</td>
                    <td>{if $event.status == "A"}{__("awaiting")}{elseif $event.status == "P"}{__("in_progress")}{else}{__("finished")}{/if}</td>
                    <td>{if $event.type == "P"}{__("public")}{elseif $event.type == "U"}{__("private")}{else}{__("disabled")}{/if}</td>
                    <td class="nowrap">
                        <div class="hidden-tools">
                            {capture name="tools_list"}
                                <li>{btn type="list" class="cm-confirm" text=__("delete") href="events.delete?event_id=`$event.event_id`"}</li>
                                <li>{btn type="list" text=__("edit") href="events.update?event_id=`$event.event_id`"}</li>
                            {/capture}
                            {dropdown content=$smarty.capture.tools_list}
                        </div>
                    </td>
                </tr>
            {/foreach}
            </tbody>
        </table>
        {else}
            <p class="no-items">{__("no_data")}</p>
        {/if}

        {include file="common/pagination.tpl"}


        {capture name="buttons"}
            {capture name="tools_list"}
                {if $events}
                    <li>{btn type="delete_selected" dispatch="dispatch[events.m_delete]" form="delete_events_form"}</li>
                {/if}
            {/capture}
            {dropdown content=$smarty.capture.tools_list}
        {/capture}


        {capture name="sidebar"}
            {include file="addons/gift_registry/views/events/components/custom_event_fields_link.tpl"}
            {include file="common/saved_search.tpl" dispatch="events.manage" view_type="events"}
            {include file="addons/gift_registry/views/events/components/events_search_form.tpl"}
        {/capture}

        {capture name="adv_buttons"}
            {include file="common/tools.tpl" tool_href="events.add" prefix="top" icon="true" hide_tools="true" title=__("add_event") icon="icon-plus"}
        {/capture}
    </form>
{/capture}
{include file="common/mainbox.tpl" title=__("events") content=$smarty.capture.mainbox buttons=$smarty.capture.buttons sidebar=$smarty.capture.sidebar adv_buttons=$smarty.capture.adv_buttons}
