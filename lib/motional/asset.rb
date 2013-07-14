# -*- encoding : utf-8 -*-

module MotionAL
  class Asset
    # An instance of ALAsset Class
    attr_reader :al_asset
    @@store = ThreadValueStore

    # @param al_asset [ALAsset]
    def initialize(al_asset)
      @al_asset = al_asset
    end

    # @return [Representations]
    # @note Representations object is an array of Representation object
    def representations
      @representations ||= Representations.new(self)
    end

    # Create
    # @param source [CGImage] # @param source [NSData] image data # @param source [NSURL] video path
    # @note use `MotionAL::Asset.video_compatible?(video_path_url)` before creating video.
    def self.create(source, meta = nil, &block)
      pid = @@store.reserve(:create)
      if block_given?
        if source.kind_of?(NSData)
          self.create_by_image_data(source, meta, pid, block)
        elsif source.kind_of?(NSURL)
          self.create_by_video_path(source, pid, block)
        else
          self.create_by_cg_image(source, meta, pid, block)
        end
      else
        Dispatch.wait_async do
          if source.kind_of?(NSData)
            self.create_by_image_data(source, meta, pid)
          elsif source.kind_of?(NSURL)
            self.create_by_video_path(source, pid)
          else
            self.create_by_cg_image(source, meta, pid)
          end
        end
        created_asset = @@store.get(:create, pid)
        @@store.release(:create, pid)
        return created_asset
      end
    end

    # Find an asset by asset url.
    # @overload self.find_by_url(asset_url, &block)
    #   @param [NSURL] asset_url
    #   @yield [asset, error]
    #   @yieldparam [Asset] asset Found asset or nil(asset did not found). 
    #   @yieldparam [error] error When the asset was found, `error` is nil.
    #   @return [nil] 
    # @overload self.find_by_url(asset_url)
    #   @return [Asset] 
    #   @return [nil] return nil when asset did not found.
    def self.find_by_url(asset_url, &block)
      pid = @@store.reserve(:find_by_url)
      if block_given?
        self.origin_find_by_url(asset_url, pid, block)
      else
        Dispatch.wait_async { self.origin_find_by_url(asset_url, pid) }
        found_asset = @@store.get(:find_by_url, pid)
        @@store.release(:find_by_url, pid)
        return found_asset
      end
    end

    def self.all(options = {}, &block)
      options[:pid] = @@store.reserve(:all, :array)
      if block_given?
        self.origin_all(options, block)
      else
        Dispatch.wait_async { self.origin_all(options) }
        assets = @@store.get(:all, options[:pid])
        @@store.release(:all, options[:pid])
        return assets
      end
    end

    # wrapper method
    def self.video_compatible?(video_path_url)
      MotionAL.library.al_asset_library.videoAtPathIsCompatibleWithSavedPhotosAlbum(video_path_url)
    end

    [:thumbnail, :aspectRatioThumbnail].each do |method_name|
       underscored_method_name = method_name.gsub(/([A-Z])/){|m| "_#{m}" }.downcase
       define_method(underscored_method_name) do 
         self.al_asset_representation.send(method_name)
       end
    end

    # Return true if App haves write access for this asset.
    # @return [Boolean]
    def editable?
      @al_asset.editable?
    end

    def original_asset
      original_al_asset = @al_asset.originalAsset
      Asset.new(original_al_asset) if original_al_asset
    end

    def default_representation
      @default_representation ||= Representation.new(@al_asset.defaultRepresentation)
    end
    alias_method :rep, :default_representation
    alias_method :file, :default_representation
    alias_method :representation, :default_representation

    # wrapper for valurForProperty
    {
      location: ALAssetPropertyLocation,                    # CLLocation
      duration: ALAssetPropertyDuration,                    # NSNumber for video
      date: ALAssetPropertyDate,                            # NSDate
      representation_utis: ALAssetPropertyRepresentations,  # NSArray
      urls: ALAssetPropertyURLs,                            # NSDirectory
      url: ALAssetPropertyAssetURL                          # NSURL
    }.each do |method_name, property_name|
      define_method(method_name) do 
        @al_asset.valueForProperty(property_name)
      end
    end
    alias_method :reps, :representations
    alias_method :files, :representations

    # @return [Symbol]
    def asset_type
      MotionAL.asset_types.key(@al_asset.valueForProperty(ALAssetPropertyType))
    end

    # @return [Symbol]
    def orientation
      MotionAL.asset_orientations.key(@al_asset.valueForProperty(ALAssetPropertyOrientation))
    end

    # through to the default representation's methods
    [:full_resolution_image, :full_screen_image, :scale, :data, :cg_image,
     :dimensions, :filename, :size, :metadata].each do |method_name|
       define_method(method_name) do 
         default_representation.send(method_name)
       end
     end

    # save_new (save to new asset with original asset property)
    # –writeModifiedImageDataToSavedPhotosAlbum:metadata:completionBlock:
    # –writeModifiedVideoAtPathToSavedPhotosAlbum:completionBlock:
    def save_new(source, metadata = nil, &block)
      @created_asset = nil
      if block_given?
        origin_save_new(source, metadata, block)
      else
        Dispatch.wait_async { origin_save_new(source, metadata) }

        return @created_asset
      end
    end

    # update (save to same asset. need editable flag)
    # –setImageData:metadata:completionBlock:
    # –setVideoAtPath:completionBlock:
    #
    # asset.update(image_data, metadata) do |updated_asset, error|
    #   asset = updated_asset
    # end
    #
    # or 
    #
    # asset.update(image_data, metadata)
    #
    def update(source, metadata = nil, &block)
      if block_given?
        origin_update(source, metadata, block)
      else
        Dispatch.wait_async { origin_update(source, metadata) }
      end
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

    def self.origin_find_by_url(asset_url, pid, callback = nil)
      MotionAL.library.al_asset_library.assetForURL(
        asset_url, 
        resultBlock: lambda {|al_asset|
          if al_asset
            found_asset = self.new(al_asset)
            @@store.set(:find_by_url, pid, found_asset) 
            callback.call(found_asset, nil) if callback
          end
        }, 
        failureBlock: lambda {|error|
          callback.call(nil, error) if callback
        }
      )
    end

    # @param options :order, :filter, :group, :indexset
    def self.origin_all(options = {}, callback = nil)
      options[:group] ||= MotionAL.library.saved_photos

      AssetsFilter.set(options[:group], options[:filter]) if options[:filter]
      if options[:indexset]
        options[:group].al_asset_group.enumerateAssetsAtIndexes(
          options[:indexset],
          options: NSEnumerationConcurrent, 
          usingBlock: using_block_for_all(options, callback)
        )
      else
        options[:group].al_asset_group.enumerateAssetsUsingBlock(using_block_for_all(options, callback))
      end
      AssetsFilter.reset(options[:group]) if options[:filter]
    end

    def self.using_block_for_all(options, callback = nil)
      Proc.new do |al_asset, index, stop|
        if !al_asset.nil?
          asset = Asset.new(al_asset)
          if options[:order] && options[:order] == "desc"
            @@store.unshift(:all, options[:pid], asset)
          else
            @@store.push(:all, options[:pid], asset)
          end
          callback.call(asset, nil) if callback
        end
      end
    end

    def self.create_by_image_data(image_data, meta, pid, &block)
      MotionAL.library.al_asset_library.writeImageDataToSavedPhotosAlbum(
        image_data,
        metadata: meta,
        completionBlock: self.completion_block_for_create(pid, block)
      )
    end

    def self.create_by_video_path(video_path_url, pid, &block)
      MotionAL.library.al_asset_library.writeVideoAtPathToSavedPhotosAlbum(
        video_path_url,
        completionBlock: self.completion_block_for_create(pid, block)
      )
    end

    def self.completion_block_for_create(pid, callback = nil)
      Proc.new do |asset_url, error|
        MotionAL::Asset.find_by_url(asset_url) do |asset, error|
          @@store.set(:create, pid, asset)
          callback.call(@@created_asset_store[pid], error) if callback
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
