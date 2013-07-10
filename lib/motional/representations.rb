# -*- encoding : utf-8 -*-

class MotionAL
  class Representations < Children
    def initialize(asset)
      @asset = asset
      load_entries
    end

    def find_by_uti(uti)
      @asset.al_asset.representationForUTI(uti)
    end

    def all(options = {}, &block)
      @asset.representation_utis.each do |uti|
        rep = Representation.new(find_by_uti(uti))
        block.call(rep)
      end
    end
  end

  Files = Representations
end
