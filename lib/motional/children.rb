# -*- encoding : utf-8 -*-

class MotionAL
  class Children < Array
    # TODO: consider performance
    def load_entries
      Dispatch.wait_async do 
        self.clear
        self.all do |entry, error|
          if error.nil? && !entry.nil?
            self << entry
          end
        end
      end
    end

    def reload
      load_entries
    end
  end
end
