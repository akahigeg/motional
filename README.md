# MotionAL

AssetLibrary framework wrapper for RubyMotion.

*This gem is beta quality.*

## Installation

Add this line to your application's Gemfile:

    gem 'motional'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motional

## Setup

Edit Rakefile

    require 'motional'

## Headfirst

1. Save any photo to your iOS simurator.
2. Type `rake` in your console.
3. Then type the below code in REPL.

---

    library = MotionAL.library

    library.groups

    rep = library.groups.first.assets.first.representations.first
    
    p library.groups.map { |g| g.name }.join(', ')

    camera_roll = library.camera_roll
    camera_roll.class

    new_group = library.groups.find_by_name('New Group') 
    if !new_group
      new_group = library.groups.create('New Group')
    end
    new_group.class
    library.groups.reload
    p library.groups.map { |g| g.name }.join(', ')
    same_as_new_group = library.groups.find_by_url(new_group.url)
    p same_as_new_group.name

    asset = camera_roll.assets.first

    new_group.assets.count
    new_group.assets << asset
    new_group.assets.reload
    
    rep = asset.default_representation
    rep.filename
    rep.metadata

    camera_roll.assets.count
    camera_roll.assets.reload

    new_asset = new_group.assets.create(rep.full_resolution_image, rep.metadata)
    new_asset = MotionAL::Asset.create(rep.full_resolution_image, rep.metadata)

    MotionAL::Asset.create(rep.full_resolution_image, rep.metadata) do |asset, error|
      p asset.url
    end

    another_new_asset = MotionAL::Asset.create(image, meta)

    asset = group.assets.find_by_url(asset_url)
    another_asset = MotionAL::Asset.find_by_url(asset_url)

## Library

    # singleton for a lifetime.
    library = MotionAL.library # should not call `Motional::Library.new` directly.

    library.camera_roll   # camera roll
    library.photo_library # synced from itunes

    MotionAL::Library.authorized? # check permission. see Settings > Privacy > Photos

### Groups

    library.groups.each { |group| ...}
    names = library.groups.map { |griup| group.name }

A collection of group. It basically behave an Array.

But you cannot access self mutation methods(delete, select!, etc.). It's restriction of iOS SDK.

### Group (alias of Group)
    
    Asset.all(:filter => :photo)
    Group.assets.filter(:photo).all

#### Create

    MotionAL::Group.create('group_name') # create and add to library
    
#### Find

    group = library.groups.find_by_url(group_url)
    group = library.groups.find_by_name('group_name')

`group_url` is a NSURL object.

as same.

    group = MotionAL::Group.find_by_url(group_url)
    group = MotionAL::Group.find_by_name('group_name')

    groups = group.all

### Assets

    some_group.assets.each { |asset| ... }
    urls = some_group.assets.map { |asset| asset.url }

A collection of asset in the group. It basically behave an Array.

But you cannot access self mutation methods(delete, select!, etc.). It's restriction of iOS SDK.
    
### Asset

#### Create

    group.assets.create(image, metadata) # create asset and add group
    
    asset = MotionAL::Asset.create(original_asset.full_resolution_image, original_asset.metadata)
    group.assets << asset
    
#### Find
    
    library.saved_photos.assets.each do |asset|
      p asset.default_file.name
    end
    
    library.saved_photos.photos.each do |photo|
      p photo.default_file.name # photo.filename
    end
    
    library.saved_photos.videos.each do |video|
      p video.default_file.name
    end
    
    # asynchronous

### Representations

### Representation

## Sample Code

### BubbleWrap camera sample


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
