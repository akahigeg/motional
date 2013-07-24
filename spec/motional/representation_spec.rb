# -*- encoding : utf-8 -*-

describe MotionAL::Representation do
  before do
    MotionAL::Group.find_camera_roll do |group, error|
      @saved_photos = group
    end
    wait_async(0.5)

    @saved_photos.assets.each(filter: :photo) do |asset|
      @asset = asset
    end
    wait_async(0.5)

    @rep = @asset.rep
  end

  describe ".data" do
    it "should return NSConcreteData(kind of NSData)" do
      @rep.data.should.kind_of NSData
    end
  end

  describe ".cg_image" do
    it "should return something except nil. maybe CGImageRef" do
      @rep.cg_image.should.not.nil
    end
  end

  describe ".filename" do
    it "should return filename" do
      @rep.filename.should.match /jpg$|png$|mp4$/i
    end
  end

  # what's UTI?
  describe ".UTI" do
    it "should return public.jpeg?" do
      @rep.UTI.should.match /public.jpeg|public.mpeg-4/i
    end
  end

  describe ".metadata" do
    it "should return metadata" do
      @rep.metadata.should.kind_of Hash
    end

  end

  describe ".url" do
    it "should return NSURL object" do
      @rep.url.should.kind_of NSURL
    end
  end

  # TODO: meta will be more handy
end
