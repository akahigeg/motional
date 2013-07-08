# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Assets < Array
    def initialize(group)
      @group = group
      self.clear
      # load_assets
    end

    # TODO support NSData and NSURL(video)
    def create(image, meta, &callback)
      # image => CGImage or NSData or NSURL(video)
      App.al_asset_library.writeImageToSavedPhotosAlbum(
        image,
        metadata: meta,
        completionBlock: lambda {|asset_url, error|
          find_by_url(asset_url) do |asset, error|
            callback.call(asset, error)
          end
        }
      )
    end

    def find_by_url(asset_url, &block)
      MotionAssetTree::Asset.find_by_url(asset_url) do |asset, error|
        block.call(asset, error)
      end
    end

    # TODO: support IndexSet
    def all(options = nil, &callback)
      if options.nil?
        @group.al_asset_group.enumerateAssetsUsingBlock(
          lambda{|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            callback.call(asset, index, stop) 
          }
        )
      elsif options[:order]
        enum_options = options[:order] == 'asc' ? NSEnumerationConcurrent : NSEnumerationReverse
        @group.al_asset_group.enumerateAssetsWithOptions(
          enum_option, 
          usingBlock: lambda {|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            callback.call(asset, index, stop) 
          }
        )
      elsif options[:indexset]
        @group.al_asset_group.enumerateAssetsAtIndexes(
          options[:indexset],
          options: enum_option, 
          usingBlock: lambda {|al_asset, index, stop| 
            asset = Asset.new(al_asset) if !al_asset.nil?
            callback.call(asset, index, stop) 
          }
        )
      end
    end

    def <<(asset)
      super
      p "add asset"
      @group.al_asset_group.addAsset(asset.al_asset)
    end

    def load_assets
      self.clear
      self.all do |asset, index, stop|
        if !asset.nil?
          self << asset
        end
      end
    end

    def reload
      load_assets
    end

    # each
  end
end
