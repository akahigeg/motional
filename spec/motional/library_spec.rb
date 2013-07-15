# -*- coding: utf-8 -*-

describe MotionAL::Library do
  before do
    @library = MotionAL.library

    @test_group_name = 'MotionAL'
    @library.groups.reload
    @test_group = @library.groups.find_by_name(@test_group_name) 
  end

  describe ".camera_roll" do
    it "should instance of Group" do
      @library.camera_roll.should.instance_of MotionAL::Group
    end
  end

  describe ".photo_library" do
    before do
      @photo_library = @library.photo_library
    end

    it "should instance of Group" do
      @photo_library.should.instance_of MotionAL::Group
    end

    it "should be named 'Photo Library'" do
      @photo_library.name.should.equal 'Photo Library'
    end

  end

  describe ".groups" do
    it "should be kind of Array" do
      @library.groups.should.kind_of Array
    end
  end
end
