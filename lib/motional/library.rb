# -*- encoding : utf-8 -*-

module MotionAL
  class Library
    def self.instance
      Dispatch.once { @@instance ||= new }
      @@instance
    end

    def al_asset_library
      @al_asset_library ||= ALAssetsLibrary.new
    end

    def groups
      @groups ||= Groups.new(self)
    end
    alias_method :albums, :groups

    def saved_photos
      groups.find_by_name('Saved Photos')
    end

  end
end
