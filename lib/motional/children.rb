# -*- encoding : utf-8 -*-

class MotionAL
  # Super class for collection classes that belong to the parent object.
  #
  # It behave an array but it is disabled self mutation methods(ex. delete). 
  # This is because that iOS SDK doesn't permit third party apps to update, to remove.
  class Children < Array
    # Reload sets from ALAssetLibrary
    def reload
      load_entries
    end

    # disable self mutation methods.
    private :delete, :delete_at, :delete_if, :reject!, :fill, :flatten!, 
      :insert, :keep_if, :pop, :shift, :drop, :replace, :reverse!, :rotate!, 
      :select!, :collect!, :shuffle!, :slice!, :sort!, :uniq!, :compact!

    private
    # TODO: check performance
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
  end
end
