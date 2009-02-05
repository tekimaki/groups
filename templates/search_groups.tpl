{* $Header: /cvsroot/bitweaver/_bit_groups/templates/search_groups.tpl,v 1.3 2009/02/05 20:49:36 tekimaki_admin Exp $ *}
{strip}
<div class="listing group">
	<div class="header">
		<h1>{if $groupSearchTitle}{tr}Search Group: {$groupSearchTitle}{/tr}{else}{tr}Groups{/tr}{/if}</h1>
	</div>

	<div class="body">

		{form id="list-query-form" legend="Search"}

		{if $smarty.request.search_group_content_id}
			<div class="row">
				{formlabel label="Content Types:" for="content_type_guid"}
				{forminput}
					{html_options options=$contentTypes name=content_type_guid[] id=content_type selected=$contentSelect size=5 multiple=TRUE}
					{formhelp note="Limit search by content type"}
				{/forminput}
			</div>
		{/if}

			<div class="row">
				{formlabel label="Find (key word or phrase):" for="find"}
				{forminput}
					<input type="text" name="find" value="{$find|default:$smarty.request.find|default:$prompt|escape}" {if $prompt}onclick="if (this.value == '{$prompt}') this.value = '';"{/if}/>&nbsp;
					{formhelp note="Searches titles"}
				{/forminput}
			</div>

			{include file="bitpackage:liberty/services_inc.tpl" serviceLocation='search'}

			<div class="row submit">
				{* requires gmap and geo packages - we send search request to gmap to display results on a map *}
				{if $listInfo && $gBitSystem->isPackageActive( 'gmap' ) }
					<div style="float:right">
						<a href="{pageurl listInfo=$listInfo}&amp;display_mode=map" title="View all that have location data">{tr}View Results on a Map{/tr}</a>
					</div>
				{/if}

				<input type="submit" name="search" value="{tr}Search{/tr}"/>
			</div>
		{/form}

		{form id="checkform"}
			<input type="hidden" name="offset" value="{$control.offset|escape}" />
			<input type="hidden" name="sort_mode" value="{$control.sort_mode|escape}" />

			<table class="data">
				<tr>
					{if $gBitSystem->isFeatureActive( 'group_list_group_id' ) eq 'y'}
						<th>{smartlink ititle="Group Id" isort=group_id offset=$control.offset iorder=desc idefault=1 find=$smarty.request.find}</th>
					{/if}

					{if $gBitSystem->isFeatureActive( 'group_list_title' ) eq 'y'}
						<th>{smartlink ititle="Title" isort=title offset=$control.offset find=$smarty.request.find}</th>
					{/if}

					{if $smarty.request.search_group_content_id}
						<th>{smartlink ititle="Content Type" isort=content_type_guid list_page=$listInfo.current_page ihash=$listInfo.ihash}</th>
					{else if $gBitSystem->isFeatureActive( 'group_list_description' ) eq 'y'}
						<th>{smartlink ititle="Description" isort=data offset=$control.offset find=$smarty.request.find}</th>
					{/if}

					{if $gBitSystem->isFeatureActive( 'group_list_data' ) eq 'y'}
						<th>{smartlink ititle="Text" isort=data offset=$control.offset find=$smarty.request.find}</th>
					{/if}

					{if $gBitUser->hasPermission( 'p_group_remove' )}
						<th>{tr}Actions{/tr}</th>
					{/if}
				</tr>

				{foreach item=item from=$contentList}
					<tr class="{cycle values="even,odd"}">
						{if $gBitSystem->isFeatureActive( 'group_list_group_id' )}
							<td>{$item.group_id}</td>
						{/if}

						{if $gBitSystem->isFeatureActive( 'group_list_title' )}
							<td><a href="{$item.display_url}" title="{$item.summary}">{$item.title|escape}</a></td>
						{/if}

						{if $smarty.request.search_group_content_id}
							<td>{assign var=content_type_guid value=`$item.content_type_guid`}{$contentTypes.$content_type_guid}</td>
						{else if $gBitSystem->isFeatureActive( 'group_list_description' )}
							<td>{$item.summary|escape}</td>
						{/if}

						{if $gBitSystem->isFeatureActive( 'group_list_data' )}
							<td>{$item.data|escape}</td>
						{/if}

						{if $gBitUser->hasPermission( 'p_group_remove' )}
							<td class="actionicon">
								{smartlink ititle="Edit" ifile="edit.php" ibiticon="icons/accessories-text-editor" group_id=$item.group_id}
								<input type="checkbox" name="checked[]" title="{$item.title|escape}" value="{$item.group_id}" />
							</td>
						{/if}
					</tr>
				{foreachelse}
					<tr class="norecords"><td colspan="16">
						{tr}No records found{/tr}
					</td></tr>
				{/foreach}
			</table>

			{if $gBitUser->hasPermission( 'p_group_remove' )}
				<div style="text-align:right;">
					<script type="text/javascript">/* <![CDATA[ check / uncheck all */
						document.write("<label for=\"switcher\">{tr}Select All{/tr}</label> ");
						document.write("<input name=\"switcher\" id=\"switcher\" type=\"checkbox\" onclick=\"switchCheckboxes(this.form.id,'checked[]','switcher')\" /><br />");
					/* ]]> */</script>

					<select name="submit_mult" onchange="this.form.submit();">
						<option value="" selected="selected">{tr}with checked{/tr}:</option>
						{if $gBitUser->hasPermission( 'p_group_remove' )}
							<option value="remove_groups">{tr}remove{/tr}</option>
						{/if}
					</select>

					<noscript><div><input type="submit" value="{tr}Submit{/tr}" /></div></noscript>
				</div>
			{/if}
		{/form}

		{pagination}

	</div><!-- end .body -->
</div><!-- end .admin -->
{/strip}
