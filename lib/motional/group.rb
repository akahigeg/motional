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

    # @param al_asset_group [ALAssetsGroup]
    def initialize(al_asset_group)
      @al_asset_group = al_asset_group
    end

    # Create a group.
    # A group should not be created if a specified name already exists.
    #
    # @param group_name [String]
    # @return [nil]
    #
    # @yield [group, error]
    # @yieldparam group [MotionAL::Group] A created group.
    # @yieldparam error [error]
    #
    # @example
    #   MotionAL::Group.create('MyAlbum') do |group, error|
    #     # asynchronous if a block given
    #     p group.name
    #   end
    #
    #   MotionAL::Group.create('MyAlbum')
    def self.create(group_name, &block)
      self.origin_create(group_name, block)
    end

    # Find a group by a specified group_url.
    #
    # @param group_url [NSURL, String]
    # @return [nil]
    #
    # @yield [group, error]
    # @yieldparam group [MotionAL::Group] A found group.
    # @yieldparam error [error]
    #
    # @example
    #   MotionAL::group.find_by_url(url) do |group, error|
    #     # asynchronous
    #     p group.name
    #   end
    def self.find_by_url(group_url, &block)
      url = group_url.is_a?(String) ? NSURL.alloc.initWithString(group_url) : group_url
      origin_find_by_url(url, block)
    end

    # Find a group by a specified group name.
    #
    # @param group_name [String]
    # @return [nil]
    #
    # @yield [group, error]
    # @yieldparam group [MotionAL::Group] A found group.
    # @yieldparam error [error]
    #
    # @note It is recommended to use find_by_url instead of this. Because a group could be renamed.
    #
    # @example
    #   MotionAL::Group.find_by_name('MyAlbum') do |group, error|
    #     p group.name
    #   end
    def self.find_by_name(group_name, &block)
      group_name = /^#{group_name}$/ if group_name.kind_of? String
      find_all do |group, error|
        block.call(group, error) if group.name =~ group_name
      end
    end

    # Find the Camera Roll(built-in default group)
    #
    # @return [nil]
    #
    # @yield [group, error]
    # @yieldparam group [MotionAL::Group] 'Camera Roll' or 'Saved Photos'
    # @yieldparam error [error]
    #
    # @example
    #   MotionAL::Group.find_camera_roll do |group, error|
    #     p group.name #=> 'Camera Roll' or 'Saved Photos'
    #   end
    def self.find_camera_roll(&block)
      find_by_name(/Camera Roll|Saved Photos/) {|group, error| block.call(group, error) }
    end

    # Find the Photo Library(synced from iTunes)
    #
    # @return [nil]
    #
    # @yield [group, error]
    # @yieldparam group [MotionAL::Group] 'Photo Library'
    # @yieldparam error [error]
    #
    # @example
    #   MotionAL::Group.find_photo_library do |group, error|
    #     p group.name #=> 'Photo Library'
    #   end
    def self.find_photo_library(&block)
      find_all({group_type: :library}) { |group, error| block.call(group, error) }
    end

    # Find and enumerate all groups in the AssetLibrary.
    #
    # @param options [Hash]
    # @option options :group_type [Symbol] An asset group type. default: :all.
    # @return [nil]
    #
    # @yield [group, error]
    # @yieldparam group [MotionAL::Group] A found group.
    # @yieldparam error [error]
    #
    # @see MotionAL.asset_group_types
    # @note group_type :all includes all groups except 'Photo Library'
    #
    # @example
    #   MotionAL::group.find_all do |group, error|
    #     # asynchronous
    #     p group.name
    #   end
    def self.find_all(options = {}, &block)
      origin_find_all(options, block)
    end
    class << self
      alias_method :each, :find_all
    end

    # The collection of assets in the group.
    # @return [MotionAL::Assets] An instance of MotionAL::Assets belongs to the group.
    def assets
      @assets ||= Assets.new(self)
    end

    # Return true if your app has write access for the group.
    # In other words true means your app can add assets to the group.
    #
    # @return [Boolean]
    def editable?
      @al_asset_group.editable?
    end

    # @return [CGImageRef] The group's poster image.
    def poster_image
      @al_asset_group.posterImage
    end

    # Add an asset to the group.
    #
    # @param asset [MotionAL::Asset]
    # @return [Boolean] true if asset was added successfully, otherwise false
    #
    # @note cannot remove ALAsset from ALAssetGroup by yor app
    def add_asset(asset)
      @al_asset_group.addAsset(asset.al_asset)
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
    make_wrapper_for_property(:name, ALAssetsGroupPropertyName, "String")
    make_wrapper_for_property(:persistent_id, ALAssetsGroupPropertyPersistentID, "String")
    make_wrapper_for_property(:url, ALAssetsGroupPropertyURL, "NSURL")

    # The type of the group.
    #
    # @return [Symbol] :library, :album, :event, :faces, :photos, :photo_stream or :all         
    def asset_group_type
      MotionAL.asset_group_types.key(@al_asset_group.valueForProperty(ALAssetsGroupPropertyType))
    end

    private
    def self.origin_create(group_name, callback = nil)
      MotionAL.library.al_asset_library.addAssetsGroupAlbumWithName(
        group_name, 
        resultBlock: lambda { |al_asset_group|
          if !al_asset_group.nil?
            created_group = Group.new(al_asset_group) 
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
          if !al_asset_group.nil?
            found_group = Group.new(al_asset_group) 
          end

          callback.call(found_group, nil)
        },
        failureBlock: lambda { |error|
          callback.call(nil, error)
        }
      )
    end

    def self.origin_find_all(options, callback = nil)
      options[:group_type] ||= :all
      MotionAL.library.al_asset_library.enumerateGroupsWithTypes(
        MotionAL.asset_group_types[options[:group_type].to_sym],
        usingBlock: lambda { |al_asset_group, stop|
          if !al_asset_group.nil?
            group = Group.new(al_asset_group) 
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
