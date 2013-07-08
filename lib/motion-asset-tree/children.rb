# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Children < Array
    def load_entries
      self.clear
      self.all do |entry, error|
        if error.nil? && !entry.nil?
          self << entry
        end
      end
    end

    def reload
      load_entries
    end
  end
end
