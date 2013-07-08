# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Groups < Array
    def initialize(al_asset_library)
      @al_asset_library = al_asset_library
      load_groups
    end

    def find_by_url(group_url, &block)
      MotionAssetTree::Group.find_by_url(group_url) do |group, error|
        block.call(group, error)
      end
    end

    def create(name, &block)
      MotionAssetTree::Group.create(name) do |group, error|
        block.call(group, error)
      end
    end

    def all(&callback)
      @al_asset_library.enumerateGroupsWithTypes(
        ALAssetsGroupAll,
        usingBlock: lambda { |al_asset_group, stop|
          group = Group.new(al_asset_group) if !al_asset_group.nil?
          callback.call(group, nil)
        },
        failureBlock: lambda { |error|
          callback.call(nil, error)
        }
      )
    end

    def load_groups
      self.clear
      self.all do |group, error|
        if error.nil? && !group.nil?
          self << group
        end
      end
    end

    def reload
      load_groups
    end
  end
end
