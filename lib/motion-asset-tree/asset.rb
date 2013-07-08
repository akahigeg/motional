# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Asset
    attr_accessor :al_asset

    def initialize(al_asset)
      @al_asset = al_asset
      @representation = al_asset.defaultRepresentation
    end

    def representations
      # キャッシュ＆遅延読み込み
    end
    alias_method :reps, :representations

    def default_representation
      # 透過的アクセス

    end
    alias_method :rep, :default_representation

    # reporesentation
    def current_representation

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
  end
end

__END__

NSString *const ALAssetPropertyType;
NSString *const ALAssetPropertyLocation;
NSString *const ALAssetPropertyDuration;
NSString *const ALAssetPropertyOrientation;
NSString *const ALAssetPropertyDate;
NSString *const ALAssetPropertyRepresentations;
NSString *const ALAssetPropertyURLs;
NSString *const ALAssetPropertyAssetURL;

Asset Properties
– valueForProperty:
  editable  property
  originalAsset  property
Accessing Representations
– defaultRepresentation
– representationForUTI:
– thumbnail
– aspectRatioThumbnail
Setting New Image and Video Data
– setImageData:metadata:completionBlock:
– setVideoAtPath:completionBlock:
Saving to the Saved Photos Album
– writeModifiedImageDataToSavedPhotosAlbum:metadata:completionBlock:
– writeModifiedVideoAtPathToSavedPhotosAlbum:completionBlock:

