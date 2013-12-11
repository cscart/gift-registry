<div class="events form-wrap">
    <div class="events-actions">
        <ul>
            <li><i class="icon-plus-circle"></i>{include file="buttons/button.tpl" but_text=__("event_add") but_href="events.add" but_role="text" but_meta="add"}</li>
            <li><i class="icon-th-list"></i>{include file="buttons/button.tpl" but_text=__("view_events") but_href="events.search" but_role="text"}</li>
        </ul>
    </div>
<form action="{""|fn_url}" method="get" name="event_access_form">
    <div class="events-private-wrap">
    <h4>{__("enter_private_event")}</h4>
    <div class="form-field-body">
        <div class="control-group">
            <label for="access_key" class="cm-required">{__("access_key")}</label>
            <input class="input-text" type="text" id="access_key" name="access_key" size="40" value="" />
        </div>
        <span>{__("text_enter_access_key")}</span>
    </div>
    <div class="buttons-container">
        {include file="buttons/button.tpl" but_text=__("enter_private_event") but_name="dispatch[events.update]"}
    </div>
    </div>
</form>
{capture name="mainbox_title"}{__("access_key")}{/capture}
</div>