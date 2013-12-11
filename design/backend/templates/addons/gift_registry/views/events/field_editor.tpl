{script src="js/tygh/tabs.js"}

<script type="text/javascript">
    //<![CDATA[
    {literal}
    function fn_check_field_type(select, id, tab_id)
    {
        var suffix = select.id.str_replace(id, '');
        var value = Tygh.$(select).val();
    
        Tygh.$('#' + tab_id + suffix).toggleBy(!(value == 'R' || value == 'S'));
    }
    {/literal}
    //]]>
</script>

{capture name="mainbox"}

{capture name="sidebar"}
    {include file="addons/gift_registry/views/events/components/custom_event_fields_link.tpl"}
{/capture}

<form action="{""|fn_url}" method="POST" name="event_fields_form">

{if $event_fields}
<table class="table table-middle">
<thead>
    <tr>
        <th class="center" width="5%">
            {include file="common/check_items.tpl"}</th>
        <th width="10%">{__("position_short")}</th>
        <th width="30%">{__("description")}</th>
        <th width="30%">{__("type")}</th>
        <th width="10%" class="center">{__("required")}</th>
        <th width="5%">&nbsp;</th>
        <th width="10%" class="right">{__("status")}</th>
    </tr>
</thead>
<tbody>
{foreach from=$event_fields item=field}
<tr class="cm-row-status-{$field.status|lower}">
    <td class="center">
        <input type="checkbox" name="field_ids[]" value="{$field.field_id}" class="cm-item"></td>
    <td><input class="input-micro" type="text" size="3" name="fields_data[{$field.field_id}][position]" value="{$field.position}" /></td>
    <td>
        <input id="descr_elm_{$field.field_id}" class="{if $field.field_type == "D"}hidden{/if}" type="text" name="fields_data[{$field.field_id}][description]" value="{$field.description}">
    <td>
        <select id="elm_{$field.field_id}" name="fields_data[{$field.field_id}][field_type]" onchange="fn_check_field_type(this, 'elm_{$field.field_id}', 'box_field_variants_{$field.field_id}');">
            <option value="C" {if $field.field_type == "C"}selected="selected"{/if}>{__("checkbox")}</option>
            <option value="V" {if $field.field_type == "V"}selected="selected"{/if}>{__("date")}</option>
            <option value="I" {if $field.field_type == "I"}selected="selected"{/if}>{__("input_field")}</option>
            <option value="R" {if $field.field_type == "R"}selected="selected"{/if}>{__("radiogroup")}</option>
            <option value="S" {if $field.field_type == "S"}selected="selected"{/if}>{__("selectbox")}</option>
            <option value="T" {if $field.field_type == "T"}selected="selected"{/if}>{__("textarea")}</option>
        </select></td>
    <td class="center">
        <input type="hidden" name="fields_data[{$field.field_id}][required]" value="N">
        <input type="checkbox" name="fields_data[{$field.field_id}][required]" value="Y"  {if $field.required == "Y"}checked="checked"{/if}></td>
     <td class="nowrap center">
        <div class="hidden-tools center">
            {capture name="tools_list"}
                <li>{btn type="delete" href="events.delete_field?field_id=`$field.field_id`"}</li>
            {/capture}
            {dropdown content=$smarty.capture.tools_list}
        </div>
    </td>
    <td class="right">
        {include file="common/select_popup.tpl" id=$field.field_id status=$field.status hidden="" object_id_name="field_id" table="giftreg_fields"}
    </td>
</tr>
<tr id="box_field_variants_{$field.field_id}" {if "ITCV"|substr_count:$field.field_type}class="hidden"{/if}>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="5">
        <table class="table table-middle">
        <tr class="cm-first-sibling cm-row-status-{$field.status|lower}">
            <th class="center">{include file="common/check_items.tpl" check_target=$field.field_id}</th>
            <th>{__("position_short")}</th>
            <th>{__("description")}</th>
            <th>&nbsp;</th>
        </tr>
        {foreach from=$field.variants item=var}
        <tr class="cm-first-sibling cm-row-status-{$field.status|lower}">
            <td class="center">
                <input type="checkbox" name="var_ids[]" value="{$var.variant_id}" class="cm-item-{$field.field_id} cm-item"></td>
            <td><input class="input-micro" size="3" type="text" name="fields_data[{$field.field_id}][variants][{$var.variant_id}][position]" value="{$var.position}"></td>
            <td><input type="text" class="input-xxlarge" name="fields_data[{$field.field_id}][variants][{$var.variant_id}][description]" value="{$var.description}"></td>
            <td><a class="cm-confirm icon-remove cm-tooltip" title="{__("remove")}" href="{"events.delete_variant?var_id=`$var.variant_id`"|fn_url}"></a></td>
        </tr>
        {/foreach}
        <tr id="box_elm_variants_{$field.field_id}" class="cm-row-status-{$field.status|lower}">
            <td>&nbsp;</td>
            <td><input class="input-micro" size="3" type="text" name="fields_data[{$field.field_id}][add_variants][0][position]"></td>
            <td><input type="text" class="input-xxlarge" name="fields_data[{$field.field_id}][add_variants][0][description]"></td>
            <td>{include file="buttons/multiple_buttons.tpl" item_id="elm_variants_`$field.field_id`" tag_level="3"}</td>
        </tr>
        </table>
    </td>      
</tr>
{/foreach}
</tbody>
</table>
{else}
    <p class="no-items">{__("no_data")}</p>
{/if}

{capture name="add_new_picker"}
    <form action="{""|fn_url}" method="post" name="add_event_fields_form" class=" form-horizontal">

    <div class="tabs cm-j-tabs">
        <ul class="nav nav-tabs">
            <li id="tab_general" class="cm-js active"><a>{__("general")}</a></li>
            <li id="tab_variants" class="cm-js hidden"><a>{__("variants")}</a></li>
        </ul>
    </div>
    
    <div class="cm-tabs-content">
        <div id="content_tab_general">
            <div class="control-group">
                <label for="descr_add_field_variants" class="control-label cm-required">{__("description")}</label>
                <div class="controls">
                    <input id="descr_add_field_variants" type="text" name="add_fields_data[0][description]" value="">
                </div>
            </div>
            
            <div class="control-group">
                <label for="position" class="control-label">{__("position_short")}</label>
                <div class="controls">
                    <input id="position" size="3" type="text" name="add_fields_data[0][position]" value="">
                </div>
            </div>
            
            <div class="control-group">
                <label for="cm-required" class="control-label">{__("required")}</label>
                <div class="controls">
                    <input type="hidden" name="add_fields_data[0][required]" value="N">
                    <input id="cm-required" type="checkbox" name="add_fields_data[0][required]" value="Y" checked="checked">
                </div>
            </div>

            {include file="common/select_status.tpl" input_name="add_fields_data[0][status]" id="event_status" obj=$field hidden=false}
            
            <div class="control-group">
                <label for="add_field_variants" class="control-label">{__("type")}</label>
                <div class="controls">
                    <select id="add_field_variants" name="add_fields_data[0][field_type]" onchange="fn_check_field_type(this, 'add_field_variants', 'tab_variants');">
                        <option value="C">{__("checkbox")}</option>
                        <option value="V">{__("date")}</option>
                        <option value="I">{__("input_field")}</option>
                        <option value="R">{__("radiogroup")}</option>
                        <option value="S">{__("selectbox")}</option>
                        <option value="T">{__("textarea")}</option>
                    </select>
                </div>
            </div>
        </div>
        
        <div id="content_tab_variants" class="hidden">
            <table class="table">
            <tbody>
            <tr class="cm-first-sibling">
                <th>{__("position_short")}</th>
                <th>{__("description")}</th>
                <th>&nbsp;</th>
            </tr>
            </tbody>
            <tbody class="hover" id="box_add_elm_variants">
            <tr>
                <td><input type="text" name="add_fields_data[0][variants][0][position]" value="" size="4" class="input-micro"></td>
                <td><input type="text" name="add_fields_data[0][variants][0][description]" value="" class="input-xxlarge"></td>
                <td class="right">{include file="buttons/multiple_buttons.tpl" item_id="add_elm_variants" tag_level=3}</td>
            </tr>
            </tbody>
            </table>
        </div>
    </div>        
    
    <div class="buttons-container">
        {include file="buttons/save_cancel.tpl" but_name="dispatch[events.add_fields]" cancel_action="close"}
    </div>
    
    </form>
{/capture}


{capture name="buttons"}
    {if $event_fields}
        {capture name="tools_list"}
            <li>{btn type="delete_selected" dispatch="dispatch[events.m_delete_fields]" form="event_fields_form"}</li>
        {/capture}
        {dropdown content=$smarty.capture.tools_list}

        {include file="buttons/save.tpl" but_name="dispatch[events.update_fields]" but_role="submit-link" but_target_form="event_fields_form"}   
    {/if}
{/capture}

{capture name="adv_buttons"}
    {include file="common/popupbox.tpl" id="add_new_field" text=__("add_field") title=__("add_field") act="general" icon="icon-plus" content=$smarty.capture.add_new_picker}
{/capture}

</form>

{/capture}
{include file="common/mainbox.tpl" title=__("custom_event_fields") content=$smarty.capture.mainbox tools=$smarty.capture.tools buttons=$smarty.capture.buttons adv_buttons=$smarty.capture.adv_buttons select_languages=true}
