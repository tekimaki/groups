<?php
// $Header: /cvsroot/bitweaver/_bit_groups/Attic/mailman_lib.php,v 1.3 2008/04/07 17:13:57 spiderr Exp $
// Copyright (c) bitweaver Group
// All Rights Reserved.
// Licensed under the GNU LESSER GENERAL PUBLIC LICENSE. See license.txt for details.

/**
* mailman lib 
* library of functions to manipulate mailman lists
*
* @date created 2008-APR-06
* @author wjames <will@tekimaki.com> spider <spider@viovio.com>
* @version 
* @class BitGroup
*/

function mailman_verify_list( $pListName ) {
	$error = NULL;
	if( $matches = preg_match( '/[^A-Za-z0-9]/', $pListName ) ) {
		$error = tra( 'Invalid mailing list name' ).': '.tra( 'List names can only contain letters and numbers' );
	} else {
		$lists = mailman_list_lists();
		if( !empty( $lists[strtolower($pListName)] ) ) {
			$error = tra( 'Invalid mailing list name' ).': '.tra( 'List already exists' );
		}
	}
	return $error;
}

function mailman_list_lists() {
	$ret = array();
	if( $output = mailman_command( 'list_lists' ) ) {
		foreach( $output as $o ) {
			if( strpos( $o, '-' ) ) {
				list( $name, $desc ) = split( '-', $o );
				$ret[strtolower( trim( $name ) )] = trim( $desc );
			}
		}
	}
	return( $ret );
}


// pParamHash follows naming convention off newlist --help usage instructions
function mailman_newlist( $pParamHash ) {
	$error = NULL;
	if( !($error = mailman_verify_list( $pParamHash['listname'] )) ) {
		$options = ' -q '.escapeshellarg( $pParamHash['listname'] );
		$options .= ' '.escapeshellarg( $pParamHash['listadmin-addr'] ).' ';
		$options .= ' '.escapeshellarg( $pParamHash['admin-password'] ).' ';
		
		$output = mailman_command( 'newlist', $options );

		$newList = $pParamHash['listname'];
		$newAliases = "
## $newList mailing list
$newList:              \"|/usr/lib/mailman/mail/mailman post $newList\"
$newList-admin:        \"|/usr/lib/mailman/mail/mailman admin $newList\"
$newList-bounces:      \"|/usr/lib/mailman/mail/mailman bounces $newList\"
$newList-confirm:      \"|/usr/lib/mailman/mail/mailman confirm $newList\"
$newList-join:         \"|/usr/lib/mailman/mail/mailman join $newList\"
$newList-leave:        \"|/usr/lib/mailman/mail/mailman leave $newList\"
$newList-owner:        \"|/usr/lib/mailman/mail/mailman owner $newList\"
$newList-request:      \"|/usr/lib/mailman/mail/mailman request $newList\"
$newList-subscribe:    \"|/usr/lib/mailman/mail/mailman subscribe $newList\"
$newList-unsubscribe:  \"|/usr/lib/mailman/mail/mailman unsubscribe $newList\"";

		if( $fh = fopen( '/etc/aliases', 'a' ) ) {
			fwrite( $fh, $newAliases );
			fclose( $fh );
			exec( 'newaliases' );
		} else {
			$error = "Could not open /etc/aliases for appending.";
		}
	}
	return $error;
}

function mailman_remove_member( $pListName, $pEmail ) {
	$ret = '';
	if( $fullCommand = mailman_get_command( 'remove_members' ) ) {
		$cmd = "echo ".escapeshellarg( $pEmail )." | $fullCommand  -f - ".escapeshellarg( $pListName );
		exec( $cmd, $ret );
	} else {
		bit_log_error( tra( 'Groups mailman command failed' ).' (remove_members) '.tra( 'File not found' ).': '.$fullCommand );
	}
}

function mailman_addmember( $pListName, $pEmail ) {
	$ret = '';
	if( $fullCommand = mailman_get_command( 'add_members' ) ) {
		$cmd = "echo ".escapeshellarg( $pEmail )." | $fullCommand  -r - ".escapeshellarg( $pListName );
		exec( $cmd, $ret );
	} else {
		bit_log_error( tra( 'Groups mailman command failed' ).' (add_members) '.tra( 'File not found' ).': '.$fullCommand );
	}
}

function mailman_findmember( $pListName, $pEmail ) {
	$options = ' -l '.escapeshellarg( $pListName ).' '.escapeshellarg( $pEmail );
	$output = mailman_command( 'find_member', $options );
	return $output;
}

function mailman_rmlist( $pListName ) {
	$ret = FALSE;
}

function mailman_command( $pCommand, $pOptions=NULL ) {
	$ret = NULL;
	if( $fullCommand = mailman_get_command( $pCommand ) ) {
		$cmd = $fullCommand.' '.$pOptions;
		exec( $cmd, $ret );
	} else {
		bit_log_error( tra( 'Groups mailman command failed' ).' ('.$pCommand.') '.tra( 'File not found' ).': '.$fullCommand );
	}
	return $ret;
}

function mailman_get_command( $pCommand ) {
	global $gBitSystem;
	$ret = NULL;
	$fullCommand = $gBitSystem->getConfig( 'group_email_mailman_bin' ).'/'.$pCommand;
	$fullCommand = str_replace( '//', '/', $fullCommand );
	if( file_exists( $fullCommand ) ) {
		$ret = $fullCommand;
	}
	return $ret;
}

?>
