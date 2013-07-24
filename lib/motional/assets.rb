# -*- encoding : utf-8 -*-

module MotionAL
  #
  # A collection of assets in the group.
  # Assets has to belong to the group.
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
    # @return [nil]
    #
    # @yield [asset, error]
    # @yieldparam asset [MotionAL::Asset] A created asset.
    # @yieldparam error [error]
    #
    # @example
    #   group.assets.create(data, meta) do |asset, error|
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #   end
    #
    #   group.assets.create(data, meta)
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

    # Enumrate assets in the group.
    #
    # @param options [Hash]
    # @option options [Symbol] :filter :all(default), :photo or :video
    # @option options [Symbol] :order :asc(default) or :desc
    # @option options [NSIndexSet] :indexset
    # @return [nil]
    #
    # @yield [asset, error]
    # @yieldparam asset [MotionAL::Asset] A found asset.
    # @yieldparam error [error]
    #
    # @example
    #   group.assets.each do |asset, error|
    #     # asynchronous
    #     p asset.url.absoluteString
    #   end
    def each(options = {}, &block)
      raise "MotionAL::Assets.each does not support :group option. Use MotionAL::Asset.find_all to get other group assets." if options[:group]

      options[:group] = @group

      MotionAL::Asset.find_all(options) do |asset, error|
        block.call(asset, error)
      end
    end
    alias_method :find_all, :each

    # @param filter [Symbol] :all(default), :photo or :video
    # @return [Fixnum] Count of assets in the group. 
    #
    # @example
    #   group.assets.count
    #   group.assets.count(:photo)
    def count(filter = :all)
      AssetsFilter.set(@group, filter)
      filtered_count = @group.al_asset_group.numberOfAssets
      AssetsFilter.reset(@group)

      filtered_count
    end

    # Add an asset to the group.
    #
    # @param asset [MotionAL::Asset]
    def push(asset)
      @group.add_asset(asset)
      self
    end
    alias_method "<<", :push
  end
end
