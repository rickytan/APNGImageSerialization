Pod::Spec.new do |s|
  s.name             = 'APNGImageSerialization'
  s.version          = '0.2.4'
  s.summary          = 'A wrapper for APNG support'
  s.description      = <<-DESC
This project provide a simple way to encode and decode APNG file to animate UIImage. requires iOS 8+
                       DESC

  s.homepage         = 'https://github.com/rickytan/APNGImageSerialization'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ricky Tan' => 'ricky.tan.xin@gmail.com' }
  s.source           = { :git => 'https://github.com/rickytan/APNGImageSerialization.git', :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/rickytan'

  s.ios.deployment_target = '8.0'
  s.watchos.deployment_target = '3.0'

  s.source_files = 'APNGImageSerialization/Classes/**/*'
  s.public_header_files = 'APNGImageSerialization/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreServices', 'ImageIO'
end
