# -*- encoding : utf-8 -*-

# first run after reset ios simurator settings is fail. need before_script travis ci?
#
# rake spec files=spec_helper
#

describe "prepare" do
  before do
    library = MotionAL.library

    first_image = UIImage.imageNamed('sample.jpg')
    MotionAL::Asset.create(first_image.CGImage, {})

    video_url = NSBundle.mainBundle.URLForResource('sample', withExtension:"mp4")
    MotionAL::Asset.create(video_url)

    test_group_name = 'MotionAL'

    test_group = library.groups.find_by_name(test_group_name)
    test_group = library.groups.create(test_group_name) if test_group.nil?

    test_group.assets << library.saved_photos.assets.first
    test_group.assets.reload
  end

  it "dummy spec for waiting creating test files" do
    1.should == 1
  end
end
