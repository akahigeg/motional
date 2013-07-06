# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Asset
    def representations
      # キャッシュ＆遅延読み込み
    end

    def self.find_by_url(asset_url, &callback)
      App.al_asset_library.library.assetForURL(
        asset_url, 
        resultcallback: lambda {|asset|
          callback.call(asset, nil)
        }, 
        failurecallback: lambda {|error|
          callback.call(nil, error)
        }
      )
    end
  end
end
