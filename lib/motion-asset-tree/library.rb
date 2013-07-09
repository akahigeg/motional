# -*- encoding : utf-8 -*-

class App
  def self.asset_library
    @@asset_library ||= MotionAssetTree.new
  end
end

module Dispatch
  def self.wait_async(duration = 0.1, &block)
    @async_done = false
    queue_group = Dispatch::Group.new
    queue = Dispatch::Queue.concurrent(:default) 

    queue.async(queue_group) { block.call }
    queue_group.notify(queue) { @async_done = true }

    CFRunLoopRunInMode(KCFRunLoopDefaultMode, duration, false) while !@async_done
    # 'queue_group.wait' is not work well. why?
  end
end

#
# App.asset_library.saved_photos.assets.each do |asset|
#   
# end
#
#
class MotionAssetTree
  def self.al_asset_library
    @@al_asset_library ||= ALAssetsLibrary.new
  end

  def al_asset_library
    self.class.al_asset_library
  end

  def initialize
  end

  def groups
    @groups ||= Groups.new(self)
  end

  def saved_photos
    @groups.find {|g| g.name == 'Saved Photos'}
  end

  def self.authorized?
    ALAssetsLibrary.authorizationStatus == ALAuthorizationStatusAuthorized
  end

  def self.disable_shared_photo_streams_support
    ALAssetsLibrary.disableSharedPhotoStreamsSupport
  end
end
