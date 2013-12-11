{if $cart.products.$key.extra.events}
{foreach from=$cart.products.$key.extra.events key="item_id" item="ordered_amount"}
<input type="hidden" name="cart_products[{$key}][extra][events][{$item_id}]" value="{$ordered_amount}" />
{/foreach}
{/if}