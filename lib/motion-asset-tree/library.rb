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

  def self.loading
    @@loading ||= false
  end

  def self.start_loading
    @@loading = true
  end

  def self.finish_loading
    @@loading = false
  end

  def al_asset_library
    self.class.al_asset_library
  end

  def initialize
  end

  def groups
    @groups ||= Groups.new(self)
  end

  def saved_photos_group
    @groups.find {|g| g.name == 'Saved Photos'}
  end

  def self.authorized?
    ALAssetsLibrary.authorizationStatus == ALAuthorizationStatusAuthorized
  end

  def self.disable_shared_photo_streams_support
    ALAssetsLibrary.disableSharedPhotoStreamsSupport
  end
end
