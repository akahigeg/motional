# -*- encoding : utf-8 -*-

@first_image = UIImage.imageNamed('sample.jpg')
MotionAL::Asset.create(@first_image.CGImage, {})
