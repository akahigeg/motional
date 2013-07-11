# -*- encoding : utf-8 -*-

describe MotionAL::Group do
  before do
    @library = MotionAL.library

    @test_group_name = 'MotionAL'
    @library.groups.create(@test_group_name)
    @test_group = @library.groups.find_by_name(@test_group_name)
  end

  # '.create' and '.find_by_name' already tested by before section.
  #
  describe ".find_by_url" do
    it "should return Group object" do
      g = MotionAL::Group.find_by_url(@test_group.url)
      g.should.instance_of MotionAL::Group
    end

    it "should return nil when unknown url given" do
      g = MotionAL::Group.find_by_url(@test_group.assets.first.url)
      g.should.be.nil
    end
  end

  describe "#url" do
    it "should return NSURL object" do
      @test_group.url.should.instance_of NSURL
    end
  end

  describe "#asset_group_type" do
    it "should be human readable" do
      @test_group.asset_group_type.should.instance_of Symbol
    end
  end

  describe "#editable?" do
    it "group is created by this App should be editable" do
      @test_group.should.be.editable
    end

    it "default group (not created by this App) should not be editable" do
      @library.saved_photos.should.not.be.editable
    end
  end

  describe "#assets" do
    it "should be kind of Array" do
      @test_group.assets.should.kind_of Array
    end

    describe ".create" do
      it "should create new asset and add that to group" do
        call_assets_create = Proc.new do
          original_asset = @library.saved_photos.assets.first
          @test_group.assets.create(original_asset.full_resolution_image, original_asset.metadata)
        end
        call_assets_create.should.change {@test_group.assets.size}
      end
    end
  end
end

