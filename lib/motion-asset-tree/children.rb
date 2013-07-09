# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Children < Array
    def load_entries
      @done = false

      self.clear

      queue_group = Dispatch::Group.new
      queue = Dispatch::Queue.concurrent(:default) 

      queue.async(queue_group) do 
        self.all do |entry, error|
          if error.nil? && !entry.nil?
            self << entry
          end
        end
      end
      queue_group.notify(queue) { @done = true }

      CFRunLoopRunInMode(KCFRunLoopDefaultMode, 0.1, false) while !@done
      # 'queue_group.wait' is not work well
    end

    def reload
      load_entries
    end
  end
end
