# -*- encoding : utf-8 -*-

class MotionAL
  # For filtering assets in a group by asset type.
  class AssetsFilter
    # :all means no filter.
    DEFAULT_FILTER = :all

    # Set filter.
    # @param group [MotionAL::Group]
    # @param filter_name [Symbol] :all, :photo or :video
    # @note Set filter once, it is available permanently until calling `reset`.
    def self.set(group, filter_name)
      group.al_asset_group.setAssetsFilter(asset_filters[filter_name.to_sym])
    end

    # Reset filter.
    # In other words set default filter.
    # @param group [MotionAL::Group]
    def self.reset(group)
      group.al_asset_group.setAssetsFilter(asset_filters[DEFAULT_FILTER])
    end

    # @return [Hash] Human readable keys and AssetLibrary Framework constant value.
    def self.asset_filters
      {
        :all => ALAssetsFilter.allAssets,
        :photo => ALAssetsFilter.allPhotos,
        :video => ALAssetsFilter.allVideos,
      }
    end
  end
end
