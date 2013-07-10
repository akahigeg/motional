# -*- coding: utf-8 -*-

# サンプルアプリの方でテストすることにした

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

  describe MotionAL::Group do
    it "should work 'name' method" do
      @test_group.name.should == @test_group_name
    end

    it "should work 'url' method" do
      @test_group.url.should.instance_of NSURL
    end

    it "should be editable" do
      @test_group.should.be.editable
    end

    it "default group (not created by this app) should not be editable" do
      @library.saved_photos.should.not.be.editable
    end
  end

  describe ".assets" do
    it "should be kind of Array" do
      @test_group.assets.should.kind_of Array
    end

    describe ".create" do
      it "should create new asset and add that to group" do
        before_count = @test_group.assets.size.to_i
        original_asset = @library.saved_photos.assets.first

        new_asset = @test_group.assets.create(original_asset.full_resolution_image, original_asset.metadata)
        @test_group.assets.size.to_i.should == before_count + 1
      end
    end
  end

  describe MotionAL::Representations do
    it "should be kind of Array" do
      @test_group.assets.first.representations.should.kind_of Array
    end
  end
end
