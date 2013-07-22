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
    # @option representation_uti [String] A representation's UTI
    # @return [MotionAL::Representation]
    # @return [nil] No representation for a specified UTI.
    #
    # @example
    #   rep = asset.representations.find_by_uti(representation_uti)
    def find_by_uti(representation_uti)
      al_rep = @asset.al_asset.representationForUTI(representation_uti)
      if al_rep
        Representation.new(al_rep)
      else
        nil
      end
    end

    # Return all representations of the asset.
    #
    # @return [Array] An Array of representation.
    #
    # @example
    #   reps = asset.representations.all
    def all
      @asset.representation_utis.map {|uti| find_by_uti(uti) }
    end
  end
end
