# -*- coding: utf-8 -*-

describe MotionAL::Library do
  before do
    @library = MotionAL.library

    MotionAL::Group.find_all do |group, error|
      @test_group = group if group.name == TEST_GROUP_NAME
    end
    wait_async
  end

  describe ".open_camera_roll" do
    it "should find the Camera Roll" do
      camera_roll = nil
      @library.open_camera_roll do |group, error|
        camera_roll = group
      end
      wait_async(0.5)
      camera_roll.should.instance_of MotionAL::Group
    end
  end

  describe ".open_photo_library" do
    before do
      @photo_library = nil
      @library.open_photo_library do |group, error|
        @photo_library = group
      end
      wait_async
    end

    it "should instance of Group" do
      @photo_library.should.instance_of MotionAL::Group
    end

    it "should be named 'Photo Library'" do
      @photo_library.name.should.equal 'Photo Library'
    end

  end

  describe ".groups" do
    it "should be alias of MotionAL::Group" do
      @library.groups.should == MotionAL::Group
    end
  end
end
