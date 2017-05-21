Pod::Spec.new do |s|
  s.name             = "GpxLocationManager"
  s.version          = "1.0.1"
  s.summary          = "GPS data from GPX files"

  s.description      = <<-DESC
GpxLocationManager allows the developer to import and use GPS data from GPX files when developing code that uses CLLocationManager. Without GpxLocationManager, the developer has just four GPS datasets to choose from in the simulator. These datasets suffer the serious shortcoming that altitudes are always 0. Unlike CLLocationManager, GpxLocationManager can optionally speed up playback of GPS datasets, allowing faster testing.
                       DESC
  s.homepage         = "https://github.com/vermont42/GpxLocationManager"
  s.license          = "MIT"
  s.author           = { "vermont42" => "vermontcoder@gmail.com" }
  s.source           = { :git => "https://github.com/vermont42/GpxLocationManager.git", :tag => s.version.to_s }
  s.social_media_url = "https://twitter.com/vermont42"
  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.source_files = "Source/GpxLocationManager.swift", "Source/GpxParser.swift", "Source/LocationManager.swift"
  s.frameworks = "CoreLocation"
end
