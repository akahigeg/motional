# -*- encoding : utf-8 -*-

module MotionAL
  #
  # A wrapper of ALAsset class.
  #
  #   An ALAsset object represents a photo or a video managed by the Photo application.
  #   Assets can have multiple representations, for example a photo which was captured in RAW and JPG. Different representations of the same asset may have different dimensions.
  #
  # And added some convinience methods.
  #
  class Asset
    # An instance of ALAsset.
    attr_reader :al_asset

    # @param al_asset [ALAsset]
    def initialize(al_asset)
      @al_asset = al_asset
    end

    # @return [MotionAL::Representations] The collection of representations in the asset.
    def representations
      @representations ||= Representations.new(self)
    end

    # Create an asset.
    #
    # @param source [CGImage, NSData, NSURL] CGImage and NSData for the photo, NSURL for the video.
    # @param metadata [Hash] Metadata for the photo.
    # @return [nil]
    #
    # @yield [asset, error]
    # @yieldparam asset [MotionAL::Asset] A created asset.
    # @yieldparam error [error]
    #
    # @note use `MotionAL::Asset.video_compatible?(video_path_url)` before creating video.
    #
    # @example
    #   MotionAL::Asset.create(data, meta) do |asset, error|
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #   end
    #
    #   MotionAL::Asset.create(data, meta)
    #
    #   if MotionAL::Asset.video_compatible?(video_path_url)
    #     MotionAL::Asset.create(data, meta)
    #   else
    #     p "This video contained incompatible data."
    #   end
    def self.create(source, metadata = nil, &block)
      if source.kind_of?(NSData)
        self.create_by_image_data(source, metadata, block)
      elsif source.kind_of?(NSURL)
        self.create_by_video_path(source, block)
      else
        self.create_by_cg_image(source, metadata, block)
      end
    end

    # Find an asset by a specified asset_url.
    #
    # @param asset_url [NSURL]
    # @return [nil]
    #
    # @yield [asset, error]
    # @yieldparam asset [MotionAL::Asset] A found asset.
    # @yieldparam error [error]
    #
    # @example
    #   MotionAL::Asset.find_by_url(url) do |asset, error|
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #   end
    def self.find_by_url(asset_url, &block)
      url = asset_url.is_a?(String) ? NSURL.alloc.initWithString(asset_url) : asset_url
      self.origin_find_by_url(url, block)
    end

    # Find and enumerate assets by options.
    #
    # @param options [Hash]
    # @option options [MotionAL::Group] :group Default is the Camera Roll.
    # @option options [Symbol] :filter :all, :photo or :video
    # @option options [Symbol] :order :asc or :desc
    # @option options [NSIndexSet] :indexset
    # @return [nil]
    #
    # @yield [asset, error]
    # @yieldparam asset [MotionAL::Asset] A found asset.
    # @yieldparam error [error]
    #
    # @example
    #   MotionAL::Asset.find_all do |asset, error|
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #   end
    #
    #   MotionAL::find_by_name('MyAppAlbum') do |group|
    #     MotionAL::Asset.find_all(group: group, order: :desc, filter: :photo) do |asset|
    #       p asset.url.absoluteString
    #     end
    #   end
    #
    #   indexset = NSMutableIndexSet.indexSetWithIndexesInRange(1..3)
    #   MotionAL::Asset.find_all(indexset: indexset, order: :desc) do |asset|
    #     p asset.url.absoluteString
    #   end
    def self.find_all(options = {}, &block)
      self.origin_find_all(options, block)
    end
    class << self
      alias_method :each, :find_all
    end

    # @return [Boolean] false means ALAssetLibrary cannot treat the video file.
    def self.video_compatible?(video_path_url)
      MotionAL.library.al_asset_library.videoAtPathIsCompatibleWithSavedPhotosAlbum(video_path_url)
    end


    # @return [CGImageRef] Returns a thumbnail of the asset.
    def thumbnail
      self.al_asset.thumbnail
    end

    # @return [CGImageRef] Returns an aspect ratio thumbnail of the asset.
    def aspect_ratio_thumbnail
      self.al_asset.aspectRatioThumbnail
    end

    # Return true if the app haves write access for the asset.
    # In other words true means the app can call `#update` for the asset.
    #
    # @return [Boolean]
    def editable?
      @al_asset.editable?
    end

    # The original version of the asset.
    #
    # @return [MotionAL::Asset]
    # @return [nil] The asset has no original asset.
    #
    # @note The original asset was set when the asset was created by `#save_new`
    def original_asset
      original_al_asset = @al_asset.originalAsset
      Asset.new(original_al_asset) if original_al_asset
    end

    # @return [MotionAL::Representation] The default representation of the asset. A representation is an actual file.
    def default_representation
      @default_representation ||= Representation.new(@asset, @al_asset.defaultRepresentation)
    end
    alias_method :rep, :default_representation
    alias_method :file, :default_representation
    alias_method :representation, :default_representation

    # wrapper for valueForProperty
    class << self
      private
      # @!macro [attach] make_wrapper
      #   The asset's $1
      #   @method $1
      #   @return [$3] The value for the property $2.
      #   @return [nil] The property is empty.
      def make_wrapper_for_property(method_name, property_name, type_of_return)
        define_method(method_name) do 
          @al_asset.valueForProperty(property_name)
        end
      end
    end
    make_wrapper_for_property(:location, ALAssetPropertyLocation, "CLLocation")
    make_wrapper_for_property(:duration, ALAssetPropertyDuration, "Float")
    make_wrapper_for_property(:date, ALAssetPropertyDate, "Time")
    make_wrapper_for_property(:url, ALAssetPropertyAssetURL, "NSURL")
    make_wrapper_for_property(:representation_utis, ALAssetPropertyRepresentations, "Array")
    make_wrapper_for_property(:representation_urls, ALAssetPropertyURLs, "Array")

    alias_method :reps, :representations
    alias_method :files, :representations

    # The type of the asset.
    #
    # @return [Symbol] :photo or :video
    def asset_type
      MotionAL.asset_types.key(@al_asset.valueForProperty(ALAssetPropertyType))
    end

    # The orientation of the asset.
    #
    # @return [Symbol] :up, :down :left, :right, :up_mirrored, :down_mirrored, :left_mirrored or :right_mirrored
    def orientation
      MotionAL.asset_orientations.key(@al_asset.valueForProperty(ALAssetPropertyOrientation))
    end

    class << self
      private
      # wrapper for representation method
      # @!macro [attach] make_wrapper
      #   The default representation's $1
      #   @method $1
      #   @return [$2] The same as the default representation's $1
      #   @return [nil] The property is empty.
      def make_wrapper_for_representation_method(method_name, type_of_return)
        define_method(method_name) do 
          default_representation.send(method_name)
        end
      end
    end
    make_wrapper_for_representation_method(:full_resolution_image, "CGImageRef")
    make_wrapper_for_representation_method(:full_screen_image, "CGImageRef")
    make_wrapper_for_representation_method(:scale, "Float")
    make_wrapper_for_representation_method(:data, "NSConcreteData")
    make_wrapper_for_representation_method(:cg_image, "CGImageRef")
    make_wrapper_for_representation_method(:dimensions, "CGSize")
    make_wrapper_for_representation_method(:filename, "String")
    make_wrapper_for_representation_method(:size, "Fixnum")
    make_wrapper_for_representation_method(:metadata, "Hash")

    # Create a new asset forked by the asset.
    #
    # @param source [NSData, NSURL] NSData for the photo, NSURL for the video.
    # @param metadata [Hash] Metadata for the photo.
    # @return [nil]
    #
    # @yield [asset, error]
    # @yieldparam asset [MotionAL::Asset] A created asset.
    # @yieldparam error [error]
    #
    # @note use `MotionAL::Asset.video_compatible?(video_path_url)` before creating video.
    #
    # @example
    #   asset_a.save_new(imagedata, meta) do |asset, error| do
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #     p asset.original_asset.url.absoluteString 
    #   end
    #
    #   asset_a.create(imagedata, meta)
    def save_new(source, metadata = nil, &block)
      origin_save_new(source, metadata, block)
    end

    # Update the asset.
    # In other words replacing the asset's representation.
    #
    # @param source [NSData, NSURL] NSData for the photo, NSURL for the video.
    # @param metadata [Hash] Metadata for the photo.
    # @return [nil]
    #
    # @yield [asset, error]
    # @yieldparam asset [MotionAL::Asset] A updated asset.
    # @yieldparam error [error]
    #
    # @note use `MotionAL::Asset.video_compatible?(video_path_url)` before updating video.
    #
    # @example
    #   asset_a.update(imagedata, meta) do |asset, error| do
    #     # asynchronous if a block given
    #     p asset.url.absoluteString
    #   end
    #
    #   asset_a.update(imagedata, meta)
    def update(source, metadata = nil, &block)
      origin_update(source, metadata, block)
    end

    private
    def self.create_by_cg_image(cg_image, meta, callback = nil)
      if self.only_orientation?(meta)
        MotionAL.library.al_asset_library.writeImageToSavedPhotosAlbum(
          cg_image,
          orientation: MotionAL.asset_orientations[meta[:orientation]],
          completionBlock: self.completion_block_for_create(callback)
        )
      else
        MotionAL.library.al_asset_library.writeImageToSavedPhotosAlbum(
          cg_image,
          metadata: meta,
          completionBlock: self.completion_block_for_create(callback)
        )
      end
    end

    def self.only_orientation?(meta)
      meta && meta.size == 1 && meta[:orientation]
    end

    def self.origin_find_by_url(asset_url, callback = nil)

      MotionAL.library.al_asset_library.assetForURL(
        asset_url, 
        resultBlock: lambda {|al_asset|
          if al_asset
            found_asset = self.new(al_asset)
            callback.call(found_asset, nil) if callback
          end
        }, 
        failureBlock: lambda {|error|
          callback.call(nil, error) if callback
        }
      )
    end

    def self.origin_find_all(options = {}, callback = nil)
      if options[:group]
        group_name = options[:group].name
      else
        group_name = /Camera Roll|Saved Photos/
      end
      options[:order] ||= :asc

      MotionAL::Group.find_by_name(group_name) do |group, error|
        order = MotionAL.enum_orders[options[:order]]
        AssetsFilter.set(group, options[:filter]) if options[:filter]
        if options[:indexset]
          group.al_asset_group.enumerateAssetsAtIndexes(
            options[:indexset],
            options: order, 
            usingBlock: using_block_for_all(options, callback)
          )
        elsif options[:order] == :desc
          group.al_asset_group.enumerateAssetsWithOptions(order, usingBlock: using_block_for_all(options, callback))
        else
          group.al_asset_group.enumerateAssetsUsingBlock(using_block_for_all(options, callback))
        end
        AssetsFilter.reset(group) if options[:filter]
      end
    end

    def self.using_block_for_all(options, callback = nil)
      Proc.new do |al_asset, index, stop|
        if !al_asset.nil?
          asset = Asset.new(al_asset)
          callback.call(asset, nil) if callback
        end
      end
    end

    def self.create_by_image_data(image_data, meta, callback = nil)
      MotionAL.library.al_asset_library.writeImageDataToSavedPhotosAlbum(
        image_data,
        metadata: meta,
        completionBlock: self.completion_block_for_create(callback)
      )
    end

    def self.create_by_video_path(video_path_url, callback = nil)
      MotionAL.library.al_asset_library.writeVideoAtPathToSavedPhotosAlbum(
        video_path_url,
        completionBlock: self.completion_block_for_create(callback)
      )
    end

    def self.completion_block_for_create(callback = nil)
      Proc.new do |asset_url, error|
        MotionAL::Asset.find_by_url(asset_url) do |asset, error|
          callback.call(asset, error) if callback
        end
      end
    end

    def completion_block_for_save_and_update(callback = nil)
      Proc.new do |asset_url, error|
        MotionAL::Asset.find_by_url(asset_url) do |asset, error|
          @created_asset = asset
          callback.call(@created_asset, error) if callback
        end
      end
    end

    def origin_save_new(source, metadata, callback = nil) 
      case self.asset_type
      when :photo
        save_new_by_image_data(source, metadata) {|asset, error| callback.call(asset, error) if callback }
      when :video
        save_new_by_video_path(source) {|asset, error| callback.call(asset, error) if callback }
      else
        raise "ALAssetTypeUnknown"
      end
    end

    def save_new_by_image_data(image_data, metadata, &block)
      @al_asset.writeModifiedImageDataToSavedPhotosAlbum(
        image_data, 
        metadata: metadata,
        completionBlock: completion_block_for_save_and_update(block)
      )
    end

    def save_new_by_video_path(video_path, &block)
      @al_asset.writeModifiedVideoAtPathToSavedPhotosAlbum(
        video_path,
        completionBlock: completion_block_for_save_and_update(block)
      )
    end

    def origin_update(source, metadata = nil, callback = nil)
      case self.asset_type
      when :photo
        update_by_image_data(source, metadata) {|asset, error| callback.call(asset, error) if callback }
      when :video
        update_by_video_path(source) {|asset, error| callback.call(asset, error) if callback}
      else
        raise "ALAssetTypeUnknown"
      end
    end

    def update_by_image_data(image_data, metadata, &block)
      @al_asset.setImageData(
        image_data, 
        metadata: metadata,
        completionBlock: completion_block_for_save_and_update(block)
      )
    end

    def update_by_video_path(video_path, &block)
      @al_asset.setVideoAtPath(
        video_path,
        completionBlock: completion_block_for_save_and_update(block)
      )
    end

  end
end
