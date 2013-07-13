# -*- encoding : utf-8 -*-

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

module MotionAL
  def self.library
    Library.instance
  end

  class Library
    def self.instance
      Dispatch.once { @@instance ||= new }
      @@instance
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
end
