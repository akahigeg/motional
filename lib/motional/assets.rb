# -*- encoding : utf-8 -*-

class MotionAL
  # 
  class Assets < Children
    def initialize(group)
      @group = group

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
      if block_given?
        MotionAL::Asset.find_by_url(asset_url) do |asset, error|
          block.call(asset, error)
        end
      else
        MotionAL::Asset.find_by_url(asset_url)
      end
    end

    def all(options = {}, &block)
      options[:group] = @group

      if block_given?
        MotionAL::Asset.all(options) do |asset, error|
          block.call(asset, error)
        end
      else
        MotionAL::Asset.all(options)
      end
    end

    def count(filter_name = AssetsFilter.DEFAULT_FILTER)
      AssetsFilter.set(@group, filter_name)
      filtered_count = @group.al_asset_group.numberOfAssets
      AssetsFilter.reset(@group)

      filtered_count
    end

    # Add an asset to the group.
    # @param asset [MotionAL::Asset]
    def push(asset)
      super
      add_asset_to_group(asset)
      self
    end
    alias_method "<<", :push

    def unshift(asset)
      super
      add_asset_to_group(asset) # TODO: keep sequence of group assets in ALAssetLibrary?
      self
    end

    # note: cannot remove ALAsset from ALAssetGroup
    
    private
    def add_asset_to_group(asset)
      @group.al_asset_group.addAsset(asset.al_asset)
    end
  end
end
