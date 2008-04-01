<?php
// $Header: /cvsroot/bitweaver/_bit_groups/edit.php,v 1.24 2008/04/01 13:43:29 wjames5 Exp $
// Copyright (c) 2004 bitweaver Group
// All Rights Reserved. See copyright.txt for details and a complete list of authors.
// Licensed under the GNU LESSER GENERAL PUBLIC LICENSE. See license.txt for details.

// Initialization
require_once( '../bit_setup_inc.php' );

// Is package installed and enabled
$gBitSystem->verifyPackage( 'group' );

require_once(GROUP_PKG_PATH.'lookup_group_inc.php' );

// must be owner or admin to edit an existing group 
if( $gContent->isValid() ) {
	$gContent->verifyEditPermission();

	// if it has a custom theme lets theme it
	$gContent->setGroupStyle();
} else {
	$gBitSystem->verifyPermission( 'p_group_edit' );
}

// get content types groups can associate with their group
$exclude = array( 'bitboard', 'bitgroup', 'bitcomment' );
$formGroupContent = array();
foreach( $gLibertySystem->mContentTypes as $cType ) {
    if( !in_array( $cType['content_type_guid'], $exclude ) && $gBitSystem->getConfig( 'group_content_'.$cType['content_type_guid'] ) ) {
		$formGroupContent['guids'][$cType['content_type_guid']]  = $cType['content_description'];
    }
}

// If we are in preview mode then preview it!
if( isset( $_REQUEST["preview"] ) ) {
    $gContent->preparePreview( $_REQUEST );
	$gBitSmarty->assign('preview', 'y');
	$gContent->invokeServices('content_preview_function');
}else {
  	$gContent->invokeServices( 'content_edit_function' );
}

// Get all rolls - used in access control options
$groupRoles = $gContent->getRoles();
$gBitSmarty->assign('groupRoles', $groupRoles );

// Get all perms - used in access control options
$allRolesPerms = $gContent->getRolesPerms();
$gBitSmarty->assign('allRolesPerms', $allRolesPerms );

// If we are saving
if( !empty( $_REQUEST["save_group"] ) ) {

	// get the current public status of the group before we save. we need this later for setting access control
	$publicStatus = isset( $gContent->mInfo['view_content_public'] )?$gContent->mInfo['view_content_public']:NULL;

	// Check if all Request values are delivered, and if not, set them
	// to avoid error messages. This can happen if some features are
	// disabled
	if( $gContent->store( $_REQUEST['group'] ) ) {

		// if that went ok store role permissions for the group
		foreach( array_keys( $groupRoles ) as $roleId ) {
			if ( $roleId == 1 ) {
				// TODO: This could be made a LOT more efficient with one query.
				foreach( array_keys( $allRolesPerms ) as $perm ) {
					// Assign all permissions to admins.
					$gContent->assignPermissionToRole($perm, $roleId);
				}
			}
			else {
				foreach( array_keys( $allRolesPerms ) as $perm ) {
					if( !empty( $_REQUEST['group']['perms'][$roleId][$perm] )) {
						$gContent->assignPermissionToRole( $perm, $roleId);
					} else {
						$gContent->removePermissionFromRole( $perm, $roleId);
					}
				}
			}
		}

		// store content types group can create
		$groupContentTypes = array_keys( $formGroupContent['guids'] );
		// we check the full list so that if the admin options changed we automagically clean up the group
		foreach( $gLibertySystem->mContentTypes as $cType ) {
			$type = $cType['content_type_guid'];
			if ( !empty( $_REQUEST['group_content'] ) && in_array( $type, $_REQUEST['group_content'] ) && in_array( $type, $groupContentTypes ) ) {
				$gContent->storeContentTypePref( $type );
			}else{
				$gContent->expungeContentTypePref( $type );
			}
		}
		// make sure the list is up to date after storing any prefs
		$gContent->mContentTypePrefs = $gContent->getContentTypePrefs();


		//------ set access permissions for the group and group related content ------//

		/* we only do this if the is_public status has changed,
		 * otherwise we will screw up access on any content that has been made public in private groups
		 * and we'll be setting custom perms over and over needlessly
		 */

		if ( $gContent->mInfo['view_content_public'] != $publicStatus ){
			// get list of user groups and their perms
			$allGroups = $gBitUser->getAllGroups();
			// set view perms for our group
			foreach( $allGroups as $groupId => $group ){
				$groupPerms = array_keys( $group['perms'] );
				if ( $groupId != 1 && $groupId != $gContent->mGroupId && in_array( $gContent->mViewContentPerm, $groupPerms ) ){
					if ( $gContent->mInfo['view_content_public'] != 'y' ){
						// revoke
						$gContent->storePermission( $groupId, $gContent->mViewContentPerm, TRUE );
					}else{
						// unrevoke if revoked
						$gContent->removePermission( $groupId, $gContent->mViewContentPerm );
					}
				}
			}
			
			// assign a custom perm for our group if private else remove it if not needed
			if ( $gContent->mInfo['view_content_public'] != 'y' ){
				// assign custom view perm for our group
				$gContent->storePermission( $gContent->mGroupId, $gContent->mViewContentPerm );
			}else{
				// remove custom view perm for our group since its not needed
				$gContent->removePermission( $gContent->mGroupId, $gContent->mViewContentPerm );
			}
				
			// assign custom view perms for our group's linked content
			// we need this to get all view perms
			require_once(  LIBERTYSECURE_PKG_PATH.'libertysecure_lib.php' );
			// get all group linked content
			$listHash = array( "connect_group_content_id" => $gContent->mContentId );
			$list = $gContent->getContentList( $listHash );
			// for each content item set custom view perms
			foreach( $list['data'] as $content ){
				$typeGuid = $content['content_type_guid'];
				$contentId = $content['content_id'];
				if ( !isset( $gLibertySystem->mContentTypes[$typeGuid]['content_perms'] ) ){
					$gLibertySystem->mContentTypes[$typeGuid]['content_perms'] = secure_get_content_permissions( $typeGuid );
				}
				if ( isset( $gLibertySystem->mContentTypes[$typeGuid]['content_perms']['view'] ) ){
					$viewPerm =  $gLibertySystem->mContentTypes[$typeGuid]['content_perms']['view'];
					// foreach user group
					foreach( $allGroups as $groupId => $group ){
						$groupPerms = array_keys( $group['perms'] );
						// if group has content view perm by default and is not admin and not our group
						if ( $groupId != 1 && $groupId != $gContent->mGroupId  && in_array( $viewPerm, $groupPerms ) ){
							if ( $gContent->mInfo['view_content_public'] != 'y' ){
								// revoke
								$gContent->storePermission( $groupId, $viewPerm, TRUE, $contentId);
							}else{
								// unrevoke if revoked
								$gContent->removePermission( $groupId, $viewPerm, $contentId );
							}
						}
					}
					
					// set custom perm for our group
					if ( $gContent->mInfo['view_content_public'] != 'y' ){
						// assign view to our group 
						$gContent->storePermission( $gContent->mGroupId, $viewPerm, FALSE, $contentId );
					}else{
						// remove custom view perm for our group since its not needed
						$gContent->removePermission( $gContent->mGroupId, $viewPerm, $contentId );
					}
				}
			}
		}
		//----- end set access perms -----//

		header( "Location: ".$gContent->getDisplayUrl() );
		die;
	} else {
		$gBitSmarty->assign_by_ref( 'errors', $gContent->mErrors );
	}
}

/* Check which content types this group allows
 * we ask for a fresh list since it might have changed
 */
$formGroupContent['checked'] = $gContent->getContentTypePrefs();
$gBitSmarty->assign( 'formGroupContent', $formGroupContent );

// get options hash
require_once(GROUP_PKG_PATH.'options_inc.php'); 

// Display the template
$gBitSystem->display( 'bitpackage:group/edit_group.tpl', tra('Group') );
?>
