# -*- coding: utf-8 -*-

describe MotionAL::Library do
  before do
    @library = MotionAL.library

    MotionAL::Group.find_all do |group, error|
      @test_group = group if group.name == TEST_GROUP_NAME
    end
    wait_async
  end

  describe ".groups" do
    it "should be alias of MotionAL::Group" do
      @library.groups.should == MotionAL::Group
    end
  end
end
