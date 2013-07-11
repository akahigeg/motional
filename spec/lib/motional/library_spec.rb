# -*- coding: utf-8 -*-

describe MotionAL::Library do
  before do
    @library = MotionAL.library

    @test_group_name = 'MotionAL'
    @library.groups.reload
    @test_group = @library.groups.find_by_name(@test_group_name) 
  end

  describe ".saved_photos" do
    it "should instance of Group" do
      @library.saved_photos.should.instance_of MotionAL::Group
    end
  end

  describe ".groups" do
    it "should be kind of Array" do
      @library.groups.should.kind_of Array
    end
  end
end
