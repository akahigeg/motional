# -*- encoding : utf-8 -*-

describe MotionAL::Representations do
  before do
    MotionAL::Group.find_camera_roll do |group, error|
      @saved_photos = group
    end
    wait_async(1)

    @saved_photos.assets.all do |asset|
      @asset = asset
    end
    wait_async(1)
  end

  describe "#find_by_uti" do
    it "should return Representation object" do
      rep = @asset.representations.find_by_uti(@asset.rep.UTI)
      rep.should.instance_of MotionAL::Representation
    end

    it "should return nil when unknown UTI given" do
      rep = @asset.representations.find_by_uti("hoge")
      rep.should.be.nil
    end
  end

  describe "#all" do
    before do
      @reps = @asset.representations.all
    end

    it "should return array" do
      @reps.should.kind_of Array
      @reps.first.should.instance_of MotionAL::Representation
    end
  end
end
