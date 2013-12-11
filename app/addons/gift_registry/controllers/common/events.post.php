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
use Tygh\Mailer;

if (!defined('BOOTSTRAP')) { die('Access denied'); }

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    // Delete events
    if ($mode == 'm_delete') {
        if (!empty($_REQUEST['event_ids']) && is_array($_REQUEST['event_ids'])) {
            foreach ($_REQUEST['event_ids'] as $v) {
                if (AREA == 'C') {
                    if (empty($auth['user_id'])) {
                        continue;
                    }
                }

                fn_event_delete($v, (AREA == 'C') ? $auth['user_id'] : 0);
            }
        }
        $suffix = (AREA == 'C') ? '.search' : '.manage';
    }

    // Send notifications
    if ($mode == 'send_notifications') {
        if (!empty($_REQUEST['event_recipients'])) {

            $event_data = db_get_row("SELECT event_id, title, status, type, owner FROM ?:giftreg_events WHERE event_id = ?i", $_REQUEST['event_id']);
            $a_key = '';
            if ($event_data['type'] == 'U') {// If the event is private - get ekey for it
                $a_key = db_get_field("SELECT ekey FROM ?:ekeys WHERE object_id = ?i AND object_type = 'G'", $event_data['event_id']);
            }

            $emails = db_get_array("SELECT email, name FROM ?:giftreg_event_subscribers WHERE event_id = ?i AND email IN (?a)", $_REQUEST['event_id'], $_REQUEST['event_recipients']);

            foreach ($emails as $recipient) {
                Mailer::sendMail(array(
                    'to' => $recipient['email'],
                    'from' => 'default_company_newsletter_email',
                    'data' => array(
                        'recipient' => $recipient,
                        'access_key' => $a_key,
                        'event' => $event_data
                    ),
                    'tpl' => 'addons/gift_registry/event.tpl'
                ), 'C');
            }
            fn_set_notification('N', __('notice'), __('text_email_sent'));
        }
        $suffix = ".update?event_id=$_REQUEST[event_id]&selected_section=notifications";
    }

    // Delete products from event
    if ($mode == 'm_delete_products') {
        foreach ($_REQUEST['event_product_ids'] as $item_id) {
            db_query("DELETE FROM ?:giftreg_event_products WHERE item_id = ?i AND event_id = ?i", $item_id, $_REQUEST['event_id']);
        }

        $suffix = ".update?selected_section=products&event_id=$_REQUEST[event_id]";
    }

    // Add products to the event
    if ($mode == 'add_products') {
        if (!empty($_REQUEST['product_data'])) {
            fn_update_event_products($_REQUEST['event_id'], $_REQUEST['product_data'], true);
        }
        $suffix = ".update?selected_section=products&event_id=$_REQUEST[event_id]";
    }

    // Update the event
    if ($mode == 'update') {
        if (AREA == 'C' && !empty($_REQUEST['event_id']) && !defined('EVENT_OWNER') && Registry::get('addons.gift_registry.event_creators') != 'all') {
            return array(CONTROLLER_STATUS_DENIED);
        }

        if (!empty($_REQUEST['event_data'])) {
            list($event_id, $access_key) = fn_update_event($_REQUEST['event_data'], $_REQUEST['event_id']);
        }

        // Update event products
        if (!empty($_REQUEST['event_products'])) {
            $event_id = empty($event_id) ? $_REQUEST['event_id'] : $event_id;
            unset($_REQUEST['event_products']['custom_files']);
            fn_update_event_products($event_id, $_REQUEST['event_products']);
        }

        $suffix = ".update?event_id=$event_id";
        $suffix .= !empty($access_key) ? "&access_key=$access_key" : '';
    }

    if ($mode == 'request_access_key') {
        if (!empty($_REQUEST['email'])) {
            // check if this email is used by event creator (for private events and anonymous)
            $owner_events = db_get_array(
                "SELECT ?:giftreg_events.event_id, ?:giftreg_events.title, ?:giftreg_events.owner, ?:ekeys.ekey " .
                "FROM ?:giftreg_events LEFT JOIN ?:ekeys ON ?:ekeys.object_id = ?:giftreg_events.event_id AND ?:ekeys.object_type = 'O' " .
                "WHERE ?:giftreg_events.email = ?s AND (?:giftreg_events.type = 'U' || ?:giftreg_events.user_id = 0) ?p",
                $_REQUEST['email'], fn_get_gift_registry_company_condition('?:giftreg_events.company_id')
            );

            // check if this email is used in event recipients
            $subscriber_events = db_get_array(
                "SELECT ?:giftreg_event_subscribers.name, ?:giftreg_events.owner, ?:giftreg_event_subscribers.event_id, ?:giftreg_events.title, ?:ekeys.ekey " .
                "FROM ?:giftreg_event_subscribers LEFT JOIN ?:giftreg_events ON ?:giftreg_events.event_id = ?:giftreg_event_subscribers.event_id " .
                "LEFT JOIN ?:ekeys ON ?:ekeys.object_id = ?:giftreg_event_subscribers.event_id AND ?:ekeys.object_type = 'G' " .
                "WHERE ?:giftreg_event_subscribers.email = ?s AND ?:giftreg_events.type = 'U' ?p",
                $_REQUEST['email'], fn_get_gift_registry_company_condition('?:giftreg_events.company_id')
            );

            if (empty($subscriber_events) && empty($owner_events)) {
                fn_set_notification('E', __('error'), __('error_giftreg_email_not_found'));
            } else {

                Mailer::sendMail(array(
                    'to' => $_REQUEST['email'],
                    'from' => 'default_company_users_department',
                    'data' => array(
                        'owner_events' => $owner_events,
                        'subscriber_events' => $subscriber_events
                    ),
                    'tpl' => 'addons/gift_registry/access_key.tpl'
                ), 'C');

                fn_set_notification('N', __('notice'), __('text_email_sent'));
            }
        }
        $suffix = ".access_key";
    }

    if (AREA == 'A' && empty($suffix)) {
        $suffix = '.field_editor';
    }

    return array(CONTROLLER_STATUS_OK, "events$suffix");
}

//
// Update event
//
if ($mode == 'update') {
    if (empty($_REQUEST['event_id'])) {
        return array(CONTROLLER_STATUS_NO_PAGE);
    }

    if (AREA == 'C' && !defined('EVENT_OWNER') && Registry::get('addons.gift_registry.event_creators') != 'all') {
        return array(CONTROLLER_STATUS_DENIED);
    }

    $event_data = db_get_row("SELECT * FROM ?:giftreg_events WHERE event_id = ?i", $_REQUEST['event_id']);

    $event_data['fields'] = db_get_hash_single_array("SELECT * FROM ?:giftreg_event_fields WHERE ?:giftreg_event_fields.event_id = ?i", array('field_id', 'value'), $_REQUEST['event_id']);

    $event_data['subscribers'] = db_get_array("SELECT name, email FROM ?:giftreg_event_subscribers WHERE event_id = ?i ORDER BY name, email", $_REQUEST['event_id']);

    list($event_data['products'], $search) = fn_get_event_products($_REQUEST, Registry::get('settings.Appearance.products_per_page'));

    foreach ($event_data['products'] as $k => $v) {
        $event_data['products'][$k]['extra'] = $event_data['products'][$k]['selected_options'] = unserialize($v['extra']);
        $product_options = $event_data['products'][$k]['extra'];
        $event_data['products'][$k]['product_options'] = fn_get_selected_product_options($v['product_id'], $product_options, CART_LANGUAGE);
        $event_data['products'][$k]['original_price'] = $event_data['products'][$k]['price'] = fn_get_product_price($v['product_id'], 1, $auth);
        $event_data['products'][$k]['avail_amount'] = $v['amount'] - $v['ordered_amount'];

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

    Registry::set('navigation.tabs', array (
        'general' => array (
            'title' => __('general'),
            'js' => true
        ),
        'products' => array (
            'title' => __('products'),
            'js' => true
        ),
        'notifications' => array (
            'title' => __('notifications'),
            'js' => true
        ),
    ));

    if (AREA != 'A') {
        fn_add_breadcrumb(__('events'), "events.search");
        fn_add_breadcrumb($event_data['title']);
    }

//
// Add new event
//
} elseif ($mode == 'add') {

    Registry::set('navigation.tabs', array (
        'general' => array (
            'title' => __('general'),
            'js' => true
        ),
    ));

    if (AREA != 'A') {
        fn_add_breadcrumb(__('events'), "events.search");
        fn_add_breadcrumb(__('add'));
    }

//
// Delete products from event
//
} elseif ($mode == 'delete_product' && !empty($_REQUEST['item_id']) && !empty($_REQUEST['event_id'])) {

    $suffix = '.update?event_id=' . $_REQUEST['event_id'];

    if (!empty($auth['user_id'])) {
        $event_id = db_get_field("SELECT event_id FROM ?:giftreg_events WHERE event_id = ?i AND user_id = ?i", $_REQUEST['event_id'], $auth['user_id']);

        if (!empty($event_id)) {
            db_query("DELETE FROM ?:giftreg_event_products WHERE item_id = ?i AND event_id = ?i", $_REQUEST['item_id'], $_REQUEST['event_id']);
            $suffix .= (!empty($_REQUEST['access_key']) ? "&access_key=$_REQUEST[access_key]" : '');
        }
    }

    return array(CONTROLLER_STATUS_REDIRECT, "events$suffix");
}

$fields_lang = CART_LANGUAGE;

if ($mode == 'field_editor') {
    $fields_lang = DESCR_SL;
}

$fields = fn_get_event_fields($fields_lang);

Registry::get('view')->assign('event_fields', $fields);

/**
 * Update event products
 *
 * @param int $event_id Event identifier
 * @param array $event_products Array of new data for products information update
 * @param boolean $is_add Flag that defines if products are added
 * @return boolean Always true
 */
function fn_update_event_products($event_id, $event_products, $is_add = false)
{
    foreach ($event_products as $item_id => $data) {

        $product_id = ($is_add || empty($data['product_id'])) ? $item_id : $data['product_id'];

        $data['item_id'] = fn_generate_cart_id($product_id, array("product_options" => (!empty($data['product_options']) ? $data['product_options'] : array())), false);

        if (!empty($data['product_options'])) {
            $data['extra'] = serialize($data['product_options']);
        }
        $data['event_id'] = $event_id;

        if ($is_add || $data['item_id'] != $item_id) {
            $existent_amount = db_get_field("SELECT amount FROM ?:giftreg_event_products WHERE item_id = ?i AND event_id = ?i", $data['item_id'], $event_id);
            $data['product_id'] = $product_id;
            if (!$is_add) {
                db_query("DELETE FROM ?:giftreg_event_products WHERE item_id = ?i AND event_id = ?i", $item_id, $event_id);
            }
            if (!empty($data['amount'])) {
                $data['amount'] += $existent_amount;
                db_query("REPLACE INTO ?:giftreg_event_products ?e", $data);
            }
        } else {
            $existent_amount = db_get_field("SELECT amount FROM ?:giftreg_event_products WHERE item_id = ?i AND event_id = ?i", $data['item_id'], $event_id);
            if (!empty($data['amount'])) {
                db_query("UPDATE ?:giftreg_event_products SET ?u WHERE item_id = ?i AND event_id = ?i", $data, $item_id, $event_id);
            } else {
                db_query("DELETE FROM ?:giftreg_event_products WHERE item_id = ?i AND event_id = ?i", $item_id, $event_id);
            }
        }
    }

    return true;
}
