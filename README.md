# MotionAL

AssetLibrary framework wrapper for RubyMotion.

## Installation

Add this line to your application's Gemfile:

    gem 'motional'

And then execute:

    $ bundle

## Setup

Add this code to your application's Rakefile.

    require 'bundler'
    Bundler.require(:development)

## Overview

### Library

    # singleton for the lifetime.
    library = MotionAL.library # should not call `Motional::Library.new` directly.

    library.groups # An alias of MotionAL::Group
    library.groups.each do |group|
      # asynchronous
      # enumerate all groups except Photo Library
    end

    # open Camera Roll
    library.groups.find_camera_roll do |group| 
      # asynchronous    
      group.assets.each do |asset|
        # enumerate all assets in the camera roll
      end
    end

    # open Photo Library synced from itunes
    library.groups.find_photo_library {|group| ... # asynchronous }

    library.al_asset_library # An instance of ALAssetLibrary

    MotionAL.authorized? # check permission to access Asset Library. see Settings > Privacy > Photos

### Group

    MotionAL::Group.create('MyAppAlbum') do |group|
      # asynchronous
      group.name #=> 'MyAppAlbum'
      group.url.absoluteString # save this to permanent strage
    end
    
    MotionAL::Group.find_by_url(saved_url_absolute_string) do |group|
      # accept NSURL or String 
      # asynchronous
      p group.name #=> 'MyAppAlbum'
    end

    group.assets # An instance of MotionAL::Assets
    group.assets.each {|asset| ... # asynchronous }
    group.assets.create(image_data, metadata) {|asset| ... # asynchronous } # create asset and add to the group
    group.assets << some_asset # an asset add to the group.

    group.al_asset_group # An instance of ALAssetGroup
    
### Asset

    MotionAL::Asset.create(image_data, metadata) do |asset|
      asset.url.absoluteString # save this to permanent strage
    end

    MotionAL::Asset.find_by_url(saved_url_absolute_string) {|asset| ...  # asynchronous }

    MotionAL::Asset.find_all(order: :desc) {|asset| ...  # asynchronous }
    MotionAL::Asset.find_all(filter: :photo) {|asset| ...  # asynchronous }
    MotionAL::Asset.find_all(group: @group) {|asset| ...  # asynchronous }

    indexset = NSMutableIndexSet.indexSetWithIndexesInRange(1..3)
    MotionAL::Asset.find_all(indexset: indexset) {|asset| ...  # asynchronous }
    MotionAL::Asset.find_all(indexset: indexset, order: :desc) {|asset| ...  # asynchronous }

    asset.representations # An instance of Representations
    asset.representations.each {|rep| ... # not asynchronous }

    asset.default_representation # An instance of MotionAL::Representation for default representation.

    # properties
    asset.location
    asset.asset_type # :photo or :video
    MotionAL.asset_types(asset.asset_type) # to get objective-c constant value
    asset.orientation # :up, :down, :left...
    MotionAL.asset_orientations(asset.orientation) # to get objective-c constant value

    # default representation properties
    asset.filename
    asset.metadata
    asset.full_resolution_image
    asset.full_screen_image
    
    asset.al_asset # An instance of ALAsset

### Representation

    # properties
    rep.filename
    rep.metadata
    rep.full_resolution_image
    rep.full_screen_image

    rep.al_asset_representation # An instance of ALAssetRepresentation

## Sample App

[akahigeg/motional-sample](https://github.com/akahigeg/motional-sample)

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
