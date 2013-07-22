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
    # @return [MotionAL::Library] Singleton instance.
    def self.instance
      Dispatch.once { @@instance ||= new }
      @@instance
    end

    def initialize 
      @camera_roll = nil
    end

    # An instance of ALAssetLibrary.
    # @return [ALAssetsLibrary]
    def al_asset_library
      @al_asset_library ||= ALAssetsLibrary.new
    end

    # @return [MotionAL::Groups] Contain all groups in AssetLibrary.
    def groups
      @groups = MotionAL::Group
      # @groups ||= Groups.new(self)
    end

    # Return the special group named 'Camera Roll' or 'Saved Photos'.
    #
    # That exists in initial state of any iOS devices and iOS Simurator. 
    # And all assets that are created in the device belong to this group automatically.(maybe)
    #
    # 'Camera Roll' is the name on a device, 'Saved Photos' is the name on a simurator.
    #
    # @return [MotionAL::Group] 
    def camera_roll(&block)
      @camera_roll if @camera_roll
      MotionAL::Group.find_by_name('Camera Roll') do |group, error|
        @camera_roll = group if group.name == 'Camera Roll'
      end
      MotionAL::Group.find_by_name('Saved Photo') do |group, error|
        @camera_roll = group if group.name == 'Saved Photo'
      end
    end
    alias_method :saved_photos, :camera_roll

    # Return the special group named 'Photo Library'.
    #
    # This group includes all assets that are synced from iTunes.
    #
    # @return [MotionAL::Group] 
    def photo_library
      @photo_library ||= MotionAL::Group.all({group_type: :library}).first
    end
  end
end
