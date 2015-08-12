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


  s.requires_arc = true
  
  s.dependency "BREnvironment", "~> 1.1"

end
