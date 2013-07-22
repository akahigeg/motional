# -*- encoding : utf-8 -*-

describe MotionAL::Asset do
  before do
    @library = MotionAL.library

    MotionAL::Asset.all do |asset, error|
      @existent_asset = asset if asset.asset_type == :photo && @existent_asset.nil?
      @existent_video_asset = asset if asset.asset_type == :video && @existent_video_asset.nil?
    end
    wait_async(0.5)

    @video_url = NSBundle.mainBundle.URLForResource('sample', withExtension:"mp4")

    @test_group_name = 'MotionAL'
    MotionAL::Group.all do |group, error|
      @test_group = group if group.name == @test_group_name
    end
    wait_async

    MotionAL::Group.camera_roll do |group, error|
      @saved_photos = group
    end
    wait_async
  end

  shared "asset creation" do
    it "should create new asset" do
      @calling_create_method.should.change do
        wait_async(0.5)
        @saved_photos.assets.count_by_filter(:all)
      end
    end
  end

  describe ".create" do
    describe "when pass a CGImage with metadata" do
      before do
        @calling_create_method = Proc.new do
          MotionAL::Asset.create(@existent_asset.full_resolution_image, @existent_asset.metadata)
        end
      end

      behaves_like "asset creation"
    end

    describe "when pass a CGImage with orientation" do
      before do
        @calling_create_method = Proc.new do
          MotionAL::Asset.create(@existent_asset.full_resolution_image, orientation: :up)
        end
      end

      behaves_like "asset creation"
    end

    describe "when pass a NSData" do
      before do
        @calling_create_method = Proc.new do
          MotionAL::Asset.create(@existent_asset.data, @existent_asset.metadata)
        end
      end

      behaves_like "asset creation"
    end

    describe "when pass a video path" do
      before do
        @calling_create_method = Proc.new do
          MotionAL::Asset.create(@video_url)
        end
      end

      behaves_like "asset creation"
    end
  end

  describe "#save_new" do
    describe "when pass a NSData" do
      before do
        @calling_create_method = Proc.new do
          @new_asset = nil
          @existent_asset.save_new(@existent_asset.data, @existent_asset.metadata) {|a| @new_asset = a }
          wait_async(1)
        end
      end

      behaves_like "asset creation"

      it "new asset have the 'original_asset'" do
        @new_asset.original_asset.filename.should == @existent_asset.filename
      end
    end

    describe "when pass a video path" do
      before do
        @calling_create_method = Proc.new do
          @new_asset = @existent_video_asset.save_new(@video_url)
        end
      end

      behaves_like "asset creation"
    end
  end

  describe "#update" do
    describe "when pass a NSData" do
      before do
        @calling_update_method = Proc.new do
          @existent_asset.update(@existent_asset.data, @existent_asset.metadata)
        end
      end

      it "should not create new asset" do
        @calling_update_method.should.not.change do
          @saved_photos.assets.count_by_filter(:all)
        end
      end
    end

    describe "when pass a video path" do
      before do
        @calling_update_method = Proc.new do
          @existent_video_asset.update(@video_url)
        end
      end

      it "should not create new asset" do
        @calling_update_method.should.not.change do
          @saved_photos.assets.count_by_filter(:all)
        end
      end
    end
  end

  describe "#find_by_url" do
    it "should return Asset object" do
      asset = nil

      MotionAL::Asset.find_by_url(@existent_asset.url) {|a| asset = a }
      wait_async(1)

      asset.should.instance_of MotionAL::Asset
    end

    it "should return nil when unknown url given" do
      url = NSURL.URLWithString("http://hogehoge")
      asset = nil

      MotionAL::Asset.find_by_url(url) {|a| asset = a }
      wait_async

      asset.should.be.nil
    end
  end

  describe "#all" do
    it "should avail order asc" do
      assets = []

      MotionAL::Asset.all(order: :asc) {|a| assets << a }
      wait_async

      assets.size.should > 1
      assets.first.url.should.equal @existent_asset.url
    end

    it "should avail order desc" do
      assets = []

      MotionAL::Asset.all(order: :desc) {|a| assets << a }
      wait_async

      assets.size.should > 1
      assets.last.url.should.equal @existent_asset.url
    end

    it "should avail group option" do
      assets_a = []
      assets_b = []

      MotionAL::Asset.all {|a| assets_a << a }
      MotionAL::Asset.all(group: @test_group) {|a| assets_b << a }
      wait_async

      assets_a.size.should.equal @saved_photos.assets.count_by_filter(:all)
      assets_a.size.should.not.equal assets_b.size
    end

    it "should avail indexset option" do
      indexset = NSMutableIndexSet.indexSetWithIndexesInRange(1..2)
      assets = []

      MotionAL::Asset.all(indexset: indexset) {|a| assets << a }
      wait_async

      assets.size.should.equal 2

      # @saved_photos.assets[1].url.should.equal assets.first.url
    end

    it "should avail indexset option with order option" do
      indexset = NSMutableIndexSet.indexSetWithIndexesInRange(1..3)
      assets = []

      MotionAL::Asset.all(indexset: indexset, order: :desc) {|a| assets << a }
      wait_async

      assets.size.should.equal 3

      # @saved_photos.assets[1..3].reverse.first.url.should.equal assets.first.url
    end

    it "should avail filter option" do
      assets = []
      photos = []

      MotionAL::Asset.all(filter: :all) {|a| assets << a }
      MotionAL::Asset.all(filter: :photo) {|a| photos << a }
      wait_async

      assets.size.should.not.equal photos.size
    end
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

  describe "#representations" do
    it "should instance of Representations" do
      @existent_asset.representations.should.instance_of MotionAL::Representations
    end

    it "should have Representation instance" do
      @existent_asset.representations.all.first.should.instance_of MotionAL::Representation
    end
  end

  describe "#asset_type" do
    it "should be human readable" do
      @existent_asset.asset_type.should.equal :photo
    end
  end

  describe "#orientation" do
    it "should be human readable" do
      @existent_asset.orientation.should.equal :up
    end
  end

  # TODO: check what is in `location`
  # TODO: treat raw image
end
