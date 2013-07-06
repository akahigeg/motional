# -*- encoding : utf-8 -*-

class MotionAssetTree
  def initialize
    @al_asset_library = ALAssetsLibrary.new
  end

  def groups
    @groups ||= Groups.new(@al_asset_library)
  end
end
