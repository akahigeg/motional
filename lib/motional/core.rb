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
  class << self
    def library
      Library.instance
    end
 
    def asset_types
      {
        :photo   => ALAssetTypePhoto,
        :video   => ALAssetTypeVideo,
        :unknown => ALAssetTypeUnknown
      }
    end
 
    def asset_orientations
      {
        :up             => ALAssetOrientationUp,
        :down           => ALAssetOrientationDown,
        :left           => ALAssetOrientationLeft,
        :right          => ALAssetOrientationRight,
        :up_mirrored    => ALAssetOrientationUpMirrored,
        :down_mirrored  => ALAssetOrientationDownMirrored,
        :left_mirrored  => ALAssetOrientationLeftMirrored,
        :right_mirrored => ALAssetOrientationRightMirrored
      }
    end

    def authorization_statuses
      {
        :not_determined => ALAuthorizationStatusNotDetermined,
        :restricted     => ALAuthorizationStatusRestricted,
        :denied         => ALAuthorizationStatusDenied,
        :authorized     => ALAuthorizationStatusAuthorized
      }
    end

    def notification_keys
      {
        :updated_assets_key        => ALAssetLibraryUpdatedAssetsKey,
        :inserted_asset_groups_key => ALAssetLibraryInsertedAssetGroupsKey,
        :updated_asset_groups_key  => ALAssetLibraryUpdatedAssetGroupsKey,
        :deleted_asset_groups_key  => ALAssetLibraryDeletedAssetGroupsKey
      }
    end

    def authorized?
      ALAssetsLibrary.authorizationStatus == authorization_statuses[:authorized]
    end

    def disable_shared_photo_streams_support
      ALAssetsLibrary.disableSharedPhotoStreamsSupport
    end
  end
end
