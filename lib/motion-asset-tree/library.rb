# -*- encoding : utf-8 -*-

class App
  def self.asset_library
    @@asset_library ||= MotionAssetTree.new
  end
end

class MotionAssetTree
  def self.al_asset_library
    @@al_asset_library ||= ALAssetsLibrary.new
  end

  def al_asset_library
    self.class.al_asset_library
  end

  def initialize
  end

  def groups
    @groups ||= Groups.new(self)
  end

  def self.authorized?
    ALAssetsLibrary.authorizationStatus == ALAuthorizationStatusAuthorized
  end

  def self.disable_shared_photo_streams_support
    ALAssetsLibrary.disableSharedPhotoStreamsSupport
  end
end
