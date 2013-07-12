# -*- encoding : utf-8 -*-

# Bacon::Functional.default_duration = 3

class SpecHelper
  def self.prepare_initial_assets
    library = MotionAL.library

    first_image = UIImage.imageNamed('sample.jpg')
    asset = MotionAL::Asset.create(first_image.CGImage, {})

    test_group_name = 'MotionAL'

    test_group = library.groups.find_by_name(test_group_name)
    test_group = library.groups.create(test_group_name) if test_group.nil?

    test_group.assets << library.saved_photos.assets.first
    test_group.assets.reload
  end
end

SpecHelper.prepare_initial_assets

# first run after reset ios simurator settings is fail. need before_script travis ci?
