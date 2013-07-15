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
    def self.instance
      Dispatch.once { @@instance ||= new }
      @@instance
    end

    def al_asset_library
      @al_asset_library ||= ALAssetsLibrary.new
    end

    def groups
      @groups ||= Groups.new(self)
    end

    def saved_photos
      groups.find_by_name('Saved Photos')
    end
  end
end
