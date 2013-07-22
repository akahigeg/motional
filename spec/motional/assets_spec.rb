# -*- encoding : utf-8 -*-

describe MotionAL::Assets do
  before do 
    @test_group_name = 'MotionAL'
    MotionAL::Group.all do |group, error|
      @test_group = group if group.name == @test_group_name
    end
    wait_async

    MotionAL::Group.camera_roll do |group, error|
      @saved_photos = group
    end
    wait_async

    @assets = @saved_photos.assets
  end

  describe "#count_by_filter" do
    it "should work assets filter" do
      @assets.count_by_filter(:photo).should.not.equal @assets.count_by_filter(:video)
      @assets.count_by_filter(:photo).should.not.equal @assets.count_by_filter(:all)
    end

    it "should return Fixnum" do
      @assets.count_by_filter(:all).should.instance_of Fixnum
    end
  end

  describe "#all" do
    it "should return assets in the group" do
      test_assets = []

      @test_group.assets.all {|a| test_assets << a }
      wait_async

      @test_group.assets.count_by_filter(:all).should.equal test_assets.size
    end

    it "cannot specify :group option" do
      Proc.new { @test_group.assets.all(:group => @saved_photos) }.should.raise StandardError
    end
  end
end
