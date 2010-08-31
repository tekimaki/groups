<?php
/**
 * @version $Header$
 */
global $gBitInstaller;

$infoHash = array(
	'package'      => GROUP_PKG_NAME,
	'version'      => str_replace( '.php', '', basename( __FILE__ )),
	'description'  => "Update permissions and roles tables to allow longer character string for guid values.",
	'post_upgrade' => NULL,
);

$gBitInstaller->registerPackageUpgrade( $infoHash, array(

array( 'DATADICT' => array(
	// insert new column
	array( 'ALTER' => array(
		'groups_permissions' => array(
			'perm_name' => array( '`perm_name`', 'TYPE VARCHAR(128)' ),
		),
		'groups_roles_perms_map' => array(
			'perm_name' => array( '`perm_name`', 'TYPE VARCHAR(128)' ),
		),
	)),
)),

));
