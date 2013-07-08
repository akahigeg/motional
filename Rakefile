# require "bundler/gem_tasks"

#
# This file is for test application.
#

$:.unshift("/Library/RubyMotion/lib")
$:.unshift("#{File.dirname(__FILE__)}/lib")
require 'motion/project/template/ios'
require 'bundler'

Bundler.require(:development)

require 'motion-asset-tree'

Motion::Project::App.setup do |app|
  app.name = 'MotionAssetTree'
  app.redgreen_style = :full # :focused, :full
end
