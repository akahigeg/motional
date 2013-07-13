# -*- encoding : utf-8 -*-

module MotionAL
  # for thread safe
  class ThreadValueStore
    @@value_store = {}
    @@store_types = {}

    def self.reserve(name, store_type = :value)
      pid = rand.to_s
      set_store_type(name, store_type)
      @@value_store[name] ||= {}
      if type_of_store_by_name(name) == :array
        @@value_store[name][pid] = []
      else
        @@value_store[name][pid] = nil
      end

      pid
    end

    def self.set(name, pid, value)
      if type_of_store_by_name(name) == :array
        @@value_store[name][pid] << value
      else
        @@value_store[name][pid] = value
      end
    end

    def self.get(name, pid)
      @@value_store[name][pid]
    end

    def self.release(name, pid)
      @@value_store[name].delete(pid)
    end

    private 
    def self.type_of_store_by_name(name)
      @@store_types[name]
    end

    # @param name [Symbol]
    # @param store_type [Symbol] :array and else
    def self.set_store_type(name, store_type)
      @@store_types[name] = store_type
    end
  end


end
