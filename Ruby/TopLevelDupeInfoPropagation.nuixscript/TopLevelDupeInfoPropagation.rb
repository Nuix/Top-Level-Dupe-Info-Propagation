script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.digest.DigestHelper"
java_import "com.nuix.nx.controls.models.Choice"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

load File.join(script_directory,"DupeInfoCache.rb")
load File.join(script_directory,"BatchingBulkAnnotater.rb")

values_choices = [
	"Duplicates Custodian Values",
	"Item and Duplicates Custodian Values",
]

dupe_path_include_self_choices = {
	"Ancestors and Item (ex: /Mailbox.pst/Inbox/Email.msg)" => true,
	"Ancestors Only (ex: /Mailbox.pst/Inbox)" => false,
}

dialog = TabbedCustomDialog.new
dialog.setTitle("Top Level Duplicate Info Propagation")
main_tab = dialog.addTab("main_tab","Main")

if !$current_selected_items.nil? && $current_selected_items.size > 0
	case_top_level_items = $current_case.searchUnsorted("flag:top_level")
	selected_top_level_items = $utilities.getItemUtility.intersection($current_selected_items,case_top_level_items)
	main_tab.appendHeader("Using #{selected_top_level_items.size} selected top level items")
	main_tab.appendCheckBox("pull_in_selection_duplicates","Also Pull in Duplicates of Selected Top Level Items",true)
else
	main_tab.appendHeader("Using #{$current_case.count("flag:top_level")} top level case items")
end
main_tab.appendHeader(" ")

main_tab.appendTextField("dupe_custodians_name","Duplicate Custodians Field","Top Level Duplicate Custodian Set")
main_tab.appendCheckBox("apply_dupe_custodians_tags","Apply Duplicate Custodians Tags",false)
main_tab.appendHeader(" ")

# main_tab.appendCheckBox("propagate_dupe_paths","Propagate Dupe Paths",false)
# main_tab.appendTextField("dupe_paths_name","Dupe Paths Field","Top Level Duplicate Paths")

main_tab.appendCheckableTextField("propagate_dupe_paths",false,"dupe_paths_name","Top Level Duplicate Paths","Propagate Dupe Paths as")
main_tab.appendComboBox("dupe_path_include_self","Duplicate Path Type",dupe_path_include_self_choices.keys)
main_tab.enabledOnlyWhenChecked("dupe_paths_name","propagate_dupe_paths")
main_tab.enabledOnlyWhenChecked("dupe_path_include_self","propagate_dupe_paths")
main_tab.appendHeader(" ")

main_tab.appendCheckBox("only_top_level_dupes","Duplicates Must Also be Top Level",false)
if !$current_selected_items.nil? && $current_selected_items.size > 0
	main_tab.appendCheckBox("only_selected_duplicates","Duplicates Must Also be in Selection",false)
end
main_tab.appendComboBox("dupe_values_type","Duplicate Values Type",values_choices)

dialog.validateBeforeClosing do |values|
	if values["dupe_custodians_name"].empty?
		CommonDialogs.showWarning("Please provide a value for 'Duplicate Custodians Field'")
		next false
	end
	if values["propagate_dupe_paths"] && values["dupe_paths_name"].empty?
		CommonDialogs.showWarning("Please provide a value for 'Duplicate Paths Field'")
		next false
	end
	next true
end

dialog.display
if dialog.getDialogResult == true
	values = dialog.toMap
	batching_annotater = BatchingBulkAnnotater.new

	pull_in_selection_duplicates = values["pull_in_selection_duplicates"]

	only_selected_duplicates = values["only_selected_duplicates"]
	dupe_custodians_name = values["dupe_custodians_name"]

	#Note that dupe paths value generated differs from the profile field of the same
	#name.  The profile field contains the OTHER dupe items paths, this value contains
	#a given item AND its duplicates paths (due to caching use)
	propagate_dupe_paths = values["propagate_dupe_paths"]
	dupe_paths_name = values["dupe_paths_name"]
	dupe_path_include_self = dupe_path_include_self_choices[values["dupe_path_include_self"]]

	#When this is true, while calculating duplicates of top level items, if duplicates
	#are determined to not be top level as well they are ignored.  When false duplicates
	#of top level items are used, regardless of whether the dupes are top level or not.
	only_top_level_dupes = values["only_top_level_dupes"]

	apply_dupe_custodians_tags = values["apply_dupe_custodians_tags"]

	# Work done inside this block will have access to the progress dialog
	ProgressDialog.forBlock do |pd|
		if $window.respond_to?(:closeAllTabs)
			$window.closeAllTabs
		end

		iutil = $utilities.getItemUtility

		batching_annotater.progress_dialog = pd
		pd.setTitle("Top Level Dupe Propagation")
		pd.setSubProgressVisible(false)
		#pd.setLogVisible(false)
		start_time = Time.now
		pd.logMessage("Dupe Custodians Field: #{dupe_custodians_name}")
		pd.logMessage("Dupe Path Field: #{dupe_paths_name}") if propagate_dupe_paths
		pd.logMessage("Dupe Path Type: #{values["dupe_path_include_self"]}")

		items = nil
		if !$current_selected_items.nil? && $current_selected_items.size > 0
			pd.logMessage "Using selected top level items..."
			items = $current_selected_items.select{|i|i.isTopLevel}

			pd.logMessage("Pulling in duplicates of selected top level items...")
			if pull_in_selection_duplicates
				items = iutil.findItemsAndDuplicates(items)
			end
		else
			pd.logMessage "Using all top level items..."
			items =  $current_case.search("flag:top_level")
		end

		pd.logMessage "Top Level Items: #{items.size}"

		include_self = (values["dupe_values_type"] == "Item and Duplicates Custodian Values")
		dupe_custodian_cache = DupeInfoCache.new(only_top_level_dupes,include_self,dupe_path_include_self)

		if only_selected_duplicates && !$current_selected_items.nil? && $current_selected_items.size > 0
			dupe_custodian_cache.duplicate_filter_set = $current_selected_items
		end

		# grouped_by_dupe_custodians = Hash.new{|h,k| h[k] = []}
		# grouped_by_dupe_paths = Hash.new{|h,k| h[k] = []}

		pd.setMainStatus("Determining Top Level Dupe Info...")
		pd.setMainProgress(0,items.size)
		last_progress = Time.now
		items.each_with_index do |item,index|
			break if pd.abortWasRequested
			dupe_custodians = dupe_custodian_cache.get_dupe_custodian_set(item)
			dupe_paths = dupe_custodian_cache.get_dupe_paths(item) if propagate_dupe_paths
			descendants = iutil.findItemsAndDescendants(Array(item))
			
			# Enqueue custom metadata field recording duplicate custodians value
			batching_annotater.enqueue_cm(dupe_custodians_name,dupe_custodians.join("; "),descendants)

			# Enqueue tag for duplicate custodians value, if were applying tags
			if apply_dupe_custodians_tags
				dupe_custodians_joined = dupe_custodians.join("; ")
				if !dupe_custodians_joined.strip.empty?
					tag = "#{dupe_custodians_name}|#{dupe_custodians_joined}"
					batching_annotater.enqueue_tag(tag,descendants)
				end
			end

			# Enqueue custom metadata recording duplicate paths if we're recording them
			if propagate_dupe_paths
				batching_annotater.enqueue_cm(dupe_paths_name,dupe_paths,descendants)
			end
			
			# Periodically show progress updates
			if (Time.now - last_progress) > 1
				pd.logMessage "#{index+1}/#{items.size} : (Cache Hits #{dupe_custodian_cache.cache_hits}/#{index})"
				pd.setMainProgress(index)
				pd.setSubStatus("#{index+1}/#{items.size}")
				last_progress = Time.now
			end
		end

		# Ensure we flush any remaining pending annotations
		batching_annotater.flush_all

		pd.logMessage "#{items.size}/#{items.size} : (Cache Hits #{dupe_custodian_cache.cache_hits}/#{items.size})"
		pd.setMainProgress(items.size)
		pd.setSubStatus("#{items.size}/#{items.size}")

		finish_time = Time.now

		pd.setSubStatus("")
		pd.setMainProgress(1,1)
		if pd.abortWasRequested
			pd.setMainStatusAndLogIt("Aborted, elapsed #{Time.at(finish_time - start_time).gmtime.strftime("%H:%M:%S")}")
		else
			pd.setMainStatusAndLogIt("Completed in #{Time.at(finish_time - start_time).gmtime.strftime("%H:%M:%S")}")
		end

		$window.openTab("workbench",{"search"=>""})
	end
end