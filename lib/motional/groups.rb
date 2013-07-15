# -*- encoding : utf-8 -*-

module MotionAL
  #
  # A collection of groups.
  # Gruops belongs to the AssetLibrary.
  #
  class Groups < Children
    # @param asset_library [MotionAL::Library]
    def initialize(asset_library)
      @asset_library = asset_library
      load_entries
      self << MotionAL.library.photo_library
    end

    def reload
      super
      self << MotionAL.library.photo_library
    end

    # Create a group.
    # A group should not be created if a specified name already exists.
    #
    # @param group_name [String]
    # @return [MotionAL::Group] A created asset.
    # @return [nil] When block given or fail to create.
    #
    # @example
    #   MotionAL.library.groups.create('MyAlbum') do |group, error|
    #     # asynchronous if a block given
    #     p group.name
    #   end
    #
    #   group = MotionAL.library.groups.create('MyAlbum')
    #   p group.name
    def create(group_name, &block)
      if block_given?
        MotionAL::Group.create(group_name) do |group, error|
          block.call(group, error)
        end
      else
        MotionAL::Group.create(group_name)
      end
    end

    # Find a group by a specified group_url.
    #
    # @param group_url [NSURL]
    # @return [MotionAL::group] A found group.
    # @return [nil] When block given or fail to find.
    #
    # @example
    #   MotionAL.library.groups.find_by_url(url) do |group, error|
    #     # asynchronous if a block given
    #     p group.name
    #   end
    #
    #   group = MotionAL.library.groups.find_by_url(url)
    #   p group.name
    def find_by_url(group_url, &block)
      if block_given?
        MotionAL::Group.find_by_url(group_url) do |group, error|
          block.call(group, error)
        end
      else
        MotionAL::Group.find_by_url(group_url)
      end
    end

    # Find an group by a specified group name.
    #
    # @param group_name [String]
    # @return [MotionAL::Group] A found group.
    # @return [nil] When fail to find.
    #
    # @example
    #   group = MotionAL.library.groups.find_by_name('MyAlbum')
    #   p group.name
    def find_by_name(group_name, &block)
      MotionAL::Group.find_by_name(group_name)
    end

    # Find all groups in the AssetLibrary.
    #
    # @return [Array] Found groups.
    #
    # @example
    #   MotionAL.library.groups.all do |group, error|
    #     # asynchronous if a block given
    #     p group.name
    #   end
    #
    #   groups = MotionAL.library.groups.all
    #   names  = groups.map {|g| g.name }
    def all(options = {}, &block)
      if block_given?
        MotionAL::Group.all(options) do |group, error|
          block.call(group, error)
        end
      else
        MotionAL::Group.all(options)
      end
    end
  end
end
