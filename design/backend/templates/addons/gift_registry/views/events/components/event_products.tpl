{script src="js/tygh/exceptions.js"}

<div class="cm-hide-save-button" id="content_products">

<p>{__("text_gr_desired_products")}</p>

{include file="common/subheader.tpl" title=__("defined_desired_products") notes=$smarty.capture.local_notes notes_id="desired_products"}

<div class="clearfix">
    <div class="pull-right">
        {if $event_data.products}
            {btn type="delete_selected" icon="icon-trash" dispatch="dispatch[events.m_delete_products]" form="event_form"}
        {/if}
    </div>
    <div class="pull-right shift-button-left">
        {include file="pickers/products/picker.tpl" display="options_amount" extra_var="events.add_products?event_id=`$event_id`" data_id="events"}
    </div>
</div>

{include file="common/pagination.tpl"}
{if $event_data.products}
<table class="table table-middle ">
<thead>
    <tr>
        <th width="5%" class="center">
            {include file="common/check_items.tpl"}</th>
        <th width="50%">{__("product")}</th>
        <th width="20%">{__("price")}</th>
        <th width="15%" class="center">{__("quantity")}</th>
        <th width="10%">&nbsp;</th>
    </tr>
</thead>
<tbody>
{foreach from=$event_data.products item="cp" key="key"}
<tr>
    <td class="center">
        <input type="checkbox" name="event_product_ids[]" value="{$key}" class="checkbox cm-item" /></td>
    <td>
        <a href="{"products.update?product_id=`$cp.product_id`"|fn_url}">{$cp.product}</a>
        {if $cp.product_options}
            <span class="cm-reload-{$key}" id="event_options_update_{$key}">
                <input type="hidden" name="appearance[events]" value="1">
                <input type="hidden" name="appearance[event_id]" value="{$event_id}">
            <!--event_options_update_{$key}--></span>
        <div>{include file="views/products/components/select_product_options.tpl" product_options=$cp.product_options name="event_products" id=$key product=$cp}</div>
        {/if}
    </td>
    <td>
        {include file="common/price.tpl" value=$cp.price}</td>
    <td class="center">
        <span class="cm-reload-{$key}" id="event_products_update_{$key}">
            <input type="hidden" name="event_products[{$key}][product_id]" value="{$cp.product_id}" />
            <input class="input-micro center input-hidden" type="text" size="3" name="event_products[{$key}][amount]" value="{$cp.amount}" />
        <!--event_products_update_{$key}--></span>
    </td>
    <td class="nowrap">
       <div class="hidden-tools">
            {capture name="tools_list"}
                <li>{btn type="list" text=__("edit") href="products.update?product_id=`$cp.product_id`"}</li>
                <li>{btn type="delete" href="events.delete_product?product_id=`$key`&event_id=`$event_id`" class="cm-confirm"}</li>
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

</div>