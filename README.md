# MotionAL

AssetLibrary framework wrapper for RubyMotion.

## Installation

Add this line to your application's Gemfile:

    gem 'motional'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install motional

## Usage

### Headfirst
    
    library = MotionAL.library
    library.albums.first.photos.first.files.first
    library.albums.each do |album|
      albums.assets.each do |asset|
        asset.files do |file|
          p file.filename
        end
      end
    end
    
    album = library.albums.first
    asset = album.assets.first
    file = photo.default_file # photo.files.first

    library.saved_photos

    new_album = library.albums.create('new_album_name')
    album = library.albums.find_by_url(album_url)

    new_asset = album.assets.create(image, meta)
    asset = album.assets.find_by_url(asset_url)
    
as same.

    group = MotionAL.library.groups.first
    asset = group.assets.first
    representation = asset.default_representation # asset.representations.first

### Library

    library = MotionAL.library # `Motional::Library.new` is not recommented.
    library.saved_photos # library.albums.find_by_name('Saved Photos')

    MotionAL::Library.authorized?

#### Albums

    library.albums.each {...}

`albums` is a kind of Array.
But if delete it or update it that does not affect AssetLibrary (It's restriction of iOS SDK)

### Album (alias of Group)
    
    Asset.all(:filter => :photo)
    Album.assets.filter(:photo).all

#### Create

    library.albums.create('album_name') # create and add library

as same.

    MotionAL::Album.create('album_name') # create and add library
    
#### Find

    album = library.albums.find_by_url(album_url)
    album = library.albums.find_by_name('album_name')

`album_url` is a NSURL object.

as same.

    album = Album.find_by_url(album_url)
    album = Album.find_by_name('album_name')

    albums = Album.all

#### Assets (also: Photos, Viedos)
    
    urls = album.assets.map {|a| a.url }
    album.assets.each {...}

`assets` is a kind of Array.
But if delete it or update it that does not affect AssetLibrary (It's restriction of iOS SDK)

### Asset (also: Photo, Video)

#### Create

    album.assets.create(image, metadata) # create asset and add album
    
    asset = MotionAL::Asset.create(original_asset.full_resolution_image, original_asset.metadata)
    album.assets << asset
    
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

### File (alias of Representation)

#### BubbleWrap camera sample

## Sample Code

## Classes overview

    MotionAL
    MotionAL::Group = Album
      assets, photos, videos
    MotionAL::Asset = Photo, Video
      representations, files
    MotionAL::Representation = File

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
