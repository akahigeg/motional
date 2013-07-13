# -*- encoding : utf-8 -*-

class MotionAL
  class Group
    attr_accessor :al_asset_group
    @@thread_safe_data_store = {}

    def initialize(al_asset_group)
      @al_asset_group = al_asset_group
    end

    def self.reserve_data_store(name)
      pid = rand.to_s
      @@thread_safe_data_store[name] ||= {}
      if type_of_data_store(name) == :array
        @@thread_safe_data_store[name][pid] = []
      else
        @@thread_safe_data_store[name][pid] = nil
      end

      pid
    end

    def self.save_to_data_store(name, pid, value)
      if type_of_data_store(name) == :array
        @@thread_safe_data_store[name][pid] << value
      else
        @@thread_safe_data_store[name][pid] = value
      end
    end

    def self.release_data_store(name, pid)
      @@thread_safe_data_store[name].delete(pid)
    end

    def self.type_of_data_store(name)
      { :all => :array }[name]
    end

    def self.create(group_name, &block)
      # TODO: thread safe
      pid = reserve_data_store(:created)
      if block_given?
        self.origin_create(group_name, pid, block)
      else
        Dispatch.wait_async { self.origin_create(group_name, pid) }
        return @created_group
      end
    end

    def self.find_by_url(group_url, &block)
      # TODO: thread safe
      @found_group = nil
      if block_given?
        self.origin_find_by_url(group_url, block)
      else
        Dispatch.wait_async { self.origin_find_by_url(group_url) }
        return @found_group
      end
    end

    def self.find_by_name(group_name)
      MotionAL.library.groups.select{|g| g.name == group_name }.first
    end

    def self.all(options = nil, &block)
      # TODO: thread safe
      @all_groups = []
      if block_given?
        origin_all(block)
      else
        Dispatch.wait_async { self.origin_all }
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
      persistent_id: ALAssetsGroupPropertyPersistentID,
      url: ALAssetsGroupPropertyURL
    }.each do |method_name, property_name|
      define_method(method_name) do 
        @al_asset_group.valueForProperty(property_name)
      end
    end

    def asset_group_type
      self.class.asset_group_types.key(@al_asset_group.valueForProperty(ALAssetsGroupPropertyType))
    end

    private
    def self.asset_group_types
      {
        :library => ALAssetsGroupLibrary,
        :album => ALAssetsGroupAlbum,
        :event => ALAssetsGroupEvent,
        :faces => ALAssetsGroupFaces,
        :photos => ALAssetsGroupSavedPhotos,
        :photo_stream => ALAssetsGroupPhotoStream,
        :all => ALAssetsGroupAll
        
      }
    end
    
    def self.origin_create(group_name, pid, callback = nil)
      MotionAL.library.al_asset_library.addAssetsGroupAlbumWithName(
        group_name, 
        resultBlock: lambda { |al_asset_group|
          if !al_asset_group.nil?
            created_group = Group.new(al_asset_group) 
            save_to_data_store(:created, pid, created_group)
          end

          callback.call(created_group, nil) if callback
        },
        failureBlock: lambda { |error|
          callback.call(nil, error) if callback
        }
      )
    end

    def self.origin_find_by_url(group_url, callback = nil)
      MotionAL.library.al_asset_library.groupForURL(
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

    def self.origin_all(callback = nil)
      # TODO: support more Type of Asset (now only support ALAssetsGroupAll)
      MotionAL.library.al_asset_library.enumerateGroupsWithTypes(
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
