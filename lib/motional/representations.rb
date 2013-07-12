# -*- encoding : utf-8 -*-

class MotionAL
  class Representations < Children
    def initialize(asset)
      @asset = asset
      load_entries
    end

    def find_by_uti(uti)
      al_rep = @asset.al_asset.representationForUTI(uti)
      if al_rep
        Representation.new(al_rep)
      else
        nil
      end
    end

    def all(options = {}, &block)
      @found_representations = []
      if block_given?
        origin_all(options, block)
      else
        Dispatch.wait_async { origin_all(options) }
        return @found_representations
      end
    end

    private
    def origin_all(options, callback = nil)
      @asset.representation_utis.each do |uti|
        rep = Representation.new(find_by_uti(uti))
        @found_representations << rep
        callback.call(rep) if callback
      end
    end
  end

  Files = Representations
end
