
Pod::Spec.new do |s|

  s.name         = "BlueRocketFuelCore"
  s.version      = "0.1"
  s.summary      = "This framework helps to jump start iOS development."

  s.description  = <<-DESC
                   A longer description of BlueRocketFuelCore in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/Blue-Rocket/BlueRocketFuelCore"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "Shawn McKee" => "shawn@bluerocket.us" }
  s.social_media_url   = "http://twitter.com/bluerocketinc"
  s.platform     = :ios, "8.1"
  s.source       = { :git => "https://github.com/Blue-Rocket/BlueRocketFuelCore.git", :tag => "0.1" }
  s.source_files  = "BlueRocketFuelCore/**/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"
  #s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
  s.requires_arc = true
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
