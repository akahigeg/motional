# -*- encoding : utf-8 -*-

# first run after reset ios simurator settings is fail. need before_script travis ci?
#
# rake spec files=spec_helper
#

TEST_GROUP_NAME = 'MotionAL'

describe "prepare" do
  before do
    library = MotionAL.library

    first_image = UIImage.imageNamed('sample.jpg')
    MotionAL::Asset.create(first_image.CGImage, {}) {|a| @test_asset = a }

    video_url = NSBundle.mainBundle.URLForResource('sample', withExtension:"mp4")
    MotionAL::Asset.create(video_url)

    library.groups.find_by_name(TEST_GROUP_NAME) {|g| @test_group = g }
    wait_async

    if !@test_group
      MotionAL::Group.create(TEST_GROUP_NAME) {|g| @test_group = g }
    end

    MotionAL::Group.find_camera_roll {|g| @camera_roll = g }
    wait_async(0.5)

    @test_group.assets << @test_asset
  end

  it "dummy spec for waiting creating test files" do
    1.should == 1
  end
end

WAIT_ASYNC_DEFAULT_DURATION = 0.1

def wait_async(duration = WAIT_ASYNC_DEFAULT_DURATION, &block)
  CFRunLoopRunInMode(KCFRunLoopDefaultMode, duration, false)
end
