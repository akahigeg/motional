# -*- encoding : utf-8 -*-

describe MotionAL::Group do
  before do
    @library = MotionAL.library

    @test_group_name = 'MotionAL'
    wait_async { MotionAL::Group.create(@test_group_name) }

    MotionAL::Group.all do |group, error|
      @test_group = group if group.name == @test_group_name
    end
    wait_async

    MotionAL::Group.find_by_name('Saved Photos') do |group, error|
      @builtin_group = group
    end
    wait_async

    #MotionAL::Asset.all do |asset, error|
    #  @test_asset = asset
    #end
    wait_async
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

    #it "should return nil when unknown url given" do
    #  group = MotionAL::Group.find_by_url(@test_group.assets.first.url)
    #  group.should.be.nil
    #end
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
      @builtin_group.should.not.be.editable
    end
  end

#  describe "#assets" do
#    it "should be kind of Array" do
#      @test_group.assets.should.kind_of Array
#    end
#
#    describe ".create" do
#      it "should create new asset and add that to group" do
#        call_assets_create = Proc.new do
#          original_asset = @library.camera_roll.assets.first
#          @test_group.assets.create(original_asset.full_resolution_image, original_asset.metadata)
#        end
#        call_assets_create.should.change {@test_group.assets.size}
#      end
#    end
#  end
end

