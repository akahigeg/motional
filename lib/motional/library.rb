# -*- encoding : utf-8 -*-

class App
  def self.asset_library
    @@asset_library ||= MotionAL.new # TODO: singleton
  end
end

module Dispatch
  def self.wait_async(duration = 0.15, &block)
    @async_done = false
    queue_group = Dispatch::Group.new
    queue = Dispatch::Queue.concurrent(:default) 

    queue.async(queue_group) { block.call }
    queue_group.notify(queue) { @async_done = true }

    CFRunLoopRunInMode(KCFRunLoopDefaultMode, duration, false) while !@async_done
    # 'queue_group.wait' is not work well. why?
    # timing bug exist. try 'duration = 0.01'
  end
end

# MotionAL
# MotionAL::Group = Album
#   assets, photos, videos
# MotionAL::Asset = Photo, Video
#   representations, files
# MotionAL::Representation = File
#
# エイリアスの方がわかりやすいのでそっちを主とする
#
# library = MotionAL.library
# library.saved_photos
#
# album = MotionAL.library.albums.first
# photo = album.photos.first
# file = photo.default_file # photo.files.first
#
# MotionAL.library.groups.first.photos.first.files.first
#
# group = MotionAL.library.groups.first
# asset = group.assets.first
# representation = asset.default_representation # asset.representations.first
#
# library.albums.create('album_name')
# MotionAL::Album.create('album_name')
#
# album = library.albums.find_by_url(album_url)
# album = library.albums.find_by_name('album_name')
#
# # create asset and add album
# original_assets = library.saved_photos.assets.first
# album.assets.create(original_asset.full_resolution_image, original_asset.metadata)
#
# asset = MotionAL::Asset.create(original_asset.full_resolution_image, original_asset.metadata)
# album.assets << asset
#
# # BubbleWrap camera sample
#
# library.saved_photos.assets.each do |asset|
#   p asset.default_file.name
# end
# 
# library.saved_photos.photos.each do |photo|
#   p photo.default_file.name # photo.filename
# end
#
# library.saved_photos.videos.each do |video|
#   p video.default_file.name
# end
#
# # asynchronous
#
class MotionAL
  # TODO: singleton
  def self.library
    @@library ||= self.new
  end

  def initialize
  end

  def al_asset_library
    @al_asset_library ||= ALAssetsLibrary.new
  end

  def groups
    @groups ||= Groups.new(self)
  end
  alias_method :albums, :groups

  def saved_photos
    groups.find_by_name('Saved Photos')
  end

  def authorized?
    ALAssetsLibrary.authorizationStatus == ALAuthorizationStatusAuthorized
  end

  def disable_shared_photo_streams_support
    ALAssetsLibrary.disableSharedPhotoStreamsSupport
  end
end
