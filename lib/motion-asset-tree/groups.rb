# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Groups < Children
    def initialize(asset_library)
      @asset_library = asset_library
      load_entries
    end

    def create(group_name, &block)
      if block_given?
        MotionAssetTree::Group.create(group_name) do |group, error|
          block.call(group, error)
        end
      else
        MotionAssetTree::Group.create(group_name)
      end
    end

    def find_by_url(group_url, &block)
      if block_given?
        MotionAssetTree::Group.find_by_url(group_url) do |group, error|
          block.call(group, error)
        end
      else
        MotionAssetTree::Group.find_by_url(group_url)
      end
    end

    def find_by_name(name, &block)
      MotionAssetTree::Group.find_by_name(name)
    end

    def all(&block)
      if block_given?
        MotionAssetTree::Group.all do |group, error|
          block.call(group, error)
        end
      else
        MotionAssetTree::Group.all
      end
    end

  end

  Albums = Groups
end
