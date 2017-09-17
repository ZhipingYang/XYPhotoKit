Pod::Spec.new do |s|
s.name         = 'XYPhotoKit'
s.summary      = '照片选择库，提供拍照和相册两种方式，支持单选多选，数据层是PhotoKit'
s.version      = '0.0.1'
s.homepage     = "https://github.com/ZhipingYang/XYPhotoKit"
s.license      = { :type => 'CHELUN', :file => 'LICENSE' }
s.authors      = { 'XcodeYang' => 'yangzhiping@chelun.com' }
s.platform     = :ios, '8.0'
s.ios.deployment_target = '8.0'
s.source       = { :git => 'https://github.com/ZhipingYang/XYPhotoKit.git', :tag => s.version.to_s }

s.requires_arc = true

s.source_files = [
"XYPhotoKit/**/*.{h,m}",
]
s.public_header_files = [
"XYPhotoKit/**/*.h",
]
s.resources = [
"XYPhotoKit/resource/*.bundle"
]

s.frameworks = 'UIKit', 'Photos', 'AVFoundation', 'AssetsLibrary', 'AVKit'

end
