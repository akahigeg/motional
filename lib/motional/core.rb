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
    # some bug exist. when try 'duration = 0.01' app crash down sometime.
  end
end

module MotionAL
  class << self
    def library
      Library.instance
    end

    # readable key and objective-c constant value
    # @return [Hash]
    def asset_group_types
      {
        :library      => ALAssetsGroupLibrary,
        :album        => ALAssetsGroupAlbum,
        :event        => ALAssetsGroupEvent,
        :faces        => ALAssetsGroupFaces,
        :photos       => ALAssetsGroupSavedPhotos,
        :photo_stream => ALAssetsGroupPhotoStream,
        :all          => ALAssetsGroupAll
      }
    end
 
    # @return [Hash]
    def asset_types
      {
        :photo   => ALAssetTypePhoto,
        :video   => ALAssetTypeVideo,
        :unknown => ALAssetTypeUnknown
      }
    end
 
    # @return [Hash]
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

    # @return [Hash]
    def authorization_statuses
      {
        :not_determined => ALAuthorizationStatusNotDetermined,
        :restricted     => ALAuthorizationStatusRestricted,
        :denied         => ALAuthorizationStatusDenied,
        :authorized     => ALAuthorizationStatusAuthorized
      }
    end

    # @return [Hash]
    def notification_keys
      {
        :updated_assets_key        => ALAssetLibraryUpdatedAssetsKey,
        :inserted_asset_groups_key => ALAssetLibraryInsertedAssetGroupsKey,
        :updated_asset_groups_key  => ALAssetLibraryUpdatedAssetGroupsKey,
        :deleted_asset_groups_key  => ALAssetLibraryDeletedAssetGroupsKey
      }
    end

    # @return [Boolean]
    # @note false means that your app cannot access the asset library.
    def authorized?
      ALAssetsLibrary.authorizationStatus == authorization_statuses[:authorized]
    end

    # A simple wrapper of ALAssetsLibrary.disableSharedPhotoStreamsSupport
    def disable_shared_photo_streams_support
      ALAssetsLibrary.disableSharedPhotoStreamsSupport
    end
  end
end
