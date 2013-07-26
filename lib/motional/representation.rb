# -*- encoding : utf-8 -*-

module MotionAL
  #
  # A wrapper of ALRepresentation class.
  #
  #   An ALAssetRepresentation object encapsulates one of the representations of a given ALAsset object.
  #   A given asset in the library may have more than one representation. For example, if a camera provides RAW and JPEG versions of an image, the resulting asset will have two representations—one for the RAW file and one for the JPEG file.
  #
  # And added some convinience methods.
  #
  class Representation
    attr_reader :asset, :al_asset_representation
    
    # @param asset [MotionAL::Asset] A parent asset.
    # @param al_asset_representation [ALAssetRepresentation] An instance of ALAssetRepresentation.
    def initialize(asset, al_asset_representation)
      @asset = asset
      @al_asset_representation = al_asset_representation
    end

    # return a NSConcreteData(kind of NSData) object for the representation file.
    #
    # support only jpeg and png.
    #
    # @return [NSConcreteData]
    def data
      ui_image = UIImage.imageWithCGImage(self.cg_image)
      if self.filename =~ /.jpe?g$/i
        NSData.alloc.initWithData(UIImageJPEGRepresentation(ui_image, 0.0))
      elsif self.filename =~ /.png$/i
        NSData.alloc.initWithData(UIImagePNGRepresentation(ui_image))
      else
        nil
      end
    end

    # @param options [Hash] described for CGImageSourceCreateWithData or CGImageSourceCreateWithURL.
    # @return [CGImageRef] A full resolution CGImage of the representation.
    def cg_image_with_options(options)
      @al_asset_representation.CGImageWithOptions(options)
    end

    # The orientation of the representation.
    #
    # @return [Symbol] :up, :down :left, :right, :up_mirrored, :down_mirrored, :left_mirrored or :right_mirrored
    #
    # @see MotionAL.asset_orientations
    def orientation
      MotionAL.asset_orientations.key(@al_asset.valueForProperty(ALAssetPropertyOrientation))
    end

    # A CGImage of the representation.
    #
    # @return [CGImageRef] 
    # @return [nil] When the representation has no CGImage.
    def full_resolution_image
      @al_asset_representation.fullResolutionImage
    end
    alias_method :cg_image, :full_resolution_image

    # A CGImage of the representation that is appropriate for displaying full screen.
    #
    # @return [CGImageRef]
    # @return [nil] When the representation has no CGImage.
    def full_screen_image
      @al_asset_representation.fullScreenImage
    end

    # Metadata of the representation.
    #
    # @return [Hash] A multidimensional hash.
    # @return [nil] When the representation has no metadata or incompatible metadata.
    def metadata
      @al_asset_representation.metadata
    end

    class << self
      private
      # wrapper for method
      # @!macro [attach] make_wrapper
      #   The representation's $1
      #
      #   @method $1
      #   @return [$2]
      def make_wrapper_for_method(method_name, type_of_return)
        define_method(method_name) do 
          @al_asset_representation.send(method_name)
        end
      end
    end

    make_wrapper_for_method(:scale, "Float")
    make_wrapper_for_method(:dimensions, "CGSize")
    make_wrapper_for_method(:filename, "String")
    make_wrapper_for_method(:size, "Fixnum")
    make_wrapper_for_method(:url, "NSURL")
    make_wrapper_for_method(:UTI, "String")
    alias_method :name, :filename
  end
end
