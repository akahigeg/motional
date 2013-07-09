# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Groups < Children
    def initialize(asset_library)
      @asset_library = asset_library
      load_entries
    end

    def find_by_url(group_url, &block)
      MotionAssetTree::Group.find_by_url(group_url) do |group, error|
        block.call(group, error)
      end
    end

    def find_by_name(name, &block)
      MotionAssetTree::Group.find_by_name(name) do |group, error|
        block.call(group, error)
      end
    end

    def create(group_name, &block)
      MotionAssetTree::Group.create(group_name) do |group, error|
        block.call(group, error)
      end
    end

    def all(&block)
      @asset_library.al_asset_library.enumerateGroupsWithTypes(
        ALAssetsGroupAll,
        usingBlock: lambda { |al_asset_group, stop|
          group = Group.new(al_asset_group) if !al_asset_group.nil?
          block.call(group, nil)
        },
        failureBlock: lambda { |error|
          block.call(nil, error)
        }
      )
    end

  end
end
