# -*- encoding : utf-8 -*-

describe MotionAL::Assets do
  describe "self mutation methods" do
    it "should not exist" do
      MotionAL.library.saved_photos.assets.should.not.respond_to :delete
      MotionAL.library.saved_photos.assets.should.not.respond_to :delete_if
      MotionAL.library.saved_photos.assets.should.not.respond_to :uniq!
    end
  end
  # filter
  #   default
  #   set
end
