# -*- encoding : utf-8 -*-

class MotionAssetTree
  attr_accessor :groups
  def initialize
    @groups = Groups.new
  end

  class Groups < Array
    def find_by_url(group_url)
      l = ALAssetsLibrary.new
      l.groupForURL(
        group_url, 
        resultBlock: lambda { |group|
          callback.call(group, nil)
        },
        resultBlock: lambda { |error|
          callback.call(nil, error)
        }
      )
      # valurForProperty ALAssetsGroupPropertyURL
    end

    def create(name, &callback)
      l = ALAssetsLibrary.new
      l.addAssetsGroupAlbumWithName(
        name, 
        resultBlock: lambda { |group|
          callback.call(group, nil)
        },
        failureBlock: lambda { |error|
          callback.call(nil, error)
        }
      )
    end
  end
end
