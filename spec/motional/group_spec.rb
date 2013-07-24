# -*- encoding : utf-8 -*-

describe MotionAL::Group do
  before do
    MotionAL::Group.all do |group, error|
      @test_group = group if group.name == TEST_GROUP_NAME
    end

    MotionAL::Group.find_camera_roll do |group, error|
      @camera_roll = group
    end

    MotionAL::Asset.all do |asset, error|
      @test_asset = asset
    end
    wait_async(0.5)
  end

  # '.create' already tested by before section.
  
  describe ".all" do
    before do
      @group = nil
      @groups = []
      MotionAL::Group.all do |group, error|
        @group = group
        @groups << group
      end
      wait_async
    end

    it "should return Group object" do
      @groups.size.should > 0
    end

    it "should return Group object" do
      @group.should.instance_of MotionAL::Group
    end
  end

  describe ".find_by_url" do
    it "should return Group object" do
      @group = nil
      MotionAL::Group.find_by_url(@test_group.url) do |group, error|
        @group = group
      end
      wait_async
      @group.url.should.equal @test_group.url
    end
  end

  describe ".find_by_name" do
    it "can find 'Saved Photos'" do
      # TODO: analyze device or simulator, and set group name
      @group = nil
      MotionAL::Group.find_by_name('Saved Photos') do |group, error|
        @group = group
      end

      wait_async
      @group.name.should.equal 'Saved Photos'
    end

    it "regexp" do
      @group = nil
      MotionAL::Group.find_by_name(/Saved Photos|Camera Roll/) do |group, error|
        @group = group
      end

      wait_async
      @group.name.should.equal 'Saved Photos'

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
      @camera_roll.should.not.be.editable
    end
  end

  describe "#assets" do
    describe ".create" do
      it "should create new asset and add that to group" do
        call_assets_create = Proc.new do
          original_asset = @test_asset
          @test_group.assets.create(original_asset.full_resolution_image, original_asset.metadata) {|a| "do nothing" }
        end
        call_assets_create.should.change { wait_async; @test_group.assets.count }
      end
    end
  end
end

