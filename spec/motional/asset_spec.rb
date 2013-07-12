# -*- encoding : utf-8 -*-

describe MotionAL::Asset do
  before do
    @library = MotionAL.library
    @existent_asset = @library.saved_photos.assets.first

    @test_group_name = 'MotionAL'
    @library.groups.create(@test_group_name)
    @test_group = @library.groups.find_by_name(@test_group_name)
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

    it "should avail group option" do
      assets_b = MotionAL::Asset.all({:group => @test_group})
      assets_a = MotionAL::Asset.all #=> sometime crash when call twice immediatly

      assets_a.size.should.equal @library.saved_photos.assets.size
      assets_a.size.should.not.equal assets_b.size
    end

    it "should avail indexset option" do
      indexset = NSMutableIndexSet.new
      (1..3).each {|n| indexset.addIndex(n) }
      assets = MotionAL::Asset.all({:indexset => indexset})
      assets.size.should.equal 3

      @library.saved_photos.assets.reload
      @library.saved_photos.assets[1].url.should.equal assets.first.url
    end

    it "should avail indexset option with order option" do
      indexset = NSMutableIndexSet.new
      (1..10).each {|n| indexset.addIndex(n) }
      assets = MotionAL::Asset.all({:indexset => indexset, :order => 'desc'})
      assets.size.should.equal 10

      @library.saved_photos.assets.reload
      @library.saved_photos.assets[1..10].reverse.first.url.should.equal assets.first.url
    end

    # TODO: filter option
    # TODO: limit and offset option
  end

  describe "#editable?" do
    it "asset is created by this App should be editable" do
      @existent_asset.should.be.editable
    end
  end

  describe "#representation" do
    it "should be default representation" do
      @existent_asset.representation.should == @existent_asset.default_representation
    end
  end
  
  

  # TODO: representation
  # TODO: video_compatible => into create video?
  # TODO: properties => convert ruby like value
  # TODO: asset_type
  # TODO: call through to the default representation's methods
end
