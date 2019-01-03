Pod::Spec.new do |s|
  s.name             = 'VKMusicBypass'
  s.version          = '0.1'
  s.summary          = 'Simple library to bypass music in VK App for iPhone'

  s.homepage         = 'https://gitlab.com/danpashin/VKMusicBypass'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'danpashin' => 'admin@danpashin.ru' }
  s.source           = { :git => 'git@gitlab.com:danpashin/vkmusicbypass.git' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Classes/**/*'

  s.public_header_files = 'Classes/VKMusicBypass.h'
  s.frameworks = 'Foundation', 'StoreKit'
end
