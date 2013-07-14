# -*- encoding : utf-8 -*-

class MotionAL
  # This is a collection class for assets.
  # Assets belongs to a group.
  class Assets < Children
    # @param group [MotionAL::Group]
    def initialize(group)
      @group = group

      load_entries
    end

    # Create asset and add it to group.
    #
    # @param source [CGImage, NSData, NSURL] CGImage and NSData for the photo, NSURL for the video.
    # @param meta [Hash] for the photo.
    # @return [MotionAL::Asset] A created asset.
    # @return [nil] When block given or fail to create.
    # @example
    #   group.assets.create(data, meta) do |asset, error|
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #   end
    #
    #   asset = group.assets.create(data, meta)
    #   p asset.url.absoluteString
    def create(source, meta = nil, &block)
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

    # Find an asset by asset_url.
    #
    # @param asset_url [NSURL] hoge
    # @return [MotionAL::Asset] A found asset.
    # @return [nil] When block given or fail to find.
    # @example
    #   group.assets.find_by_url(url) do |asset, error|
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #   end
    #
    #   asset = group.assets.find_by_url(url)
    #   p asset.url.absoluteString
    def find_by_url(asset_url, &block)
      if block_given?
        MotionAL::Asset.find_by_url(asset_url) do |asset, error|
          block.call(asset, error)
        end
      else
        MotionAL::Asset.find_by_url(asset_url)
      end
    end

    # Find all assets in the group.
    #
    # @param options [Hash]
    # @option options [Symbol] :filter :all, :photo or :video
    # @option options [Symbol] :order :asc or :desc
    # @option options [NSIndexSet] :indexset
    # @return [MotionAL::Asset] A found asset.
    # @return [nil] When block given or fail to find.
    # @example
    #   group.assets.all do |asset, error|
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #   end
    #
    #   assets = group.assets.all(order: :desc, filter: :photo)
    #   urls  = assets.map {|a| a.url }
    def all(options = {}, &block)
      raise "MotionAL::Assets.all does not support :group option. Use MotionAL::Asset.all" if options[:group]

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
