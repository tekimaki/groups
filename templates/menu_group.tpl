{strip}
	<ul>
		{if $gBitUser->hasPermission( 'p_group_view')}
			<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}index.php">{tr}Groups Home{/tr}</a></li>
		{/if}
		{if $gBitUser->hasPermission( 'p_group_view')  || $gBitUser->hasPermission( 'p_group_remove' ) }
			<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}list_groups.php">{tr}List Groups{/tr}</a></li>
		{/if}
		{if $gBitUser->hasPermission( 'p_group_edit' ) }
			<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}edit.php">{tr}Create Group{/tr}</a></li>
		{/if}
		{if $gContent->mGroupId && $gContent->hasUserPermission( 'p_group_view', TRUE, TRUE)}
			<li><hr/><h3>{$gContent->getTitle()}</h3></li>
			<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}index.php?group_id={$gContent->mGroupId}">{tr}Home{/tr}</a></li>
			<li><a class="item" href="{$smarty.const.BOARDS_PKG_URL}index.php?b={$board_id}" title="post messages">{tr}Forum{/tr}</a></li>
			<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}members.php?group_id={$gContent->mGroupId}" title="view group members">{tr}Members{/tr}</a></li>

			{if $allowedContentTypes}
			<li><a class="item">{tr}Content{/tr}</a>
				<ul style="margin-left:10px">
					{foreach item=name key=type from=$allowedContentTypes}
					<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}index.php?group_id={$gContent->mGroupId}&content_type={$type}">{$name}s</a></li>
					{/foreach}
				</ul>
			</li>
			{/if}

			<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}files.php?group_id={$gContent->mGroupId}" title="view attachments">{tr}Files{/tr}</a></li>
			<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}about.php?group_id={$gContent->mGroupId}">{tr}About this group{/tr}</a></li>
			<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}join.php?group_id={$gContent->mGroupId}">{if !$gBitUser->isInGroup( $gContent->mGroupId )}{tr}Join this group{/tr}{else}{tr}Edit my membership{/tr}{/if}</a></li>
			{if $gBitUser->isAdmin() }
				<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}manage.php?group_id={$gContent->mGroupId}" title="assign roles">{tr}Manage members{/tr}</a></li>
			{/if}
			{if $gBitUser->isAdmin() }
				<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}invite_members.php?group_id={$gContent->mGroupId}">{tr}Invite members{/tr}</a></li>
			{/if}
			{if $gBitUser->isAdmin() || $gBitUser->hasPermission( 'p_group_edit' ) }
				<li><a class="item" href="{$smarty.const.GROUP_PKG_URL}edit.php?group_id={$gContent->mGroupId}">{tr}Group settings{/tr}</a></li>
			{/if}
		{/if}
	</ul>
{/strip}
