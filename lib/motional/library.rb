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
    # @return [Class] An alias of MotionAL::Group class
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
  end
end
