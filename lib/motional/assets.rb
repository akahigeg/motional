# -*- encoding : utf-8 -*-

class MotionAL
  class Assets < Children
    DEFAULT_FILTER = :all

    def initialize(group)
      @group = group

      set_filter(DEFAULT_FILTER)
      load_entries
    end

    def create(source, meta, &block)
      if block_given?
        Asset.create(source, meta) do |asset, error|
          block.call(asset, error)
          self << asset
        end
      else
        asset = Asset.create(source, meta)
        self << asset
        asset
      end
    end

    def find_by_url(asset_url, &block)
      MotionAL::Asset.find_by_url(asset_url) do |asset, error|
        block.call(asset, error)
      end
    end

    def all(options = nil, &block)
      if options.nil?
        @group.al_asset_group.enumerateAssetsUsingBlock(
          lambda{|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            block.call(asset, nil) # not use 'index' and 'stop'
            unset_filter
          }
        )
      elsif options[:order]
        enum_options = options[:order] == 'asc' ? NSEnumerationConcurrent : NSEnumerationReverse
        @group.al_asset_group.enumerateAssetsWithOptions(
          enum_option, 
          usingBlock: lambda {|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            block.call(asset, nil) 
            unset_filter
          }
        )
      elsif options[:indexset]
        @group.al_asset_group.enumerateAssetsAtIndexes(
          options[:indexset],
          options: enum_option, 
          usingBlock: lambda {|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            block.call(asset, nil) 
            unset_filter
          }
        )
      end
    end

    def count
      count = @group.al_asset_group.numberOfAssets
      unset_filter

      count
    end

    def filter(filter_name)
      set_filter(filter_name)
      self
    end

    # add
    def push(asset)
      super
      @group.al_asset_group.addAsset(asset.al_asset)
      self
    end
    alias_method "<<", :push

    def unshift(asset)
      super
      @group.al_asset_group.addAsset(asset.al_asset)
      self
    end

    # note: cannot remove ALAsset from ALAssetGroup
    
    private
    # filter_name :all, :photo, :video
    def set_filter(filter_name)
      @current_filter = filter_name
      @group.al_asset_group.setAssetsFilter(asset_filters[filter_name.to_sym])
    end

    def unset_filter
      @current_filter = DEFAULT_FILTER
      @group.al_asset_group.setAssetsFilter(asset_filters[@current_filter])
    end

    def asset_filters
      {
        :all => ALAssetsFilter.allAssets,
        :photo => ALAssetsFilter.allPhotos,
        :video => ALAssetsFilter.allVideos,
      }
    end
  end

  class Photos < Assets
    DEFAULT_FILTER = :photo
  end

  class Videos < Assets
    DEFAULT_FILTER = :video
  end
end
