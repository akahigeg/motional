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

    # TODO support NSData and NSURL(video)
    #– writeImageToSavedPhotosAlbum:orientation:completionBlock:
    #– writeImageDataToSavedPhotosAlbum:metadata:completionBlock:
    #– writeImageToSavedPhotosAlbum:metadata:completionBlock:
    #– writeVideoAtPathToSavedPhotosAlbum:completionBlock:
    def self.create(source, meta = nil, &block)
      # source => CGImage or NSData or NSURL(video)
      if source.kind_of? NSURL
      else
        self.create_by_cg_image(source, meta) do |asset, error|
          block.call(asset, error)
        end
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
      Representation.new(@al_asset.defaultRepresentation)
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

    # create (save to new asset)
    # – writeModifiedImageDataToSavedPhotosAlbum:metadata:completionBlock:
    # – writeModifiedVideoAtPathToSavedPhotosAlbum:completionBlock:
    def save(source, metadata = nil, &block) 
      case self.asset_type
      when ALAssetTypePhoto
        create_by_image_data(source, metadata) {|asset, error| block.call(asset, error) }
      when
        create_by_video_path(source) {|asset, error| block.call(asset, error) }
      else
        raise "ALAssetTypeUnknown"
      end
    end

    # update (save to same asset. need editable flag)
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
    def self.create_by_cg_image(cg_image, meta, &block)
      if meta && meta.size == 1 && meta[:orientation]
        App.asset_library.al_asset_library.writeImageToSavedPhotosAlbum(
          cg_image,
          orientation: meta[:orientation],
          completionBlock: self.completion_block_for_create(block)
        )
      else
        App.asset_library.al_asset_library.writeImageToSavedPhotosAlbum(
          cg_image,
          metadata: meta,
          completionBlock: self.completion_block_for_create(block)
        )
      end
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

    def self.completion_block_for_create(callback)
      Proc.new do |asset_url, error|
        self.find_by_url(asset_url) do |asset, error|
          callback.call(asset, error)
        end
      end
    end

    def create_by_image_data(image_data, metadata, &block)
      @al_asset.writeModifiedImageDataToSavedPhotosAlbum(
        source, 
        metadata: metadata,
        completionBlock: self.class.completion_block_for_create(block)
      )
    end

    def create_by_video_path(video_path, &block)
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
end
