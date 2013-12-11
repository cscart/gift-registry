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

$schema['events'] = array (
    'permissions' => array ('GET' => 'view_events', 'POST' => 'manage_events'),
    'modes' => array (
        'delete_product' => array (
            'permissions' => 'manage_events'
        ),
        'delete_events' => array (
            'permissions' => 'manage_events'
        ),
        'delete_variant' => array (
            'permissions' => 'manage_events'
        ),
        'delete_field' => array (
            'permissions' => 'manage_events'
        )
    ),
);
$schema['tools']['modes']['update_status']['param_permissions']['table']['giftreg_fields'] = 'manage_events';

return $schema;
