# -*- encoding : utf-8 -*-

class App
  def self.al_asset_library
    @@al_asset_library ||= ALAssetsLibrary.new
  end
end

class MotionAssetTree
  def initialize
    @al_asset_library = App.al_asset_library
  end

  def groups
    @groups ||= Groups.new(@al_asset_library)
  end

  def self.authorized?
    ALAssetsLibrary.authorizationStatus == ALAuthorizationStatusAuthorized
  end
end
