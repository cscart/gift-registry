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
use Tygh\Navigation\LastView;

if (!defined('BOOTSTRAP')) { die('Access denied'); }

function fn_get_gift_registry_company_condition($field)
{
    if (fn_allowed_for('ULTIMATE')) {
        return fn_get_company_condition($field);
    }

    return '';
}

//
// Delete event
//
function fn_event_delete($event_id, $user_id = 0)
{
    if (!empty($user_id)) {
        $event_id = db_get_field("SELECT event_id FROM ?:giftreg_events WHERE event_id = ?i AND user_id = ?i", $event_id, $user_id);
        if (empty($event_id)) {
            return false;
        }
    }

    db_query("DELETE FROM ?:giftreg_events WHERE event_id = ?i", $event_id);
    db_query("DELETE FROM ?:giftreg_event_fields WHERE event_id = ?i", $event_id);
    db_query("DELETE FROM ?:giftreg_event_products WHERE event_id = ?i", $event_id);
    db_query("DELETE FROM ?:giftreg_event_subscribers WHERE event_id = ?i", $event_id);
    db_query("DELETE FROM ?:ekeys WHERE object_id = ?i AND object_type IN ('O', 'G')", $event_id);

    fn_set_hook('delete_event', $event_id);

    return true;
}

//
// Generate access key for private events and owner
//
function fn_event_generate_ekey($event_id, $owner = false)
{

    $ekey = md5(uniqid(rand()));

    $data = array(
        'object_id' => $event_id,
        'object_type' => ($owner == true) ? 'O' : 'G',
        'ekey' => $ekey,
        'ttl' => 0
    );
    db_query("DELETE FROM ?:ekeys WHERE object_id = ?i AND object_type = ?s", $data['object_id'], $data['object_type']);
    db_query("INSERT INTO ?:ekeys ?e", $data);

    return $ekey;
}

//
// Delete expired events
//
function fn_event_update_status()
{
    if (fn_is_expired_storage_data('gift_registry_next_check', GIFTREG_STATUS_CHECK_PERIOD)) {
        db_query("UPDATE ?:giftreg_events SET status = IF(start_date > ?i, 'A', IF(end_date < ?i, 'F', 'P'))", TIME, TIME);
    }
}

//
// Add fields to gift registry
//
function fn_giftreg_add_fields($fields)
{
    if (empty($fields)) {
        return false;
    }

    foreach ($fields as $v) {

        if (empty($v['description'])) {
            continue;
        }

        // Insert main data
        $field_id = db_query("INSERT INTO ?:giftreg_fields ?e", $v);
        // Insert descriptions
        $_data = array(
            'object_id' => $field_id,
            'object_type' => 'F',
            'description' => $v['description'],
        );

        foreach (fn_get_translation_languages() as $_data['lang_code'] => $_v) {
            db_query("INSERT INTO ?:giftreg_descriptions ?e", $_data);
        }

        if (substr_count('SR', $v['field_type']) && is_array($v['variants'])) {
            fn_giftreg_add_field_variants($v['variants'], $field_id);
        }
    }

    return true;
}

//
// Add variants for gift registry field
//
function fn_giftreg_add_field_variants($variants = array(), $field_id = 0)
{
    if (empty($variants) || empty($field_id)) {
        return false;
    }

    foreach ($variants as $_v) {

        if (empty($_v['description'])) {
            continue;
        }
        // Insert main data
        $_v['field_id'] = $field_id;
        $variant_id = db_query("INSERT INTO ?:giftreg_field_variants ?e", $_v);

        // Insert descriptions
        $_data = array(
            'object_id' => $variant_id,
            'object_type' => 'V',
            'description' => $_v['description'],
        );

        foreach (fn_get_translation_languages() as $_data['lang_code'] => $_v) {
            db_query("INSERT INTO ?:giftreg_descriptions ?e", $_data);
        }
    }

    return true;
}

//
// Delete variants of gift registry field
//
function fn_giftreg_delete_field_variants($field_id)
{

    $vars = db_get_fields("SELECT variant_id FROM ?:giftreg_field_variants WHERE field_id = ?i", $field_id);
    if (!empty($vars)) {
        db_query("DELETE FROM ?:giftreg_descriptions WHERE object_id IN (?a) AND object_type = 'V'", $vars);
        db_query("DELETE FROM ?:giftreg_field_variants WHERE field_id = ?i", $field_id);
    }
}

function fn_update_event_subscribers($event_data, $event_id)
{
    $subscribers = array();
    if (!empty($event_data['subscribers'])) {
        $subscribers = $event_data['subscribers'];
    }
    if (!empty($event_data['add_subscribers'])) {
        $subscribers = fn_array_merge($subscribers, $event_data['add_subscribers'], false);
    }

    if (!empty($subscribers)) {
        $invalid_emails = array();
        db_query("DELETE FROM ?:giftreg_event_subscribers WHERE event_id = ?i", $event_id);
        foreach ($subscribers as $v) {
            if (empty($v['email']) || empty($v['name'])) {
                continue;
            }

            if (fn_validate_email($v['email']) == false) {
                $invalid_emails[] = $v['email'];
            }

            $v['event_id'] = $event_id;
            db_query("REPLACE INTO ?:giftreg_event_subscribers ?e", $v);
        }

        if (!empty($invalid_emails)) {
            fn_set_notification('W', __('warning'), __('error_invalid_emails', array(
                '[emails]' => implode(', ', $invalid_emails)
            )));
        }
    }

    return true;
}

function fn_gift_registry_get_discussion_object_data(&$data, &$object_id, &$object_type)
{
    if ($object_type == 'G') { // gift registry
        $data['description'] = db_get_field("SELECT title FROM ?:giftreg_events WHERE event_id = ?i", $object_id);
        if (AREA == 'A') {
            $data['url'] = "events.update?event_id=$object_id&selected_section=discussion";
        } else {
            $data['url'] = "events?event_id=$object_id";
        }
    }
}

function fn_gift_registry_get_discussion_objects(&$objects)
{
    $objects['G'] = 'gift_registry';
}

function fn_gift_registry_is_accessible_discussion(&$data, &$auth, &$access)
{

    if ($data['object_type'] == 'G') {// gift_registry
        $_data = db_get_row("SELECT user_id, type FROM ?:giftreg_events WHERE event_id = ?i AND type != 'D'", $data['object_id']);

        // If event is private, ask for access code
        if (empty($_data['type']) || (!empty($_data['user_id']) && $auth['user_id'] != $_data['user_id'])) {
            $access = false;
        }

        if ($_data['type'] == 'U') {
            if (empty($_data['user_id'])) { // if this is anonymous event, ask for access key
                $access = false;
            } elseif ((!empty($_data['user_id']) && $auth['user_id'] == $_data['user_id'])) {
                $access = true;
            } else {
                $access = false;
            }
        } elseif (!empty($_data['user_id']) && $auth['user_id'] == $_data['user_id']) {
            $access = true;
        }
    }
}

function fn_gift_registry_change_order_status(&$status_to, &$status_from, &$order_info)
{
    $order_statuses = fn_get_statuses(STATUSES_ORDER, array(), true);

    if ($order_statuses[$status_to]['params']['inventory'] == 'D' && $order_statuses[$status_from]['params']['inventory'] == 'I') { // decrease amount
        $sign = '+';
    } elseif ($order_statuses[$status_to]['params']['inventory'] == 'I' && $order_statuses[$status_from]['params']['inventory'] == 'D') { // increase amount
        $sign = '-';
    }

    if (!empty($sign)) {
        foreach ($order_info['products'] as $v) {
            if (is_array($v['extra']) && !empty($v['extra']['events'])) {
                foreach ($v['extra']['events'] as $item_id => $amount) {
                    db_query("UPDATE ?:giftreg_event_products SET ordered_amount = ordered_amount $sign ?i WHERE item_id = ?i AND event_id = ?i", $amount, $item_id, $v['extra']['events']['event_id']);
                }
            }
        }
    }
}

function fn_gift_registry_pre_place_order(&$cart, &$allow)
{
    // corect ordered amount for events
    if (!empty($cart['products'])) {
        foreach ((array) $cart['products'] as $k => $v) {
            if (is_array($v['extra']) && !empty($v['extra']['events'])) {
                foreach ($v['extra']['events'] as $item_id => $amount) {
                    if ($amount > $v['amount']) {
                        $cart['products'][$k]['extra']['events'][$item_id] = $v['amount'];
                    }
                }
            }
        }
    }
}

function fn_gift_registry_place_order(&$order_id)
{
    $order_info = fn_get_order_info($order_id);
    $status_from = 'B';
    fn_gift_registry_change_order_status($order_info['status'], $status_from, $order_info);
}

function fn_get_event_name($event_id)
{
    if (!empty($event_id)) {
        return db_get_field("SELECT title FROM ?:giftreg_events WHERE event_id = ?i", $event_id);
    }

    return false;
}

function fn_update_event($event_data, $event_id = 0)
{
    $event_data['start_date'] = fn_parse_date($event_data['start_date']);
    $event_data['end_date'] = fn_parse_date($event_data['end_date'], true);

    if ($event_data['start_date'] > TIME) {
        $event_data['status'] = 'A';
    } elseif ($event_data['end_date'] < TIME) {
        $event_data['status'] = 'F';
    } else {
        $event_data['status'] = 'P';
    }

    $_data = $event_data;
    $_data['user_id'] = $_SESSION['auth']['user_id'];

    if (empty($_data['company_id']) && Registry::get('runtime.company_id')) {
        $_data['company_id'] = Registry::get('runtime.company_id');
    }

    if (empty($event_id)) {
        $event_id = db_query("INSERT INTO ?:giftreg_events ?e", $_data);
    } else {
        unset($_data['user_id']);
        db_query("UPDATE ?:giftreg_events SET ?u WHERE event_id = ?i", $_data, $event_id);
    }

    fn_update_event_subscribers($event_data, $event_id);

    // Generate access key for editing this event
    if (AREA == 'C') {
        $access_key = fn_event_generate_ekey($event_id, true);
    }

    // Generate access key for event subscribers (for private event)
    if ($_data['type'] == 'U') {
        fn_event_generate_ekey($event_id);
    }

    if (!empty($event_data['fields'])) {
        $_data = array (
            'event_id' => $event_id,
        );

        db_query("DELETE FROM ?:giftreg_event_fields WHERE event_id = ?i", $event_id);

        foreach ($event_data['fields'] as $field_id => $value) {
            if (substr_count($value, '/') == 2) { // FIXME: it's date field
                $value = fn_parse_date($value);
            }
            $_data['field_id'] = $field_id;
            $_data['value'] = $value;
            db_query("INSERT INTO ?:giftreg_event_fields ?e", $_data);
        }
    }

    fn_set_hook('update_event', $event_data, $event_id);

    return array($event_id, empty($access_key) ? '' : $access_key);
}

function fn_delete_events_variant($variant_id)
{
    db_query("DELETE FROM ?:giftreg_field_variants WHERE variant_id = ?i", $variant_id);
    db_query("DELETE FROM ?:giftreg_descriptions WHERE object_id = ?i AND object_type = 'V'", $variant_id);
}

function fn_delete_events_field($field_id)
{
    fn_giftreg_delete_field_variants($field_id);
    db_query("DELETE FROM ?:giftreg_fields WHERE field_id = ?i", $field_id);
    db_query("DELETE FROM ?:giftreg_descriptions WHERE object_id = ?i AND object_type = 'F'", $field_id);
}

function fn_get_event_products($params, $items_per_page = 0, $lang_code = CART_LANGUAGE)
{
    $default_params = array (
        'page' => 1,
        'event_id' => 0,
        'items_per_page' => $items_per_page
    );

    $params = array_merge($default_params, $params);

    $limit = '';
    if (!empty($params['items_per_page'])) {
        $params['total_items'] = db_get_field("SELECT DISTINCT(COUNT(*)) FROM ?:giftreg_event_products WHERE event_id = ?i", $params['event_id']);
        $limit = db_paginate($params['page'], $params['items_per_page']);
    }

    $products = db_get_hash_array("SELECT * FROM ?:giftreg_event_products LEFT JOIN ?:product_descriptions ON ?:product_descriptions.product_id = ?:giftreg_event_products.product_id AND ?:product_descriptions.lang_code = ?s WHERE event_id = ?i $limit", 'item_id', $lang_code, $params['event_id']);

    return array($products, $params);
}

function fn_gift_registry_delete_product_post(&$product_id)
{
    db_query("DELETE FROM ?:giftreg_event_products WHERE product_id = ?i", $product_id);

    return true;
}

/**
 * Get event fields
 *
 * @param string $lang_code      2 letters language code
 * @return array Event fields
 */
function fn_get_event_fields($lang_code = CART_LANGUAGE)
{
    $fields = db_get_hash_array(
        "SELECT ?:giftreg_fields.*, ?:giftreg_descriptions.description"
        . " FROM ?:giftreg_fields"
        . " LEFT JOIN ?:giftreg_descriptions ON ?:giftreg_fields.field_id = ?:giftreg_descriptions.object_id AND ?:giftreg_descriptions.object_type = 'F' AND ?:giftreg_descriptions.lang_code = ?s"
        . " ORDER BY ?:giftreg_fields.position",
        'field_id', $lang_code
    );

    foreach ($fields as $k => $v) {
        if (strpos('SR', $v['field_type']) !== false) {
            $fields[$k]['variants'] = db_get_hash_array(
                "SELECT ?:giftreg_field_variants.*, ?:giftreg_descriptions.description"
                . " FROM ?:giftreg_field_variants"
                . " LEFT JOIN ?:giftreg_descriptions ON ?:giftreg_descriptions.object_id = ?:giftreg_field_variants.variant_id AND ?:giftreg_descriptions.object_type = 'V' AND ?:giftreg_descriptions.lang_code = ?s"
                . " WHERE ?:giftreg_field_variants.field_id = ?i"
                . " ORDER BY ?:giftreg_field_variants.position",
                'variant_id', $lang_code, $v['field_id']
            );
        }
    }

    return $fields;
}

/**
 * Searches for events
 *
 * @param array $params Events search params
 * @param int $items_per_page Items per page
 * @param string $lang_code 2-letters language code
 * @return array Array with 2 params
 *              array $events Events data
 *              array $params Events search params
 */
function fn_get_events($params, $items_per_page = 0)
{
    // Init filter
    $params = LastView::instance()->update('events', $params);

    // Set default values to input params
    $default_params = array (
        'page' => 1,
        'items_per_page' => $items_per_page
    );

    $params = array_merge($default_params, $params);

    // Define fields that should be retrieved
    $fields = array (
        '*',
    );

    $condition = $join = '';

    if (!empty($params['type'])) {
        $condition .= db_quote(" AND type IN (?a)", $params['type']);
    }

    if (!empty($params['period']) && $params['period'] != 'A') {
        list($params['time_from'], $params['time_to']) = fn_create_periods($params);

        $condition .= db_quote(" AND (start_date >= ?i AND end_date <= ?i)", $params['time_from'], $params['time_to']);
    }

    if (isset($params['owner']) && fn_string_not_empty($params['owner'])) {
        $condition .= db_quote(" AND (owner LIKE ?l OR ?:giftreg_events.email LIKE ?l)", "%".trim($params['owner'])."%", "%".trim($params['owner'])."%");
    }

    if (isset($params['title']) && fn_string_not_empty($params['title'])) {
        $condition .= db_quote(" AND title LIKE ?l", "%".trim($params['title'])."%");
    }

    if (!empty($params['type'])) {
        $condition .= db_quote(" AND type IN (?a)", $params['type']);
    }

    if (!empty($params['status'])) {
        $condition .= db_quote(" AND status IN (?a)", $params['status']);
    }

    if (isset($params['subscriber']) && fn_string_not_empty($params['subscriber'])) {
        $join .= " INNER JOIN ?:giftreg_event_subscribers ON ?:giftreg_event_subscribers.event_id = ?:giftreg_events.event_id";
        $condition .= db_quote(" AND (?:giftreg_event_subscribers.name LIKE ?l OR ?:giftreg_event_subscribers.email LIKE ?l)", "%".trim($params['subscriber'])."%", "%".trim($params['subscriber'])."%");
    }

    if (!empty($params['search_fields'])) {
        $_cond = array();
        $total_hits = 0;
        foreach ($params['search_fields'] as $f_id => $f_val) {
            $_condition = array();
            if (substr_count($f_val, '/') == 2) { // FIXME: it's date field
                $_condition[] = db_quote("?:giftreg_event_fields.value = ?s", fn_parse_date($f_val));
            } else {
                $_condition[] = db_quote("?:giftreg_event_fields.value LIKE ?l", "%$f_val%");
            }

            if (!empty($f_val)) {
                $total_hits++;
                $_cond[] = db_quote("(?:giftreg_event_fields.field_id = ?i AND ", $f_id) . implode(" AND ", $_condition) . ')';
            }
        }

        if (!empty($_cond)) {
            $cache_field_search = db_get_fields("SELECT event_id, COUNT(event_id) as cnt FROM ?:giftreg_event_fields WHERE (" . implode(' OR ', $_cond) . ") GROUP BY event_id HAVING cnt = $total_hits");
            $condition .= db_quote(" AND event_id IN (?n)", $cache_field_search);
        }
    }

    if (!empty($params['today_events'])) {
        $condition .= db_quote("AND (start_date <= ?i AND end_date > ?i)", TIME, TIME);
    }

    $limit = '';
    if (!empty($params['items_per_page'])) {
        $params['total_items'] = db_get_field("SELECT COUNT(*) FROM ?:giftreg_events ?p WHERE 1 ?p", $join, $condition . fn_get_gift_registry_company_condition('?:giftreg_events.company_id'));
        $limit = db_paginate($params['page'], $params['items_per_page']);
    }

    $events = db_get_array(
        "SELECT ?p FROM ?:giftreg_events ?p WHERE 1 ?p ORDER BY start_date ASC ?p",
          implode(',', $fields), $join, $condition . fn_get_gift_registry_company_condition('?:giftreg_events.company_id'), $limit
    );

    LastView::instance()->processResults('events', $events, $params);

    return array($events, $params);
}

if (fn_allowed_for('ULTIMATE')) {
    function fn_gift_registry_ult_check_store_permission(&$params, &$object_type, &$object_name, &$table, &$key, &$key_id)
    {
        if (Registry::get('runtime.controller') == 'events' && !empty($params['event_id'])) {
            $key = 'event_id';
            $key_id = $params[$key];
            $table = 'giftreg_events';
            $object_name = fn_get_event_name($key_id);
            $object_type = __('event');
        }
    }
}
