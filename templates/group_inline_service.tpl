{strip}
{if $smarty.const.ACTIVE_PACKAGE != 'group' && $smarty.const.ACTIVE_PACKAGE != 'boards'}
<div class="group-permalink">
	{if $contentMemberGroups} 
		<strong>{tr}In Group{if count($contentMemberGroups) > 1 }s{/if}{/tr}:</strong>&nbsp;
	{foreach from=$contentMemberGroups item=group}
		<a href="{$group.group_home}">{$group.group_name}</a>&nbsp;
	{/foreach}
{/if}
{if is_object($gContent) && $gContent->hasUserPermission('p_groups_view') && $gContent->hasUpdatePermission() && (!$gBitSystem->isFeatureActive('group_admin_content') || (isset($contentMemberGroups) && count($contentMemberGroups)==0))}
	<a href="{$smarty.const.GROUP_PKG_URL}add_to_group.php?submit_content_id={$gContent->mContentId}">{tr}Submit to a Group{/tr}</a>
{/if}
</div>
{/if}
{/strip}
