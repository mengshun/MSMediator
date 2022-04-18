#
# Be sure to run `pod lib lint MSMediator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MSMediator'
  s.version          = '0.1.2'
  s.summary          = 'MSMediator 是 Router 基础库'
  s.description      = <<-DESC
0.1.0 中间组件创建, 添加URL扩展, 添加Target规则及支持只有host无path调用
0.1.1 添加手动创建规则 分类
0.1.2 fix 通过URL分类添加 arry, dict 参数时 issue

                       DESC

  s.homepage         = 'https://github.com/mengshun/MSMediator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shun.meng' => '892445213@qq.com' }
  s.source           = { :git => 'https://github.com/mengshun/MSMediator.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'MSMediator/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MSMediator' => ['MSMediator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
