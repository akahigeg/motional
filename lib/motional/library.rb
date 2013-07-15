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

    # An instance of ALAssetLibrary.
    # @return [ALAssetsLibrary]
    def al_asset_library
      @al_asset_library ||= ALAssetsLibrary.new
    end

    # @return [MotionAL::Groups] Contains all groups in AssetLibrary.
    def groups
      @groups ||= Groups.new(self)
    end

    # Return a default group named 'Camera Roll' or 'Saved Photos'.
    #
    # 'Camera Roll' and 'Saved Photos' are the special groups. 
    # That exists in initial state of any iOS devices and iOS Simurator. 
    # And all assets belong to Those automatically.(maybe)
    #
    # 'Camera Roll' is in a device, 'Saved Photos' is in a simurator.
    #
    # @return [MotionAL::Group] 
    def camera_roll
      groups.find_by_name('Camera Roll') || groups.find_by_name('Saved Photos')
    end
    alias_method :saved_photos, :camera_roll
  end
end
