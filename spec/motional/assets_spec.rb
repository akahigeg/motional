# -*- encoding : utf-8 -*-

describe MotionAL::Assets do
  before do 
    @saved_photos = MotionAL.library.saved_photos
    @assets = @saved_photos.assets
    @test_group = MotionAL.library.groups.find_by_name('MotionAL')
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

  describe ".all" do
    it "should return assets in the group" do
      test_assets = @test_group.assets.all
      @assets.size.should.not.equal test_assets.size
    end

    it "cannot specify :group option" do
      Proc.new { @test_group.assets.all(:group => @saved_photos) }.should.raise StandardError
    end
  end
end
