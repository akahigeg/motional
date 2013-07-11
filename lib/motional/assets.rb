# -*- encoding : utf-8 -*-

class MotionAL
  class Assets < Children
    DEFAULT_FILTER = :all

    def initialize(group)
      @group = group

      set_filter(DEFAULT_FILTER)
      load_entries({:filter => @current_filter})
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
      options[:filter] = @current_filter

      if block_given?
        MotionAL::Asset.all(options) do |asset, error|
          block.call(asset, error)
          unset_filter
        end
      else
        MotionAL::Asset.all(options)
        unset_filter
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
      add_asset_to_group(asset)
      self
    end
    alias_method "<<", :push

    def unshift(asset)
      super
      add_asset_to_group(asset)
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

    def add_asset_to_group(asset)
      @group.al_asset_group.addAsset(asset.al_asset)
    end
  end
end
