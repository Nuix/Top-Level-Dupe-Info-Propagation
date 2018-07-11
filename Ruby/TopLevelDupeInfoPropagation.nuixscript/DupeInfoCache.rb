# This class performs the calculation of duplicate custodians and duplicate paths based on its
# configuration, caching results which are reusable when possible (@include_self is true)
class DupeInfoCache
	attr_accessor :cache_hits
	attr_accessor :duplicate_filter_set

	def initialize(only_top_level_dupes=false,include_self=false,dupe_path_include_self=true)
		@only_top_level_dupes = only_top_level_dupes
		@include_self = include_self
		@dupe_path_include_self = dupe_path_include_self
		@custodians_cache = {}
		@paths_cache = {}
		@cache_hits = 0
	end

	# Gets the appropriate items to be used for calculating dupe values based on class configuration
	def get_comparison_items(guid,md5)
		result = nil

		if @include_self
			if @only_top_level_dupes
				result = $current_case.searchUnsorted("md5:#{md5} AND flag:top_level")
			else
				result = $current_case.searchUnsorted("md5:#{md5}")
			end
		else
			if @only_top_level_dupes
				result = $current_case.searchUnsorted("(md5:#{md5} AND flag:top_level) AND -guid:#{guid}")
			else
				result = $current_case.searchUnsorted("md5:#{md5} AND -guid:#{guid}")
			end
		end

		if !@duplicate_filter_set.nil?
			result = $utilities.getItemUtility.intersection(result,@duplicate_filter_set)
		end

		return result
	end

	# Generates duplicate custodians value and/or uses cached previously calculated value
	def get_dupe_custodian_set(item)
		md5 = item.getDigests.getMd5
		if md5.nil? || md5.strip.empty?
			custodian = item.getCustodian || ""
			return [custodian]
		else
			dupe_custodian_set = @custodians_cache[md5]
			if dupe_custodian_set.nil?
				item_dupes = get_comparison_items(item.getGuid,md5)
				dupe_custodian_set = item_dupes.map{|i|i.getCustodian}.reject{|i|i.nil?}.uniq.sort
				if @include_self
					@custodians_cache[md5] = dupe_custodian_set
				end
			else
				@cache_hits += 1
			end
			return dupe_custodian_set
		end
	end

	# Generates an item path value for an item based on how the class is configured
	def get_item_path(item)
		if @dupe_path_include_self == true
			return item.getLocalisedPathNames.join("/")
		else
			# need to_a because underlying Java collection is more touchy
			# when the [0..-2] when collection only has 1 or fewer entries
			# where as Ruby array implementation seems to handle this just fine
			return item.getLocalisedPathNames.to_a[0..-2].join("/")
		end
	end

	# Generates duplicate paths value and/or uses cached previously calculated value
	def get_dupe_paths(item)
		md5 = item.getDigests.getMd5
		if md5.nil? || md5.strip.empty?
			return get_item_path(item)
		else
			dupe_paths = @paths_cache[md5]
			if dupe_paths.nil?
				item_dupes = get_comparison_items(item.getGuid,md5)
				dupe_paths = item_dupes.map{|i|get_item_path(i)}.reject{|p|p.nil? || p.strip.empty?}.uniq.sort.join("; ")
				if @include_self
					@paths_cache[md5] = dupe_paths
				end
			else
				@cache_hits += 1
			end
			return dupe_paths
		end
	end
end