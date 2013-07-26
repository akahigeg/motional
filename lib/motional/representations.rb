# -*- encoding : utf-8 -*-

module MotionAL
  #
  # A collection of representations. 
  # Representations belongs to the asset.
  #
  class Representations
    # @param asset [MotionAL::Asset]
    def initialize(asset)
      @asset = asset
    end

    # Find a representation by a specified representation UTI.
    #
    # @param representation_uti [String] A representation's UTI
    # @return [nil]
    #
    # @yield [representation]
    # @yieldparam representation [MotionAL::Representation] A found representation.
    #
    # @example
    #   asset.representations.find_by_uti(representation_uti) do |rep|
    #     p rep.filename
    #   end
    def find_by_uti(representation_uti, &block)
      al_rep = @asset.al_asset.representationForUTI(representation_uti)
      if al_rep
        block.call(Representation.new(@asset, al_rep))
      else
        nil # not found
      end
    end

    # Find and enumerate representations of the asset.
    #
    # @return [nil]
    #
    # @yield [representation]
    # @yieldparam representation [MotionAL::Representation] A found representation.
    #
    # @example
    #   asset.representations.find_all do |rep|
    #     p rep.filename
    #   end
    def find_all(&block)
      @asset.representation_utis.each do |uti|
        find_by_uti(uti) do |rep|
          block.call(rep)
        end
      end
    end
    alias_method :each, :find_all
  end
end
