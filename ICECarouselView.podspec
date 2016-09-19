

Pod::Spec.new do |s|
  s.name             = 'ICECarouselView'
  s.version          = '1.0.0'
  s.summary          = '轮播图'


  s.description      = <<-DESC
TODO: 这是一个轮播图
                       DESC

  s.homepage         = 'https://github.com/My-Pod/ICECarouselView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gumengxiao' => 'rare_ice@163.com' }
  s.source           = { :git => 'https://github.com/My-Pod/ICECarouselView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.source_files = 'Classes/**/*'
end
