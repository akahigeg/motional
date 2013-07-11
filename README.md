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

TODO: Write usage instructions here

sample code

    MotionAL
    MotionAL::Group = Album
      assets, photos, videos
    MotionAL::Asset = Photo, Video
      representations, files
    MotionAL::Representation = File
    
    エイリアスの方がわかりやすいのでそっちを主とする
    
    library = MotionAL.library
    library.saved_photos
    
    album = MotionAL.library.albums.first
    photo = album.photos.first
    file = photo.default_file # photo.files.first
    
    MotionAL.library.groups.first.photos.first.files.first
    
    group = MotionAL.library.groups.first
    asset = group.assets.first
    representation = asset.default_representation # asset.representations.first
    
    library.albums.create('album_name')
    MotionAL::Album.create('album_name')
    
    album = library.albums.find_by_url(album_url)
    album = library.albums.find_by_name('album_name')
    
    # create asset and add album
    original_assets = library.saved_photos.assets.first
    album.assets.create(original_asset.full_resolution_image, original_asset.metadata)
    
    asset = MotionAL::Asset.create(original_asset.full_resolution_image, original_asset.metadata)
    album.assets << asset
    
    # BubbleWrap camera sample
    
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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
