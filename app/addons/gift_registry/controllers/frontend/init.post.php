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
    return;
}

$today_events = db_get_array(
    "SELECT event_id, title FROM ?:giftreg_events " .
    "WHERE (start_date <= ?i AND end_date > ?i) AND type IN ('P','U') ?p ORDER BY start_date LIMIT ?p",
    TIME, TIME, fn_get_gift_registry_company_condition('?:giftreg_events.company_id'), (Registry::get('addons.gift_registry.events_in_sidebox') + 1)
);

if (count($today_events) > Registry::get('addons.gift_registry.events_in_sidebox')) {
    array_pop($today_events);
    Registry::get('view')->assign('more_link', true);
}

Registry::get('view')->assign('today_events', $today_events);

fn_event_update_status();
