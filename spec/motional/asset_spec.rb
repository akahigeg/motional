# -*- encoding : utf-8 -*-

describe MotionAL::Asset do
  before do
    @library = App.asset_library
    @existent_asset = @library.saved_photos.assets.first
    # TODO: to pass when saved_photos.assets is empty
  end

  shared "asset creation" do
    it "should create new asset" do
      @calling_create_method.should.change do
        @library.saved_photos.assets.reload
        @library.saved_photos.assets.size
      end
    end
  end

  describe ".create" do
    # TODO: create video
    # TODO: create image from image_data
    # TODO: create image with orientation
    before do
      @calling_create_method = Proc.new do
        MotionAL::Asset.create(@existent_asset.full_resolution_image, @existent_asset.metadata)
      end
    end

    behaves_like "asset creation"
  end

  describe "#save_new" do
    # TODO: save_new video
    before do
      @calling_create_method = Proc.new do
        @new_asset = @existent_asset.save_new(@existent_asset.data, @existent_asset.metadata)
      end
    end

    behaves_like "asset creation"

    it "new asset have the 'original_asset'" do
      @new_asset.original_asset.filename.should == @existent_asset.filename
    end
  end

  describe "#update" do
    # TODO: update video
    before do
      @calling_update_method = Proc.new do
        @existent_asset.update(@existent_asset.data, @existent_asset.metadata)
      end
    end

    it "should not create new asset" do
      @calling_update_method.should.not.change do
        @library.saved_photos.assets.reload
        @library.saved_photos.assets.size
      end
    end
  end

  describe ".find_by_url" do
    # TODO: order option
    # TODO: filter option
    # TODO: group option
    # TODO: indexset option
  end

  # TODO: all
  # TODO: representation
  # TODO: video_compatible => into create video?
  # TODO: editable
  # TODO: alias, shortcut
  # TODO: properties => convert ruby like value
  # TODO: asset_type
  # TODO: call through to the default representation's methods
end
