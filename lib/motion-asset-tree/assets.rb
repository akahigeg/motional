# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Assets < Array
    def initialize(group)
      @group = group
      # self.clear
      load_assets

      @current_filter = :all
    end

    def create(image, meta, &block)
      Asset.create(image, meta) do |asset, error|
        block.call(asset, error)
        reload
      end
    end

    def find_by_url(asset_url, &block)
      MotionAssetTree::Asset.find_by_url(asset_url) do |asset, error|
        block.call(asset, error)
      end
    end

    # TODO: support IndexSet
    def all(options = nil, &block)
      if options.nil?
        @group.al_asset_group.enumerateAssetsUsingBlock(
          lambda{|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            block.call(asset, index, stop) 
            unset_filter
          }
        )
      elsif options[:order]
        enum_options = options[:order] == 'asc' ? NSEnumerationConcurrent : NSEnumerationReverse
        @group.al_asset_group.enumerateAssetsWithOptions(
          enum_option, 
          usingBlock: lambda {|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            block.call(asset, index, stop) 
            unset_filter
          }
        )
      elsif options[:indexset]
        @group.al_asset_group.enumerateAssetsAtIndexes(
          options[:indexset],
          options: enum_option, 
          usingBlock: lambda {|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            block.call(asset, index, stop) 
            unset_filter
          }
        )
      end
    end

    def count
      @group.al_asset_group.numberOfAssets
      unset_filter
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

    def load_assets
      self.clear
      self.all do |asset, index, stop|
        if !asset.nil?
          self << asset
        end
      end
    end

    def reload
      load_assets
    end
    
    private
    # filter_name :all, :photo, :video
    def set_filter(filter_name)
      @current_filter = filter_name
      @group.al_asset_group.setAssetsFilter(filters[asset_filter_nane.to_sym])
    end

    def unset_filter
      @group.al_asset_group.setAssetsFilter(asset_filters[:all])
      @current_filter = :all
    end

    def asset_filters
      {
        :all => ALAssetsFilter.allAssets,
        :photo => ALAssetsFilter.allPhotos,
        :video => ALAssetsFilter.allVideos,
      }
    end
  end
end
