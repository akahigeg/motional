# -*- encoding : utf-8 -*-

describe MotionAL::Representations do
  before do
    @asset = MotionAL.library.saved_photos.assets.first
  end

  it "should be kind of Array" do
    @asset.representations.should.kind_of Array
  end

  # find_by_uti
  # all
end
