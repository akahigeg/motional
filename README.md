# Motion::Asset::Tree

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'motional'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motional

## Usage

### Classes 

    MotionAL
    MotionAL::Group = Album
      assets, photos, videos
    MotionAL::Asset = Photo, Video
      representations, files
    MotionAL::Representation = File

### Overview

    
    library = MotionAL.library
    
    album = library.albums.first
    asset = album.assets.first
    file = photo.default_file # photo.files.first

    library.groups.first.photos.first.files.first
    
    group = MotionAL.library.groups.first
    asset = group.assets.first
    representation = asset.default_representation # asset.representations.first

### Album (Group)

#### Create

    library.albums.create('album_name')
    MotionAL::Album.create('album_name')
    
#### Find

    album = library.albums.find_by_url(album_url)
    album = library.albums.find_by_name('album_name')
    
#### Assets

    # create asset and add album
    original_assets = library.saved_photos.assets.first
    album.assets.create(original_asset.full_resolution_image, original_asset.metadata)
    
### Asset (Photo, Video)

    asset = MotionAL::Asset.create(original_asset.full_resolution_image, original_asset.metadata)
    album.assets << asset
    
    
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

### File (Representation)

#### BubbleWrap camera sample

## Sample Code

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
