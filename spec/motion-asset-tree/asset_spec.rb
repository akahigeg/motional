# -*- encoding : utf-8 -*-

describe MotionAssetTree::Asset do
  before do
    @library = App.asset_library
  end

  describe ".create" do
    it "should create new asset" do
      before_count = @library.saved_photos.assets.size
      original_asset = @library.saved_photos.assets.first

      new_asset = MotionAssetTree::Asset.create(original_asset.full_resolution_image, original_asset.metadata)
      @library.saved_photos.assets.reload
      @library.saved_photos.assets.size.should == before_count + 1
    end

  end
end
