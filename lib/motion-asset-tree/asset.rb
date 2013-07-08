# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Asset
    attr_accessor :al_asset

    def initialize(al_asset)
      @al_asset = al_asset
      @representation = al_asset.defaultRepresentation
    end

    def representations
      @representations ||= Representations.new(self)
    end

    def self.find_by_url(asset_url, &callback)
      ap asset_url
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

    [:editable, :originalAsset, :defaultRepresentation, 
     :thumbnail, :aspectRatioThumbnail].each do |method_name|
       underscored_method_name = method_name.gsub(/([A-Z])/){|m| "_#{m}" }.downcase
       define_method(underscored_method_name) do 
         self.al_asset_representation.send(method_name)
       end
    end
    alias_method :rep, :default_representation

    {
      asset_type: ALAssetPropertyType, # ALAssetTypePhoto or ALAssetTypeVideo or ALAssetTypeUnknown
      location: ALAssetPropertyLocation,
      duration: ALAssetPropertyDuration, # for video
      orientation: ALAssetPropertyOrientation,
      date: ALAssetPropertyDate,
      al_representations: ALAssetPropertyRepresentations,
      urls: ALAssetPropertyURLs,
      url: ALAssetPropertyAssetURL
    }.each do |method_name, property_name|
      define_method(method_name) do 
        @al_asset_group.valueForProperty(property_name)
      end
    end
    alias_method :reps, :representations

    # – setImageData:metadata:completionBlock:
    def set_image_data()

    end

    # – setVideoAtPath:completionBlock:
    def set_video_at_path()

    end

    # – writeModifiedImageDataToSavedPhotosAlbum:metadata:completionBlock:
    def update()
    end
    
    #– writeModifiedVideoAtPathToSavedPhotosAlbum:completionBlock:
  end
end

__END__


Accessing Representations
– representationForUTI:
Saving to the Saved Photos Album

