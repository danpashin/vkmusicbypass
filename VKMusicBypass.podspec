Pod::Spec.new do |s|
  s.name             = 'VKMusicBypass'
  s.version          = '0.4'
  s.summary          = 'Simple library to bypass music in VK App for iPhone'

  s.homepage         = 'https://gitlab.com/danpashin/VKMusicBypass'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'danpashin' => 'admin@danpashin.ru' }
  s.source           = { :git => 'git@github.com:danpashin/vkmusicbypass.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Classes/**/*'

  s.public_header_files = 'Classes/Public/*.h'
  s.frameworks = 'Foundation', 'StoreKit'
end
