# -*- coding: utf-8 -*-

describe MotionAssetTree do
  before do
    @sample_image = File.join(File.dirname(__FILE__), 'sample.jpg')
    @library = MotionAssetTree.new

    @test_serial = Time.now.to_i.to_s
  end

  describe ".groups" do
    it "should be Array" do
      @library.groups.should.be.kind_of Array
    end

    it "should have 'find_by_url' method" do
      @library.groups.should.respond_to :find_by_url
    end

    describe ".create" do
      it "should add a group to library" do
        @library.groups.create("g_#{@test_serial}") do |group, error|
          group.valueForProperty(ALAssetsGroupPropertyURL).should == 'hoge'
        end
      end
    end
    
  end
end
