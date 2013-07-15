# -*- encoding : utf-8 -*-

module MotionAL
  #
  # A wrapper of ALAssetGroup class.
  #
  #   An ALAssetsGroup object represents an ordered set of the assets managed by the Photos application. The order of the elements is the same as the user sees in the Photos application. An asset can belong to multiple assets groups.
  #   Assets groups themselves are synced via iTunes, created to hold the user’s saved photos or created during camera import. You cannot directly modify the groups using ALAssetsGroup. You can indirectly modify the Saved Photos group by saving images or videos into it using the ALAssetsLibrary class.
  #
  # And added some convinience methods.
  #
  class Group
    # An instance of ALAssetGroup.
    attr_reader :al_asset_group

    @@thread_safe_data_store = {}
    @@store = ThreadValueStore

    # @param al_asset_group [ALAssetsGroup]
    def initialize(al_asset_group)
      @al_asset_group = al_asset_group
    end

    # Create a group.
    # A group should not be created if a specified name already exists.
    #
    # @param group_name [String]
    # @return [MotionAL::Group] A created asset.
    # @return [nil] When block given or fail to create.
    #
    # @example
    #   MotionAL::Group.create('MyAlbum') do |group, error|
    #     # asynchronous if a block given
    #     p group.name
    #   end
    #
    #   group = MotionAL::Group.create('MyAlbum')
    #   p group.name
    def self.create(group_name, &block)
      pid = @@store.reserve(:create)
      if block_given?
        self.origin_create(group_name, pid, block)
      else
        Dispatch.wait_async { self.origin_create(group_name, pid) }
        created_group = @@store.get(:create, pid)
        @@store.release(:create, pid)

        return created_group
      end
    end

    # Find an asset by a specified asset_url.
    #
    # @param group_url [NSURL]
    # @return [MotionAL::group] A found group.
    # @return [nil] When block given or fail to find.
    #
    # @example
    #   MotionAL::group.find_by_url(url) do |group, error|
    #     # asynchronous if a block given
    #     p group.name
    #   end
    #
    #   group = MotionAL::group.find_by_url(url)
    #   p group.name
    def self.find_by_url(group_url, &block)
      pid = @@store.reserve(:find_by_url)
      if block_given?
        self.origin_find_by_url(group_url, pid, block)
      else
        Dispatch.wait_async { self.origin_find_by_url(group_url, pid) }
        found_group = @@store.get(:find_by_url, pid)
        @@store.release(:find_by_url, pid)

        return found_group
      end
    end

    # Find an group by a specified group name.
    #
    # @param group_name [String]
    # @return [MotionAL::Group] A found group.
    # @return [nil] When fail to find.
    #
    # @example
    #   group = MotionAL::Group.find_by_name('MyAlbum')
    #   p group.name
    def self.find_by_name(group_name)
      MotionAL.library.groups.select{|g| g.name == group_name }.first
    end

    # Find all groups in the AssetLibrary.
    #
    # @return [Array] Found groups.
    #
    # @example
    #   MotionAL::group.all do |group, error|
    #     # asynchronous if a block given
    #     p group.name
    #   end
    #
    #   groups = MotionAL::group.all
    #   names  = groups.map {|g| g.name }
    def self.all(&block)
      pid = @@store.reserve(:all, :array)
      if block_given?
        origin_all(pid, block)
      else
        Dispatch.wait_async { self.origin_all(pid) }
        found_groups = @@store.get(:all, pid)
        @@store.release(:all, pid)

        return found_groups
      end
    end

    # @return [MotionAL::Assets] The collection of assets in the group.
    def assets
      @assets ||= Assets.new(self)
    end

    # Return true if the app haves write access for the group.
    # In other words true means the app can add assets to the group.
    #
    # @return [Boolean]
    def editable?
      @al_asset_group.editable?
    end

    # @return [CGImageRef] The group's poster image.
    def poster_image
      @al_asset_group.posterImage
    end

    # wrapper of valueForProperty
    class << self
      private
      # wrapper for valueForProperty
      # @!macro [attach] make_wrapper
      #   The gruop's $1
      #   @method $1
      #   @return [$3] The value for the property $2.
      #   @return [nil] The property is empty.
      def make_wrapper_for_property(method_name, property_name, type_of_return)

        define_method(method_name) do 
          @al_asset_group.valueForProperty(property_name)
        end
      end
    end
    make_wrapper_for_property(:name, ALAssetsGroupPropertyName, "Stirng")
    make_wrapper_for_property(:persistent_id, ALAssetsGroupPropertyPersistentID, "String")
    make_wrapper_for_property(:url, ALAssetsGroupPropertyURL, "NSURL")

    # The type of the group.
    #
    # @return [Symbol] :library, :album, :event, :faces, :photos, :photo_stream or :all         
    def asset_group_type
      MotionAL.asset_group_types.key(@al_asset_group.valueForProperty(ALAssetsGroupPropertyType))
    end

    private
    def self.origin_create(group_name, pid, callback = nil)
      MotionAL.library.al_asset_library.addAssetsGroupAlbumWithName(
        group_name, 
        resultBlock: lambda { |al_asset_group|
          if !al_asset_group.nil?
            created_group = Group.new(al_asset_group) 
            @@store.set(:create, pid, created_group)
          end

          callback.call(created_group, nil) if callback
        },
        failureBlock: lambda { |error|
          callback.call(nil, error) if callback
        }
      )
    end

    def self.origin_find_by_url(group_url, pid, callback = nil)
      MotionAL.library.al_asset_library.groupForURL(
        group_url, 
        resultBlock: lambda { |al_asset_group|
          if !al_asset_group.nil?
            found_group = Group.new(al_asset_group) 
            @@store.set(:find_by_url, pid, found_group)
          end

          callback.call(found_group, nil) if callback
        },
        failureBlock: lambda { |error|
          callback.call(nil, error) if callback
        }
      )
    end

    def self.origin_all(pid, callback = nil)
      # TODO: support more Type of Asset (now only support ALAssetsGroupAll)
      MotionAL.library.al_asset_library.enumerateGroupsWithTypes(
        MotionAL.asset_group_types[:all],
        usingBlock: lambda { |al_asset_group, stop|
          if !al_asset_group.nil?
            group = Group.new(al_asset_group) 
            @@store.set(:all, pid, group)
            callback.call(group, nil) if callback
          end
        },
        failureBlock: lambda { |error|
          callback.call(nil, error) if callback
        }
      )
    end
  end
end
