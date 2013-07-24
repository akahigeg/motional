# MotionAL

AssetLibrary framework wrapper for RubyMotion.

*This gem is a beta quality.*

## Installation

Add this line to your application's Gemfile:

    gem 'motional'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motional

## Setup

Add this code to your application's Rakefile.

    require 'bundler'
    Bundler.require(:development)

## Headfirst

1. Save any photo to your iOS simurator's Photos.(use Safari)
2. Type `rake` on the command line.
3. Then type the below code in REPL.

---

    library = MotionAL.library

    library.open_camera_roll do |camera_roll|
      camera_roll.assets.each do |asset|
        p asset.filename
      end
    end

## Library

    # singleton for the lifetime.
    library = MotionAL.library # should not call `Motional::Library.new` directly.

    library.open_camera_roll {|group| ... }   # open Camera Roll
    library.open_photo_library {|group| ... } # open Photo Library synced from itunes

    library.groups # An alias of MotionAL::Group
    library.groups.each do |group|
      # enumerate all groups except Photo Library
    end

    library.al_asset_library # An instance of ALAssetLibrary

    MotionAL.authorized? # check permission to access Asset Library. see Settings > Privacy > Photos

### Group

    MotionAL::Group.create('MyAppAlbum') do |group|
      group.name #=> 'MyAppAlbum'
      group.url.absoluteString # save this to permanent strage
    end
    
    MotionAL::Group.find_by_url(saved_url_absolute_string) do |group|
      # accept NSURL or String 
      # asynchronous
      p group.name #=> 'MyAppAlbum'
    end

    group.assets # An instance of MotionAL::Assets
    group.assets.each {|asset| ... }
    group.assets.create(image_data, metadata) {|asset| ... }
    group.assets << some_asset

    group.al_asset_group # An instance of ALAssetGroup
    
### Asset

    MotionAL::Asset.create(image_data, metadata) do |asset|
      asset.url.absoluteString # save this to permanent strage
    end

    MotionAL::Asset.find_by_url(saved_url_absolute_string) {|asset| ... }

    asset.representations # An instance of Representations
    asset.representations.each {|rep| ... }

    asset.default_representation # An instance of MotionAL::Representation for default representation.
    asset.filename
    asset.metadata
    asset.full_resolution_image
    asset.full_screen_image
    asset.location

    asset.media_type # :photo or :video
    MotionAL.asset_types(asset.media_type) # to get objective-c constant value
    asset.orientation # :up, :down, :left...
    MotionAL.asset_orientations(asset.orientation) # to get objective-c constant value
    
    asset.al_asset # An instance of ALAsset

### Representation

    rep.al_asset_representation # An instance of ALAssetRepresentation

## How to run specs

### Preparing test data

    rake spec files=spec_helper

### Run specs

    rake spec

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Check all specs passed on your simurator (`rake spec`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
