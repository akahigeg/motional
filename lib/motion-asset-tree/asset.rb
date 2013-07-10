# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Asset
    attr_accessor :al_asset

    def initialize(al_asset)
      @al_asset = al_asset
    end

    def representations
      @representations ||= Representations.new(self)
    end

    def self.asset_types
      {
        :photo => ALAssetTypePhoto,
        :video => ALAssetTypeVideo,
        :unknown => ALAssetTypeUnknown
      }
    end

    # @param source => CGImage or NSData or NSURL(video)
    def self.create(source, meta = nil, &block)
      @created_asset = nil
      if block_given?
        self.create_by_cg_image(source, meta, block)
      else
        Dispatch.wait_async { self.create_by_cg_image(source, meta) }
        return @created_asset
      end
    end

    def self.find_by_url(asset_url, &block)
      App.asset_library.al_asset_library.assetForURL(
        asset_url, 
        resultBlock: lambda {|al_asset|
          asset = self.new(al_asset)
          block.call(asset, nil)
        }, 
        failureBlock: lambda {|error|
          block.call(nil, error)
        }
      )
    end

    # wrapper method
    def video_compatible?(video_path_url)
      App.asset_library.al_asset_library.videoAtPathIsCompatibleWithSavedPhotosAlbum(video_path_url)
    end

    [:thumbnail, :aspectRatioThumbnail].each do |method_name|
       underscored_method_name = method_name.gsub(/([A-Z])/){|m| "_#{m}" }.downcase
       define_method(underscored_method_name) do 
         self.al_asset_representation.send(method_name)
       end
    end

    def editable?
      @al_asset.editable
    end

    def original_asset
      original_al_asset = @al_asset.originalAsset
      Asset.new(original_al_asset) if original_al_asset
    end

    def default_representation
      @default_representation ||= Representation.new(@al_asset.defaultRepresentation)
    end
    alias_method :rep, :default_representation

    # wrapper for valurForProperty
    {
      asset_type: Asset.asset_types.key(ALAssetPropertyType),
      location: ALAssetPropertyLocation,
      duration: ALAssetPropertyDuration, # for video
      orientation: ALAssetPropertyOrientation,
      date: ALAssetPropertyDate,
      representation_utis: ALAssetPropertyRepresentations,
      urls: ALAssetPropertyURLs,
      url: ALAssetPropertyAssetURL
    }.each do |method_name, property_name|
      define_method(method_name) do 
        @al_asset.valueForProperty(property_name)
      end
    end
    alias_method :reps, :representations

    # call through to the default representation's methods
    [:full_resolution_image, :full_screen_image, :scale, 
     :dimensions, :filename, :size, :metadata].each do |method_name|
       define_method(method_name) do 
         default_representation.send(method_name)
       end
     end

    # fork, save_new (save to new asset with original asset property)
    # – writeModifiedImageDataToSavedPhotosAlbum:metadata:completionBlock:
    # – writeModifiedVideoAtPathToSavedPhotosAlbum:completionBlock:
    def fork(source, metadata = nil, &block) 
      case self.asset_type
      when ALAssetTypePhoto
        fork_by_image_data(source, metadata) {|asset, error| block.call(asset, error) }
      when
        fork_by_video_path(source) {|asset, error| block.call(asset, error) }
      else
        raise "ALAssetTypeUnknown"
      end
    end
    alias_method :save_new, :fork

    # overwrite, update (save to same asset. need editable flag)
    # – setImageData:metadata:completionBlock:
    # – setVideoAtPath:completionBlock:
    #
    # asset.overwrite(image_data, metadata) do |updated_asset, error|
    #   asset = updated_asset
    # end
    #
    def overwrite(source, metadata = nil, &block)
      case self.asset_type
      when ALAssetTypePhoto
        overwrite_by_image_data(source, metadata) {|asset, error| block.call(asset, error) }
      when
        overwrite_by_video_path(source) {|asset, error| block.call(asset, error) }
      else
        raise "ALAssetTypeUnknown"
      end
    end
    alias_method :update, :overwrite

    private
    def self.create_by_cg_image(cg_image, meta, callback = nil)
      if self.orientation?(meta)
        App.asset_library.al_asset_library.writeImageToSavedPhotosAlbum(
          cg_image,
          orientation: meta[:orientation],
          completionBlock: self.completion_block_for_create(callback)
        )
      else
        App.asset_library.al_asset_library.writeImageToSavedPhotosAlbum(
          cg_image,
          metadata: meta,
          completionBlock: self.completion_block_for_create(callback)
        )
      end
    end

    def self.orientation?(meta)
      meta && meta.size == 1 && meta[:orientation]
    end

    def self.create_by_image_data(image_data, meta, &block)
      App.asset_library.al_asset_library.writeImageDataToSavedPhotosAlbum(
        image_data,
        metadata: meta,
        completionBlock: self.completion_block_for_create(block)
      )
    end

    def self.create_by_video_path(video_path_url, &block)
      App.asset_library.al_asset_library.writeVideoAtPathToSavedPhotosAlbum(
        video_path_url,
        completionBlock: self.completion_block_for_create(block)
      )
    end

    def self.completion_block_for_create(callback = nil)
      Proc.new do |asset_url, error|
        self.find_by_url(asset_url) do |asset, error|
          @created_asset = asset
          callback.call(asset, error) if callback
        end
      end
    end

    def fork_by_image_data(image_data, metadata, &block)
      @al_asset.writeModifiedImageDataToSavedPhotosAlbum(
        source, 
        metadata: metadata,
        completionBlock: self.class.completion_block_for_create(block)
      )
    end

    def fork_by_video_path(video_path, &block)
      @al_asset.writeModifiedVideoAtPathToSavedPhotosAlbum(
        video_path,
        completionBlock: self.class.completion_block_for_create(block)
      )
    end

    def overwrite_by_image_data(image_data, metadata, &block)
      @al_asset.setImageData(
        source, 
        metadata: metadata,
        completionBlock: self.class.completion_block_for_create(block)
      )
    end

    def overwrite_by_video_path(video_path, &block)
      @al_asset.setVideoAtPath(
        video_path,
        completionBlock: self.class.completion_block_for_create(block)
      )
    end
  end

  Photo = Asset
  Video = Asset
end
