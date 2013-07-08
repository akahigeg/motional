# -*- coding: utf-8 -*-

# サンプルアプリの方でテストすることにした

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

    # describe ".create" => SampleApp
  end

  describe MotionAssetTree::Group do
    it "should have 'name' method" do
      @library.groups.first.name.should == 'hoge'
    end
  end
end

__END__

asyncronous


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

    describe ".create" do
      it "should add a group to library" do
        before_count = @library.groups.length
        @library.groups.create("g_#{@test_serial}") do |group, error|
          group.valueForProperty(ALAssetsGroupPropertyURL).should == 'hoge'
        end
        sleep 5 #無駄ァ！
        @library.groups.reload
        @library.groups.length.should > before_count
      end
    end
    
  end
end
