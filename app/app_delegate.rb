# -*- encoding : utf-8 -*-

# for testing
class AppDelegate  
  def application(application, didFinishLaunchingWithOptions: launchOptions)  
    true  
  end  

  def test_image
    @path = "#{NSBundle.mainBundle.resourcePath}/sample.jpg"
    @url = NSURL.fileURLWithPath(@path)
    cg_image = CGImageSourceCreateWithURL(@url, nil);
  end
end
