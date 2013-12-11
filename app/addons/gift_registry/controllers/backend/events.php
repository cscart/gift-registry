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

    $suffix = '';

    // Add new fields to event
    if ($mode == 'add_fields') {
        if (is_array($_REQUEST['add_fields_data'])) {
            fn_giftreg_add_fields($_REQUEST['add_fields_data']);
        }

        $suffix = ".field_editor";
    }

    // Update event fields
    if ($mode == 'update_fields') {
        if (@is_array($_REQUEST['fields_data'])) {
            foreach ($_REQUEST['fields_data'] as $field_id => $data) {
                db_query("UPDATE ?:giftreg_fields SET ?u WHERE field_id = ?i", $data, $field_id);

                $_data = array (
                    'object_id' => $field_id,
                    'object_type' => 'F',
                    'description' => $data['description'],
                    'lang_code' => DESCR_SL
                );
                db_query("REPLACE INTO ?:giftreg_descriptions ?e", $_data);

                if (!empty($data['variants']) && is_array($data['variants'])) {
                    foreach ($data['variants'] as $variant_id => $vdata) {
                        db_query("UPDATE ?:giftreg_field_variants SET ?u WHERE variant_id = ?i", $vdata, $variant_id);

                        $_data = array (
                            'object_id' => $variant_id,
                            'object_type' => 'V',
                            'description' => $vdata['description'],
                            'lang_code' => DESCR_SL
                        );
                        db_query("REPLACE INTO ?:giftreg_descriptions ?e", $_data);
                    }
                }

                if (substr_count('SR', $data['field_type']) && is_array($data['add_variants'])) {
                    fn_giftreg_add_field_variants($data['add_variants'], $field_id);
                } else {
                    fn_giftreg_delete_field_variants($field_id);
                }
            }
        }
        $suffix = ".field_editor";
    }

    // Delete fields and/or variants
    if ($mode == 'm_delete_fields') {
        if (!empty($_REQUEST['field_ids'])) {
            foreach ($_REQUEST['field_ids'] as $field_id) {
                fn_delete_events_field($field_id);
            }
        }

        if (!empty($_REQUEST['var_ids'])) {
            foreach ($_REQUEST['var_ids'] as $variant_id) {
                fn_delete_events_variant($variant_id);
            }
        }

        $suffix = ".field_editor";
    }

    return array(CONTROLLER_STATUS_OK, "events$suffix");
}

if ($mode == 'manage') {

    $params = $_REQUEST;

    list($events, $search) = fn_get_events($params, Registry::get('settings.Appearance.admin_elements_per_page'));

    Registry::get('view')->assign('events', $events);
    Registry::get('view')->assign('search', $search);

} elseif ($mode == 'delete_field') {
    if (!empty($_REQUEST['field_id'])) {
        fn_delete_events_field($_REQUEST['field_id']);
    }

    return array(CONTROLLER_STATUS_REDIRECT, "events.field_editor");

} elseif ($mode == 'delete_variant') {
    if (!empty($_REQUEST['var_id'])) {
        fn_delete_events_variant($_REQUEST['var_id']);
    }

    return array(CONTROLLER_STATUS_REDIRECT, "events.field_editor");

} elseif ($mode == 'delete') {
    if (!empty($_REQUEST['event_id'])) {
        fn_event_delete($_REQUEST['event_id']);
    }

    return array(CONTROLLER_STATUS_REDIRECT, "events.manage");

} elseif ($mode == 'delete_product') {
    if (!empty($_REQUEST['product_id']) && !empty($_REQUEST['event_id'])) {
        db_query("DELETE FROM ?:giftreg_event_products WHERE item_id = ?i AND event_id = ?i", $_REQUEST['product_id'], $_REQUEST['event_id']);
    }

    return array(CONTROLLER_STATUS_REDIRECT, "events.update?selected_section=products&event_id=$_REQUEST[event_id]");
}
