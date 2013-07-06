# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Asset
    def representations
      # キャッシュ＆遅延読み込み
    end

    def self.find_by_url(asset_url, &callback)
      ap asset_url
      App.al_asset_library.assetForURL(
        asset_url, 
        resultBlock: lambda {|asset|
          callback.call(asset, nil)
        }, 
        failureBlock: lambda {|error|
          callback.call(nil, error)
        }
      )
    end
  end
end
