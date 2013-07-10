# -*- encoding : utf-8 -*-

class MotionAL
  class Groups < Children
    def initialize(asset_library)
      @asset_library = asset_library
      load_entries
    end

    def create(group_name, &block)
      if block_given?
        MotionAL::Group.create(group_name) do |group, error|
          block.call(group, error)
        end
      else
        MotionAL::Group.create(group_name)
      end
    end

    def find_by_url(group_url, &block)
      if block_given?
        MotionAL::Group.find_by_url(group_url) do |group, error|
          block.call(group, error)
        end
      else
        MotionAL::Group.find_by_url(group_url)
      end
    end

    def find_by_name(name, &block)
      MotionAL::Group.find_by_name(name)
    end

    def all(options = {}, &block)
      if block_given?
        MotionAL::Group.all do |group, error|
          block.call(group, error)
        end
      else
        MotionAL::Group.all
      end
    end

  end

  Albums = Groups
end
