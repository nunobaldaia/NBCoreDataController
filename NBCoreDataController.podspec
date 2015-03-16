Pod::Spec.new do |s|
  s.name         = "NBCoreDataController"
  s.version      = "0.1.1"
  s.summary      = "Simple and lightweight three-layer CoreData stack for asynchronous saving"
  s.description  = <<-DESC
  				   NBCoreDataController is a simple and lightweight implementatoin of the elegant
				   three-context scheme proposed by [Marcus Zarra](http://www.cimgf.com) 
				   for asynchronous CoreData saving, as [documented by Cocoanetics](http://www.cocoanetics.com/2012/07/multi-context-coredata/).
                   DESC
  s.homepage     = "https://github.com/nunobaldaia/NBCoreDataController"
  s.license      = "MIT"
  s.author             = { "Nuno Baldaia" => "nunobaldaia@gmail.com" }
  s.social_media_url   = "http://twitter.com/nunobaldaia"
  s.source       = { :git => "https://github.com/nunobaldaia/NBCoreDataController.git", :tag => s.version.to_s }
  s.source_files = "NBCoreDataController"
  s.frameworks   = "Foundation", "CoreData"
  s.platform     = :ios, "7.0"
  s.requires_arc = true
end
