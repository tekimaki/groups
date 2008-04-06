{strip}

<div class="listing users">
	<div class="header">
		<h1>{tr}Mailing List{/tr}: {$groupInfo.group_name|escape}</h1>
	</div>

	<div class="body">
		{formfeedback success=$successMsg error=$errorMsg}

		{if !$gContent->getPreference( 'group_mailing_list' )}
			{formfeedback warning="No mailing address has been configured for this group."}
			{if $gContent->hasAdminPermission()}
{strip}
{legend legend="Group Mailing List"}
{form}
	<input type="hidden" name="group_id" value="{$gContent->mGroupId}"/>
	<div class="row">
		{formlabel label="Mailing List Address" for='emailhost'}
		{forminput}
			<input type="text" name="group_mailing_list" value="{$smarty.request.group_mailing_list|default:$suggestedListName}" /> <strong> @ {$gBitSystem->getConfig('group_email_host',$gBitSystem->getConfig('kernel_server_name'))} </strong>
			{formhelp note="This is the email address for the group. It needs to be all lowercase alpha-numeric characters."}
		{/forminput}
	</div>
	<div class="row submit">
		{forminput}
			<input type="submit" name="create_list" value="Create List" />
		{/forminput}
	</div>
{/form}
{/legend}
{/strip}
			{/if}
		{/if}

		<ol class="data">
			{foreach from=$groupMembers key=userId item=member}
				<li>{displayname hash=$member}</li>
			{foreachelse}
				<li>{tr}The group has no members.{/tr}</li>
			{/foreach}
		</ol>
	</div><!-- end .body -->
</div>
{/strip}

