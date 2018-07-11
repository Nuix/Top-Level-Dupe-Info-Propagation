# This class collects up annotations and automatically applies those annotations
# when the pending items for a particular annotation reaches a specified threshold.
# This supports a situation where you may want to collect up all results before annotating them
# in one pass, but the full count of results for a given annotation becomes rather large and
# unwieldy causing performance problems.
class BatchingBulkAnnotater
	# Tracks pending tags and the associated items
	# { tag => [items] }
	attr_accessor :pending_tagging

	# Tracks pending custom metadata values
	# {
	#    field_name => { value => [items] }
	# }
	attr_accessor :pending_custom_metadata

	# Number of pending items for a given annotation before
	# they are automatically flushed
	attr_accessor :max_pending

	# Can provide an Nx progress dialog that this will
	# log messages back to
	attr_accessor :progress_dialog

	def initialize
		@max_pending = 5000
		@pending_tagging = Hash.new{|h,tag| h[tag] = [] }
		@pending_custom_metadata = Hash.new{|h,field| h[field] = Hash.new{|h2,value| h2[value] = [] } }
	end

	# Enqueues a tag to be applied against 1 or more items
	# items can be a single item or collection of items
	def enqueue_tag(tag,items)
		items = Array(items)
		pending = @pending_tagging[tag] += items
		flush
	end

	# Enqueues custom metadata to be applied against 1 or more items
	# items can be a single item or collection of items
	def enqueue_cm(field,value,items)
		items = Array(items)
		pending = @pending_custom_metadata[field][value] += items
		flush
	end

	# Logs a message either to an Nx progress dialog (if one was provided) or
	# to standard out via puts
	def log(message)
		if !@progress_dialog.nil?
			@progress_dialog.logMessage(message)
		else
			puts message
		end
	end

	# Checks various annotations buckets and flushes those (by applying their annotation) which
	# have a pending item count greater than or equal to the threshold specified by @max_pending
	def flush
		@pending_tagging.each do |tag,pending_items|
			if pending_items.size >= @max_pending
				log("Applying tag '#{tag}' to #{pending_items.size} items")
				$utilities.getBulkAnnotater.addTag(tag,pending_items)
				@pending_tagging[tag] = []
			end
		end

		@pending_custom_metadata.each do |field_name,value_grouped|
			value_grouped.each do |value,pending_items|
				if pending_items.size >= @max_pending
					log("Applying field '#{field_name}' to #{pending_items.size} items")
					$utilities.getBulkAnnotater.putCustomMetadata(field_name,value,pending_items,nil)
					@pending_custom_metadata[field_name][value] = []
				end	
			end
		end
	end

	# Flushes all pending annotations out to items, good to call this when you're done using this class
	# to make sure anything which did not trigger in a "flush" call gets annotated
	def flush_all
		log("Applying all pending annotations...")
		@pending_tagging.each do |tag,pending_items|
			if pending_items.size >= 1
				log("Applying tag '#{tag}' to #{pending_items.size} items")
				$utilities.getBulkAnnotater.addTag(tag,pending_items)
				@pending_tagging[tag] = []
			end
		end

		@pending_custom_metadata.each do |field_name,value_grouped|
			value_grouped.each do |value,pending_items|
				if pending_items.size >= 1
					log("Applying field '#{field_name}' to #{pending_items.size} items")
					$utilities.getBulkAnnotater.putCustomMetadata(field_name,value,pending_items,nil)
					@pending_custom_metadata[field_name][value] = []
				end	
			end
		end
	end
end