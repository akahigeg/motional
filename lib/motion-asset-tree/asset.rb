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

    # TODO support NSData and NSURL(video)
    #– writeImageToSavedPhotosAlbum:orientation:completionBlock:
    #– writeImageDataToSavedPhotosAlbum:metadata:completionBlock:
    #– writeImageToSavedPhotosAlbum:metadata:completionBlock:
    #– writeVideoAtPathToSavedPhotosAlbum:completionBlock:
    def self.create(source, meta, &callback)
      # image => CGImage or NSData or NSURL(video)
      App.al_asset_library.writeImageToSavedPhotosAlbum(
        source,
        metadata: meta,
        completionBlock: lambda {|asset_url, error|
          find_by_url(asset_url) do |asset, error|
            callback.call(asset, error)
          end
        }
      )
    end
    #– videoAtPathIsCompatibleWithSavedPhotosAlbum:

    def self.find_by_url(asset_url, &callback)
      App.al_asset_library.assetForURL(
        asset_url, 
        resultBlock: lambda {|al_asset|
          asset = self.new(al_asset)
          callback.call(asset, nil)
        }, 
        failureBlock: lambda {|error|
          callback.call(nil, error)
        }
      )
    end

    # wrapper method
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
      asset_type: ALAssetPropertyType, # ALAssetTypePhoto or ALAssetTypeVideo or ALAssetTypeUnknown
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
        create_by_image(source, metadata) {|asset, error| block.call(asset, error) }
      when
        create_by_video(source) {|asset, error| block.call(asset, error) }
      else
        raise "ALAssetTypeUnknown"
      end
    end

    def create_by_image(image_data, metadata, &block)
      @al_asset.writeModifiedImageDataToSavedPhotosAlbum(
        source, 
        metadata: metadata,
        completionBlock: lambda {|asset_url, error|
          # should reload?
          asset = self.new(@al_asset) if asset_url
          block.call(asset, error)
        }
      )
    end

    def create_by_video(video_path, &block)
      @al_asset.writeModifiedVideoAtPathToSavedPhotosAlbum(
        video_path,
        completionBlock: lambda {|asset_url, error|
          # should reload?
          asset = self.new(@al_asset) if asset_url
          block.call(asset, error)
        }
      )
    end

    # update (save to same asset. need editable flag)
    # – setImageData:metadata:completionBlock:
    # – setVideoAtPath:completionBlock:
    def overwrite(source, metadata = nil, &block)
      case self.asset_type
      when ALAssetTypePhoto
        overwrite_by_image(source, metadata) {|asset, error| block.call(asset, error) }
      when
        overwrite_by_video(source) {|asset, error| block.call(asset, error) }
      else
        raise "ALAssetTypeUnknown"
      end
    end
    alias_method :update, :overwrite

    def overwrite_by_image(image_data, metadata, &block)
      @al_asset.setImageData(
        source, 
        metadata: metadata,
        completionBlock: lambda {|asset_url, error|
          # should reload?
          asset = self.new(@al_asset) if asset_url
          block.call(asset, error)
        }
      )
    end

    def overwrite_by_video(video_path, &block)
      @al_asset.setVideoAtPath(
        video_path,
        completionBlock: lambda {|asset_url, error|
          # should reload?
          asset = self.new(@al_asset) if asset_url
          block.call(asset, error)
        }
      )
    end

  end
end

__END__


Accessing Representations
– representationForUTI:
Saving to the Saved Photos Album

