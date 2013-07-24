# -*- encoding : utf-8 -*-

module MotionAL
  class << self
    def library
      @library ||= Library.instance
    end

    # @return [Hash] readable key and objective-c constant value
    def asset_group_types
      {
        :library      => ALAssetsGroupLibrary,
        :album        => ALAssetsGroupAlbum,
        :event        => ALAssetsGroupEvent,
        :faces        => ALAssetsGroupFaces,
        :saved_photos => ALAssetsGroupSavedPhotos,
        :photo_stream => ALAssetsGroupPhotoStream,
        :all          => ALAssetsGroupAll
      }
    end
 
    # TODO: :photo = :image, :video => :movie
    # @return [Hash] readable key and objective-c constant value
    def asset_types
      {
        :photo   => ALAssetTypePhoto,
        :video   => ALAssetTypeVideo,
        :unknown => ALAssetTypeUnknown
      }
    end
 
    # @return [Hash] readable key and objective-c constant value
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

    # @return [Hash] readable key and objective-c constant value
    def authorization_statuses
      {
        :not_determined => ALAuthorizationStatusNotDetermined,
        :restricted     => ALAuthorizationStatusRestricted,
        :denied         => ALAuthorizationStatusDenied,
        :authorized     => ALAuthorizationStatusAuthorized
      }
    end

    # @return [Hash] readable key and objective-c constant value
    def notification_keys
      {
        :updated_assets_key        => ALAssetLibraryUpdatedAssetsKey,
        :inserted_asset_groups_key => ALAssetLibraryInsertedAssetGroupsKey,
        :updated_asset_groups_key  => ALAssetLibraryUpdatedAssetGroupsKey,
        :deleted_asset_groups_key  => ALAssetLibraryDeletedAssetGroupsKey
      }
    end

    # @return [Hash] readable key and objective-c constant value
    def enumeration_options
      {
        :asc   => NSEnumerationConcurrent,
        :desc  => NSEnumerationReverse
      }
    end
    alias_method :enum_orders, :enumeration_options

    # @return [Boolean] False means that your app cannot access the asset library.
    def authorized?
      ALAssetsLibrary.authorizationStatus == authorization_statuses[:authorized]
    end

    # A simple wrapper of ALAssetsLibrary.disableSharedPhotoStreamsSupport
    def disable_shared_photo_streams_support
      ALAssetsLibrary.disableSharedPhotoStreamsSupport
    end
  end
end
