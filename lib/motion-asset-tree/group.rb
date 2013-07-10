# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Group
    attr_accessor :al_asset_group
    def initialize(al_asset_group)
      @al_asset_group = al_asset_group
    end

    def self.create(group_name, &block)
      @created_group = nil
      if block_given?
        self.call_origin_create(group_name, block)
      else
        Dispatch.wait_async { self.call_origin_create(group_name) }
        return @created_group
      end
    end

    def self.find_by_url(group_url, &block)
      @found_group = nil
      if block_given?
        self.call_origin_find_by_url(group_url, block)
      else
        Dispatch.wait_async { self.call_origin_find_by_url(group_url) }
        return @found_group
      end
    end

    def self.find_by_name(group_name)
      App.asset_library.groups.select{|g| g.name == group_name }.first
    end

    def self.all(&block)
      @all_groups = []
      if block_given?
        call_origin_all(block)
      else
        Dispatch.wait_async { self.call_origin_all }
        return @all_groups
      end
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

    private
    def self.call_origin_create(group_name, callback = nil)
      App.asset_library.al_asset_library.addAssetsGroupAlbumWithName(
        group_name, 
        resultBlock: lambda { |al_asset_group|
          @created_group = Group.new(al_asset_group) if !al_asset_group.nil?
          callback.call(@created_group, nil) if callback
        },
        failureBlock: lambda { |error|
          callback.call(nil, error) if callback
        }
      )
    end

    def self.call_origin_find_by_url(group_url, callback = nil)
      App.asset_library.al_asset_library.groupForURL(
        group_url, 
        resultBlock: lambda { |al_asset_group|
          @found_group = Group.new(al_asset_group) if !al_asset_group.nil?
          callback.call(@found_group, nil) if callback
        },
        failureBlock: lambda { |error|
          callback.call(nil, error) if callback
        }
      )
    end

    def self.call_origin_all(callback = nil)
      App.asset_library.al_asset_library.enumerateGroupsWithTypes(
        ALAssetsGroupAll,
        usingBlock: lambda { |al_asset_group, stop|
          if !al_asset_group.nil?
            group = Group.new(al_asset_group) 
            @all_groups << group
            callback.call(group, nil) if callback
          end
        },
        failureBlock: lambda { |error|
          callback.call(nil, error) if callback
        }
      )
    end
  end

  Album = Group
end
