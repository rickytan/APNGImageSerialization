Pod::Spec.new do |s|
  s.name             = 'APNGImageSerialization'
  s.version          = '0.1.0'
  s.summary          = 'A short description of APNGImageSerialization.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/rickytan/APNGImageSerialization'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ricky Tan' => 'ricky.tan.xin@gmail.com' }
  s.source           = { :git => 'https://github.com/rickytan/APNGImageSerialization.git', :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/rickytan'

  s.ios.deployment_target = '8.0'

  s.source_files = 'APNGImageSerialization/Classes/**/*'
  s.public_header_files = 'APNGImageSerialization/Classes/**/*.h'
  s.frameworks = 'UIKit', 'ImageIO'
end
