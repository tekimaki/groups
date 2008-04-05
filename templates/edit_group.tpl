{* $Header: /cvsroot/bitweaver/_bit_groups/templates/edit_group.tpl,v 1.9 2008/04/05 23:27:07 spiderr Exp $ *}
{strip}
<div class="floaticon">{bithelp}</div>

<div class="admin group">
	{if $preview}
		<h2>Preview {$gContent->mInfo.title|escape}</h2>
		<div class="preview">
			{include file="bitpackage:group/group_about.tpl" page=`$gContent->mInfo.group_id`}
		</div>
	{/if}

	<div class="header">
		<h1>
			{if $gContent->mInfo.group_id}
				{tr}{tr}Edit{/tr} {$gContent->mInfo.title|escape}{/tr}
			{else}
				{tr}Create New Group{/tr}
			{/if}
		</h1>
	</div>

 	{if $errors}
 		{formfeedback warning=`$errors`}
 	{/if}


	<div class="body">
		{form enctype="multipart/form-data" id="editgroupform"}
			{jstabs}
				{jstab title="Group Information"}
					{legend legend="Group Information"}
						<input type="hidden" name="group[group_id]" value="{$gContent->mInfo.group_id}" />

						<div class="row">
							{formlabel label="Title" for="title"}
							{forminput}
								<input type="text" size="60" maxlength="200" name="group[title]" id="title" value="{$gContent->mInfo.title|escape}" />
							{/forminput}
						</div>

						<div class="row">
							{formlabel label="Short Description (Optional)" for="summary"}
							{forminput}
								<input size="60" type="text" name="group[summary]" id="summary" value="{$gContent->mInfo.summary|escape}" />
								{formhelp note="A brief description of Group. This is used in group listings. If left blank a truncated version of the Long Description will be autogenerated."}
							{/forminput}
						</div>

						{textarea name="group[edit]" label="Long Description" help="The description of the group or other group message. By default this appears at the top of your group home page"}{$gContent->mInfo.data}{/textarea}
						{textarea name="group[after_registration]" noformat=true help="The message shown after a user registers. If none is provided then the user will be sent to the group directly." id="after_reg" label="After Registration Message"}{$gContent->mInfo.after_registration}{/textarea}

						{* any simple service edit options *}
						{include file="bitpackage:liberty/edit_services_inc.tpl serviceFile=content_edit_mini_tpl}

						<div class="row submit">
							<input type="submit" name="preview" value="{tr}Preview{/tr}" /> 
							<input type="submit" name="save_group" value="{tr}Save{/tr}" />
						</div>
					{/legend}
				{/jstab}

				{jstab title="Group Options"}
					{include file="bitpackage:group/edit_group_options.tpl"}
				{/jstab}

				{jstab title="Group Administration"}
					{include file="bitpackage:group/edit_group_admin.tpl"}
				{/jstab}

			{if $gBitSystem->isFeatureActive('group_email_list')}
				{jstab title="Group Email List"}
					{include file="bitpackage:group/edit_group_email_list.tpl"}
				{/jstab}
			{/if}

				{* any service edit template tabs *}
				{include file="bitpackage:liberty/edit_services_inc.tpl serviceFile=content_edit_tab_tpl}
			{/jstabs}
		{/form}
	</div><!-- end .body -->
</div><!-- end .group -->

{/strip}
