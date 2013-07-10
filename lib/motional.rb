# -*- encoding : utf-8 -*-
unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  app.frameworks += ['AssetsLibrary']
  Dir.glob(File.join(File.dirname(__FILE__), 'motional/*rb')).each do |file|
    app.files.unshift(file)
  end
end
