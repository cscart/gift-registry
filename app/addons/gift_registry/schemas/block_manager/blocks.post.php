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

$schema['gift_registry'] = array(
    'templates' => array(
        'addons/gift_registry/blocks/giftregistry.tpl' => array(),
    ),
    'wrappers' => 'blocks/wrappers',
    'cache'	=> array(
        'update_handlers' => 'giftreg_events'
    )
);
$schema['gift_registry_key'] = array(
    'templates' => array(
        'addons/gift_registry/blocks/giftregistry_key.tpl' => array(),
    ),
    'wrappers' => 'blocks/wrappers'
);

return $schema;
