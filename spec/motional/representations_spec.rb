# -*- encoding : utf-8 -*-

describe MotionAL::Representations do
  before do
    @asset = MotionAL.library.saved_photos.assets.first
  end

  it "should be kind of Array" do
    @asset.representations.should.kind_of Array
  end

  describe ".find_by_uti" do
    it "should return Representation object" do
      rep = @asset.representations.find_by_uti(@asset.rep.UTI)
      rep.should.instance_of MotionAL::Representation
    end

    it "should return nil when unknown UTI given" do
      rep = @asset.representations.find_by_uti("hoge")
      rep.should.be.nil
    end
  end

  describe ".all" do
    before do
      @reps = @asset.representations.all
    end

    it "should return array" do
      @reps.should.kind_of Array
      @reps.first.should.instance_of MotionAL::Representation
    end
  end
end
