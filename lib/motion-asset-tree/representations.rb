# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Representations < Array
    def initialize(asset)
      @asset = asset
      load_representations
    end

    def find_by_uti(uti)
      # representationForUTI
    end

    def all(&block)
      asset.al_representations.each do |al_rep|
        block.call(Representation.new(al_rep))
      end
    end

    def load_representations
      self.clear
      self.all do |rep, error|
        if error.nil? && !rep.nil?
          self << rep
        end
      end
    end

    def reload
      load_representations
    end
  end
end
