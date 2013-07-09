# -*- encoding : utf-8 -*-

class MotionAssetTree
  class Representation
    attr_accessor :al_asset_representation
    
    def initialize(al_asset_representation)
      @al_asset_representation = al_asset_representation
    end

    # wrapper method
    def cg_image_with_options(options)
      self.al_asset_representation.CGImageWithOptions(options)
    end
    alias_method :cg_image, :cg_image_with_options

    def get_bytes(buffer, from, length, error = nil)
      self.al_asset_representation.getBytes(
        buffer,
        fromOffset: offset,
        length: length,
        error: error
      )
    end

    [:fullResolutionImage, :fullScreenImage,
     :orientation, :scale, :dimensions, :filename, :size, 
     :metadata, :url, :UTI].each do |method_name|
       if method_name == :UTI
         underscored_method_name = method_name
       else
         underscored_method_name = method_name.gsub(/([A-Z])/){|m| "_#{m}" }.downcase
       end
       define_method(underscored_method_name) do 
         self.al_asset_representation.send(method_name)
       end
    end
  end
end
