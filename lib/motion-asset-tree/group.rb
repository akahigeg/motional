# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Group
    attr_accessor :al_asset_group
    def initialize(al_asset_group)
      @al_asset_group = al_asset_group
    end

    def assets
      @assets ||= Assets.new(self)
      # キャッシュ＆遅延読み込み
    end

    def editable?
      @al_asset_group.editable?
    end

    def poster_image
      @al_asset_group.posterImage
    end

    # wrapper of valueForProperty
    def name
      @al_asset_group.valueForProperty(ALAssetsGroupPropertyName)
    end

    def asset_group_type
      @al_asset_group.valueForProperty(ALAssetsGroupPropertyType)
    end

    def persistent_id
      @al_asset_group.valueForProperty(ALAssetsGroupPropertyPersistentID)
    end

    def url
      @al_asset_group.valueForProperty(ALAssetsGroupPropertyURL)
    end
  end
end

__END__

– enumerateAssetsUsingBlock: => Assets
– enumerateAssetsWithOptions:usingBlock: => Assets
– enumerateAssetsAtIndexes:options:usingBlock: => Assets
Adding Assets
– addAsset: => Assets
  editable
Filtering
– numberOfAssets => Assets
– setAssetsFilter: => Assets
Accessing Properties
– valueForProperty:
– posterImage

