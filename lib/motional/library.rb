# -*- encoding : utf-8 -*-

module MotionAL
  #
  # A wrapper of ALAssetLibrary class.
  #
  #   An instance of ALAssetsLibrary provides access to the videos and photos that are under the control of the Photos application.
  #   The library includes those that are in the Saved Photos album, those coming from iTunes, and those that were directly imported into the device. You use it to retrieve the list of all asset groups and to save images and videos into the Saved Photos album.
  #
  # And added some convinience methods.
  #
  class Library
    # An alias of MotionAL::Group
    attr_reader :groups

    # @return [MotionAL::Library] Singleton instance.
    def self.instance
      Dispatch.once { @@instance ||= new }
      @@instance
    end

    def initialize 
      @groups = MotionAL::Group
    end

    # An instance of ALAssetLibrary.
    # @return [ALAssetsLibrary]
    def al_asset_library
      @al_asset_library ||= ALAssetsLibrary.new
    end

    # Return the special group named 'Camera Roll' or 'Saved Photos'.
    #
    # That exists in initial state of any iOS devices and iOS Simurator. 
    # And all assets that are created in the device belong to this group automatically.(maybe)
    #
    # 'Camera Roll' is the name on a device, 'Saved Photos' is the name on a simurator.
    #
    # @return [MotionAL::Group] 
    def open_camera_roll(&block)
      MotionAL::Group.find_camera_roll do |group, error|
        block.call(group, error)
      end
    end
    alias_method :open_saved_photos, :open_camera_roll

    # Return the special group named 'Photo Library'.
    #
    # This group includes all assets that are synced from iTunes.
    #
    # @return [MotionAL::Group] 
    def open_photo_library(&block)
      MotionAL::Group.find_photo_library do |group, error|
        block.call(group, error)
      end
    end
  end
end
