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

$auth = & $_SESSION['auth'];

if ($mode == 'add' && Registry::get('addons.gift_registry.event_creators') == 'registered' && empty($auth['user_id'])) {
    return array(CONTROLLER_STATUS_REDIRECT, "auth.login_form?return_url=" . urlencode(Registry::get('config.current_url')));

}

if (!empty($_REQUEST['access_key'])) {
    $_REQUEST['event_id'] = 0;
    $data = db_get_row("SELECT object_id, object_type FROM ?:ekeys WHERE ekey = ?s", $_REQUEST['access_key']);
    if (!empty($data) && strpos('OG', $data['object_type']) !== false) {
        $_REQUEST['event_id'] = $data['object_id'];

        if ($data['object_type'] == 'G' && $mode == 'update') {
            return array(CONTROLLER_STATUS_REDIRECT, "events.view?access_key=$_REQUEST[access_key]");
        }

        if ($data['object_type'] == 'O') {// owner's key
            define('EVENT_OWNER', true);
        }

        Registry::get('view')->assign('access_key', $_REQUEST['access_key']);
    } else {
        fn_set_notification('E', __('error'), __('error_invalid_access_key'));

        return array(CONTROLLER_STATUS_REDIRECT, "events.access_key");
    }

} elseif (!empty($_REQUEST['event_id'])) {
    $_data = db_get_row("SELECT user_id, type FROM ?:giftreg_events WHERE event_id = ?i AND type != 'D'", $_REQUEST['event_id']);

    // Check if the event exists
    if (empty($_data['type'])) {
        return array(CONTROLLER_STATUS_NO_PAGE);
    }

    // If event is private, ask for access code
    if ((!empty($_data['user_id']) && $auth['user_id'] != $_data['user_id']) && $mode == 'update') { // if this is user's event, go to login page

        return array(CONTROLLER_STATUS_REDIRECT, "auth.login_form?return_url=" . urlencode(Registry::get('config.current_url')));
    }

    if ($_data['type'] == 'U') {
        if ((!empty($_data['user_id']) && $auth['user_id'] == $_data['user_id'])) {
            define('EVENT_OWNER', true);
        } else {
            return array(CONTROLLER_STATUS_REDIRECT, "events.access_key");
        }
    } elseif (!empty($_data['user_id']) && $auth['user_id'] == $_data['user_id']) {
        define('EVENT_OWNER', true);
    }
}

// Search for events
if ($mode == 'search') {

    $params = $_REQUEST;

    list($events, $search) = fn_get_events($params, Registry::get('settings.Appearance.elements_per_page'));

    Registry::get('view')->assign('events', $events);
    Registry::get('view')->assign('search', $search);

    fn_add_breadcrumb(__('events'));

} elseif ($mode == 'delete') {
    if (defined('EVENT_OWNER')) {
        fn_event_delete($_REQUEST['event_id']);
    }

    return array(CONTROLLER_STATUS_REDIRECT, "events.search");

} elseif ($mode == 'unsubscribe') {
    db_query("DELETE FROM ?:giftreg_event_subscribers WHERE event_id = ?i AND email = ?s", $_REQUEST['event_id'], $_REQUEST['email']);
    fn_set_notification('N', __('notice'), __('text_event_unsubscribe'));

    return array(CONTROLLER_STATUS_REDIRECT, "events.search");

} elseif ($mode == 'view') {
    if (empty($_REQUEST['event_id'])) {
        return array(CONTROLLER_STATUS_NO_PAGE);
    }

    $event_data = db_get_row("SELECT * FROM ?:giftreg_events WHERE event_id = ?i", $_REQUEST['event_id']);

    fn_add_breadcrumb($event_data['title']);

    $event_data['fields'] = db_get_hash_single_array("SELECT * FROM ?:giftreg_event_fields WHERE ?:giftreg_event_fields.event_id = ?i", array('field_id', 'value'), $_REQUEST['event_id']);

    list($event_data['products'], $search) = fn_get_event_products($_REQUEST, Registry::get('settings.Appearance.products_per_page'));

    foreach ($event_data['products'] as $k => $v) {
        $event_data['products'][$k]['extra'] = $event_data['products'][$k]['selected_options'] = unserialize($v['extra']);
        $product_options = $event_data['products'][$k]['extra'];
        $event_data['products'][$k]['product_options'] = fn_get_selected_product_options($v['product_id'], $product_options, CART_LANGUAGE);
        $event_data['products'][$k]['original_price'] = $event_data['products'][$k]['price'] = fn_get_product_price($v['product_id'], 1, $auth);
        $event_data['products'][$k]['avail_amount'] = $v['amount'] - $v['ordered_amount'];
        $event_data['products'][$k]['disabled_options'] = true;

        $event_data['products'][$k]['product_options_ids'] = $event_data['products'][$k]['extra'];
        $event_data['products'][$k]['product_options_combination'] = fn_get_options_combination($event_data['products'][$k]['product_options_ids']);
        if (!empty($event_data['products'][$k]['selected_options'])) {
            $options = fn_get_selected_product_options($v['product_id'], $product_options, CART_LANGUAGE);
            foreach ($event_data['products'][$k]['selected_options'] as $option_id => $variant_id) {
                foreach ($options as $option) {
                    if ($option['option_id'] == $option_id && !in_array($option['option_type'], array('I', 'T', 'F')) && empty($variant_id)) {
                        $event_data['products'][$k]['changed_option'] = $option_id;
                        break 2;
                    }
                }
            }
        }
    }

    fn_gather_additional_products_data($event_data['products'], array('get_icon' => true, 'get_detailed' => true, 'get_options' => true, 'get_discounts' => true));

    Registry::get('view')->assign('event_id', $_REQUEST['event_id']);
    Registry::get('view')->assign('event_data', $event_data);
    Registry::get('view')->assign('search', $search);

} elseif ($mode == 'access_key') {
    fn_add_breadcrumb(__('access_key'));
}
