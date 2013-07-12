# -*- encoding : utf-8 -*-

class MotionAL
  class Children < Array
    # TODO: consider performance
    def load_entries(options = {})
      Dispatch.wait_async do 
        self.clear
        self.all(options) do |entry, error|
          if error.nil? && !entry.nil?
            self << entry
          end
        end
      end
    end

    def reload
      # TODO: treat options
      load_entries
    end

    private :delete, :delete_at, :delete_if, :reject!, :fill, :flatten!, 
      :insert, :keep_if, :pop, :shift, :replace, :reverse!, :rotate!, 
      :select!, :shuffle!, :slice!, :sort!, :uniq!
  end
end
