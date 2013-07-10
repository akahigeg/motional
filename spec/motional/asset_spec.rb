# -*- encoding : utf-8 -*-

describe MotionAL::Asset do
  before do
    @library = App.asset_library
    @existent_asset = @library.saved_photos.assets.first
  end

  describe ".create" do
    it "should create new asset" do
      before_count = @library.saved_photos.assets.size

      new_asset = MotionAL::Asset.create(@existent_asset.full_resolution_image, @existent_asset.metadata)

      @library.saved_photos.assets.reload
      @library.saved_photos.assets.size.should == before_count + 1
    end
  end

  describe "#save_new" do
    before do 
      @new_asset = @existent_asset.save_new(@existent_asset.data, @existent_asset.metadata)
    end

    it "new asset have the 'original_asset'" do
      @new_asset.original_asset.filename.should == @existent_asset.filename
    end
  end

  describe "#update" do
    it "should not create new asset" do
      @library.saved_photos.assets.reload
      before_count = @library.saved_photos.assets.size

      @existent_asset.update(@existent_asset.data, @existent_asset.metadata)

      @library.saved_photos.assets.reload
      @library.saved_photos.assets.size.should == before_count
    end
  end
end
