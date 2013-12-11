<?php
/***************************************************************************
*                                                                          *
*   (c) 2004 Vladimir V. Kalynyak, Alexey V. Vinokurov, Ilya M. Shalnev    *
*                                                                          *
* This  is  commercial  software,  only  users  who have purchased a valid *
* license  and  accept  to the terms of the  License Agreement can install *
* and use this program.                                                    *
*                                                                          *
****************************************************************************
* PLEASE READ THE FULL TEXT  OF THE SOFTWARE  LICENSE   AGREEMENT  IN  THE *
* "copyright.txt" FILE PROVIDED WITH THIS DISTRIBUTION PACKAGE.            *
****************************************************************************/

use Tygh\Registry;

if (!defined('BOOTSTRAP')) { die('Access denied'); }

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if ($mode == 'options') {
        if (!empty($_REQUEST['event_products']) && !empty($_REQUEST['appearance']['events'])) {
            $event_data['products'] = db_get_hash_array("SELECT * FROM ?:giftreg_event_products LEFT JOIN ?:product_descriptions ON ?:product_descriptions.product_id = ?:giftreg_event_products.product_id AND ?:product_descriptions.lang_code = ?s WHERE event_id = ?i", 'item_id', CART_LANGUAGE, $_REQUEST['appearance']['event_id']);

            foreach ($event_data['products'] as $k => $v) {
                $event_data['products'][$k]['extra'] = $event_data['products'][$k]['selected_options'] = @$_REQUEST['event_products'][$k]['product_options'];
                $product_options = $event_data['products'][$k]['extra'];
                $event_data['products'][$k]['product_options'] = fn_get_selected_product_options($v['product_id'], $product_options, CART_LANGUAGE);
                $event_data['products'][$k]['original_price'] = $event_data['products'][$k]['price'] = fn_get_product_price($v['product_id'], 1, $auth);
                $event_data['products'][$k]['avail_amount'] = $v['amount'] - $v['ordered_amount'];
            }

            if (!empty($_REQUEST['changed_option'])) {
                list($key, $option_id) = each($_REQUEST['changed_option']);
                if (isset($event_data['products'][$key])) {
                    $event_data['products'][$key]['changed_option'] = $option_id;
                }
            }

            fn_gather_additional_products_data($event_data['products'], array('get_icon' => true, 'get_detailed' => true, 'get_options' => true, 'get_discounts' => true));

            Registry::get('view')->assign('event_id', $_REQUEST['appearance']['event_id']);
            Registry::get('view')->assign('event_data', $event_data);

            Registry::get('view')->display('addons/gift_registry/views/events/components/event_products.tpl');

            exit;
        }
    }
}
