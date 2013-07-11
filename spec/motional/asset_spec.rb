# -*- encoding : utf-8 -*-

describe MotionAL::Asset do
  before do
    @library = MotionAL.library
    @existent_asset = @library.saved_photos.assets.first
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

  describe "#find_by_url" do
    it "should return Asset object" do
      asset = MotionAL::Asset.find_by_url(@existent_asset.url)
      asset.should.instance_of MotionAL::Asset
    end

    it "should return nil when unknown url given" do
      url = NSURL.URLWithString("http://hogehoge")
      asset = MotionAL::Asset.find_by_url(url)
      asset.should.be.nil
    end
  end

  describe "#all" do
    it "should return array" do
      assets = MotionAL::Asset.all
      assets.should.kind_of Array
      assets.first.should.instance_of MotionAL::Asset
    end

    it "should avail order asc" do
      assets = MotionAL::Asset.all({:order => 'asc'})
      assets.size.should > 1
      assets.first.url.should.equal @existent_asset.url
    end

    it "should avail order desc" do
      assets = MotionAL::Asset.all({:order => 'desc'})
      assets.size.should > 1
      assets.last.url.should.equal @existent_asset.url
    end
    # TODO: order option
    # TODO: filter option
    # TODO: group option
    # TODO: indexset option
  end

  # TODO: representation
  # TODO: video_compatible => into create video?
  # TODO: editable
  # TODO: properties => convert ruby like value
  # TODO: asset_type
  # TODO: call through to the default representation's methods
end
