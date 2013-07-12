# -*- encoding : utf-8 -*-

class MotionAL
  class AssetsFilter
    DEFAULT_FILTER = :all

    # filter_name :all, :photo, :video
    def self.set(group, filter_name)
      group.al_asset_group.setAssetsFilter(asset_filters[filter_name.to_sym])
    end

    def self.unset(group)
      group.al_asset_group.setAssetsFilter(asset_filters[DEFAULT_FILTER])
    end

    def self.asset_filters
      {
        :all => ALAssetsFilter.allAssets,
        :photo => ALAssetsFilter.allPhotos,
        :video => ALAssetsFilter.allVideos,
      }
    end

  end
end
