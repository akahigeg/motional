# -*- encoding : utf-8 -*-

describe MotionAL::Representations do
  before do
    MotionAL::Group.find_camera_roll do |group, error|
      @saved_photos = group
    end
    wait_async(1)

    @saved_photos.assets.each do |asset|
      @asset = asset
    end
    wait_async(1)
  end

  describe "#find_by_uti" do
    it "should return Representation object" do
      @asset.representations.find_by_uti(@asset.rep.UTI) do |rep|
        @rep = rep

      end
      @rep.should.instance_of MotionAL::Representation
    end

    it "should return nil when unknown UTI given" do
      rep = @asset.representations.find_by_uti("hoge")
      rep.should.be.nil
    end
  end

  describe "#find_all" do
    before do
      @reps = []
      @asset.representations.find_all do |rep|
        @reps << rep
      end
    end

    it "should return array" do
      @reps.first.should.instance_of MotionAL::Representation
    end
  end
end
