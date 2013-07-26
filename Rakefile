#
# This file is for test application.
#

$:.unshift("/Library/RubyMotion/lib")
$:.unshift("#{File.dirname(__FILE__)}/lib")
require 'motion/project/template/ios'
require 'bundler'

Bundler.require(:development)

require 'motional'

Motion::Project::App.setup do |app|
  app.name = 'MotionAL'
  app.redgreen_style = :full # :focused, :full
  app.build_dir = '/tmp/build'
end
