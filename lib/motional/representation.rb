# -*- encoding : utf-8 -*-

class MotionAL
  class Representation
    attr_accessor :al_asset_representation
    
    def initialize(al_asset_representation)
      @al_asset_representation = al_asset_representation
    end

    def data
      ui_image = UIImage.imageWithCGImage(self.cg_image)
      if self.filename =~ /.jpe?g$/i
        NSData.dataWithData(UIImageJPEGRepresentation(ui_image, 0.0))
      elsif self.filename =~ /.png$/i
        NSData.dataWithData(UIImagePNGRepresentation(ui_image))
      else
        nil
      end
    end

    # wrapper method
    def cg_image_with_options(options = {})
      self.al_asset_representation.CGImageWithOptions(options)
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
    alias_method :name, :filename
    alias_method :cg_image, :full_resolution_image
  end

  File = Representation
end
