# -*- coding: utf-8 -*-

describe MotionAL do
  before do
    @library = App.asset_library

    @test_group_name = 'MotionAL'
    @library.groups.create(@test_group_name)
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

  describe MotionAL::Representations do
    it "should be kind of Array" do
      @test_group.assets.first.representations.should.kind_of Array
    end
  end
end
