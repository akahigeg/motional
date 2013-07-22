# -*- encoding : utf-8 -*-

module MotionAL
  #
  # A collection of assets.
  # Assets belongs to the group.
  #
  class Assets
    attr_reader :group

    # @param group [MotionAL::Group]
    def initialize(group)
      @group = group
    end

    # Create an asset and add it to the group.
    #
    # @param source [CGImage, NSData, NSURL] CGImage and NSData for the photo, NSURL for the video.
    # @param metadata [Hash] Metadata for the photo.
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
    def create(source, metadata = nil, &block)
      Asset.create(source, metadata) do |asset, error|
        if asset
          block.call(asset, error)
          self << asset
        else
          raise "Asset creation failed. #{error}"
        end
      end
    end

    # Find an asset by a specified asset_url.
    #
    # @param asset_url [NSURL]
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
      MotionAL::Asset.find_by_url(asset_url) do |asset, error|
        block.call(asset, error)
      end
    end

    # Find all assets in the group.
    #
    # @param options [Hash]
    # @option options [Symbol] :filter :all, :photo or :video
    # @option options [Symbol] :order :asc or :desc
    # @option options [NSIndexSet] :indexset
    # @return [Array] Found assets.
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
      raise "MotionAL::Assets.all does not support :group option. Use MotionAL::Asset.all to get other group assets." if options[:group]

      options[:group] = @group

      MotionAL::Asset.all(options) do |asset, error|
        block.call(asset, error)
      end
    end

    # @param filter [Symbol] :all, :photo or :video
    # @return [Fixnum] Filtered count of assets in the group. 
    # @example
    #   group.assets.count_by_filter(:photo)
    def count_by_filter(filter = :all)
      AssetsFilter.set(@group, filter)
      filtered_count = @group.al_asset_group.numberOfAssets
      AssetsFilter.reset(@group)

      filtered_count
    end

    # Add an asset to the group.
    # @param asset [MotionAL::Asset]
    def push(asset)
      add_asset_to_group(asset)
      self
    end
    alias_method "<<", :push

    # note: cannot remove ALAsset from ALAssetGroup
    
    private
    def add_asset_to_group(asset)
      @group.al_asset_group.addAsset(asset.al_asset)
    end
  end
end
