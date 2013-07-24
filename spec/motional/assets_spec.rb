# -*- encoding : utf-8 -*-

describe MotionAL::Assets do
  before do 
    MotionAL::Asset.find_all do |asset, error|
      @existent_asset = asset if asset.asset_type == :photo && @no_group_asset.nil?
    end
    wait_async

    MotionAL::Asset.create(@existent_asset.full_resolution_image) do |created|
      @no_group_asset = created
    end

    @test_group_name = 'MotionAL'
    MotionAL::Group.find_all do |group, error|
      @test_group = group if group.name == TEST_GROUP_NAME
    end
    wait_async

    MotionAL::Group.find_camera_roll do |group, error|
      @saved_photos = group
    end
    wait_async(0.5)

    @all_assets = @saved_photos.assets
  end

  describe "#count" do
    it "should work assets filter" do
      @all_assets.count(:photo).should.not.equal @all_assets.count(:video)
      @all_assets.count(:photo).should.not.equal @all_assets.count(:all)
    end

    it "should return Fixnum" do
      @all_assets.count(:all).should.instance_of Fixnum
    end
  end

  describe "#each" do
    it "should return assets in the group" do
      test_assets = []

      @test_group.assets.each {|a| test_assets << a }
      wait_async

      @test_group.assets.count(:all).should.equal test_assets.size
    end

    it "cannot specify :group option" do
      Proc.new { @test_group.assets.each(:group => @saved_photos) }.should.raise StandardError
    end
  end
end
