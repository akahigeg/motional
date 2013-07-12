# -*- encoding : utf-8 -*-

describe MotionAL::Assets do
  before do 
    @assets = MotionAL.library.saved_photos.assets
  end
  describe "self mutation methods" do
    it "should not exist" do
      @assets.should.not.respond_to :delete
      @assets.should.not.respond_to :delete_if
      @assets.should.not.respond_to :uniq!
    end
  end

  describe ".count" do
    it "should work assets filter" do
      @assets.count(:photo).should.not.equal @assets.count(:video)
    end
  end
  # filter
  #   default
  #   set
end
