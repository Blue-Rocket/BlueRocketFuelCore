Pod::Spec.new do |s|

  s.name         = 'BlueRocketFuelCore'
  s.version      = '0.1'
  s.summary      = 'This framework helps to jump start iOS development.'

  s.description        = <<-DESC
                         A set of common components to jump start iOS app development.
                         DESC

  s.homepage           = 'https://github.com/Blue-Rocket/BlueRocketFuelCore'
  s.license            = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author             = { 'Shawn McKee' => 'shawn@bluerocket.us',
  							'Matt Magoffin' => 'matt@bluerocket.us' }
  s.social_media_url   = 'http://twitter.com/bluerocketinc'
  s.platform           = :ios, '8.1'
  s.source             = { :git => 'https://github.com/Blue-Rocket/BlueRocketFuelCore.git', 
                           :tag => s.version.to_s }
  
  s.requires_arc       = true

  s.default_subspecs = 'All'
  
  s.subspec 'All' do |sp|
    sp.source_files = 'Code/BlueRocketFuelCore.h'
    sp.dependency 'BlueRocketFuelCore/Core'
    sp.dependency 'BlueRocketFuelCore/Logging'
    sp.dependency 'BlueRocketFuelCore/UI'
    sp.dependency 'BlueRocketFuelCore/WebApiClient'
    sp.dependency 'BlueRocketFuelCore/WebApiClient-AFNetworking'
    sp.dependency 'BlueRocketFuelCore/WebApiClient-RestKit'
    sp.dependency 'BlueRocketFuelCore/WebApiClient-Services'
    sp.dependency 'BlueRocketFuelCore/WebApiClient-UI'
    sp.dependency 'BlueRocketFuelCore/WebRequest'
  end
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'Code/Core.h', 'Code/Core'
    sp.dependency 'BREnvironment',     '~> 1.1'
    sp.dependency 'BRCocoaLumberjack'
    sp.ios.frameworks = 'Security'
  end
  
  s.subspec 'Logging' do |sp|
    sp.source_files = 'Code/Logging.h', 'Code/Logging'
    sp.dependency 'BREnvironment',     '~> 1.1'
  end
  
  s.subspec 'UI' do |sp|
    sp.source_files = 'Code/UI.h', 'Code/UI'
    sp.dependency 'BlueRocketFuelCore/Core'
  end

  s.subspec 'WebApiClient' do |sp|
    sp.source_files = 'Code/WebApiClient-Core.h', 'Code/WebApiClient'
    sp.dependency 'BlueRocketFuelCore/Core'
	sp.dependency 'MAObjCRuntime', '~> 0.0.1'
	sp.dependency 'SOCKit',        '~> 1.1'
  end

  s.subspec 'WebApiClient-AFNetworking' do |sp|
    sp.source_files = 'Code/WebApiClient-AFNetworking.h', 'Code/WebApiClient-AFNetworking'
    sp.dependency 'BlueRocketFuelCore/WebApiClient'
    sp.dependency 'AFNetworking/NSURLSession', '~> 2.5'
  end

  s.subspec 'WebApiClient-RestKit' do |sp|
    sp.source_files = 'Code/WebApiClient-RestKit.h', 'Code/WebApiClient-RestKit'
    sp.dependency 'BlueRocketFuelCore/WebApiClient'
    sp.dependency 'RestKit/ObjectMapping', '~> 0.24'
    sp.dependency 'TransformerKit/String', '~> 0.5'
  end

  s.subspec 'WebApiClient-Services' do |sp|
    sp.source_files = 'Code/WebApiClient-Services.h', 'Code/WebApiClient-Services'
    sp.dependency 'BlueRocketFuelCore/WebApiClient'
  end

  s.subspec 'WebApiClient-UI' do |sp|
    sp.source_files = 'Code/WebApiClient-UI.h', 'Code/WebApiClient-UI'
    sp.dependency 'BlueRocketFuelCore/WebApiClient'
    sp.dependency 'BlueRocketFuelCore/UI'
    sp.dependency 'Masonry', '~> 0.6'
  end

  s.subspec 'WebRequest' do |sp|
    sp.source_files = 'Code/WebRequest.h', 'Code/WebRequest'
    sp.dependency 'BlueRocketFuelCore/Logging'
    sp.dependency 'BlueRocketFuelCore/UI'
  end

end
