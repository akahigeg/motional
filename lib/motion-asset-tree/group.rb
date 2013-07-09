# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Group
    attr_accessor :al_asset_group
    def initialize(al_asset_group)
      @al_asset_group = al_asset_group
    end

    def self.create(group_name, &block)
      App.asset_library.al_asset_library.addAssetsGroupAlbumWithName(
        group_name, 
        resultBlock: lambda { |al_asset_group|
          group = Group.new(al_asset_group) if !al_asset_group.nil?
          block.call(group, nil)
        },
        failureBlock: lambda { |error|
          block.call(nil, error)
        }
      )
    end

    def self.find_by_url(group_url)
      App.asset_library.al_asset_library.groupForURL(
        group_url, 
        resultBlock: lambda { |al_asset_group|
          group = Group.new(al_asset_group) if !al_asset_group.nil?
          callback.call(group, nil)
        },
        resultBlock: lambda { |error|
          callback.call(nil, error)
        }
      )
    end

    def self.find_by_name(group_name)
      App.asset_library.groups.select{|g| g.name == group_name }.first
    end

    def assets
      @assets ||= Assets.new(self)
    end

    # wrapper method
    def editable?
      @al_asset_group.editable?
    end

    def poster_image
      @al_asset_group.posterImage
    end

    # wrapper of valueForProperty
    {
      name: ALAssetsGroupPropertyName,
      asset_group_type: ALAssetsGroupPropertyType,
      persistent_id: ALAssetsGroupPropertyPersistentID,
      url: ALAssetsGroupPropertyURL
    }.each do |method_name, property_name|
      define_method(method_name) do 
        @al_asset_group.valueForProperty(property_name)
      end
    end
  end
end
