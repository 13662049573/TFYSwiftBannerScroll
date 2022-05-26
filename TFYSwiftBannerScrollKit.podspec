
Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftBannerScrollKit"

  spec.version      = "2.0.2"

  spec.summary      = "
  Swift版的 无线滚动。自定义cell,自定义圆点，支持常用的卡片类型，满足现在项目所有需求。最低支持iOS12 Swift5 以上"

  spec.description  = <<-DESC
Swift版的 无线滚动。自定义cell,自定义圆点，支持常用的卡片类型，满足现在项目所有需求。最低支持iOS12 Swift5 以上
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftBannerScroll"

  spec.license      = "MIT"
  
  spec.author       = { "田风有" => "420144542@qq.com" }

  spec.platform     = :ios, "12.0"

  spec.swift_version = '5.0'

  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftBannerScroll.git", :tag => spec.version }

  spec.source_files  = "TFYSwiftBannerScroll/TFYSwiftBannerScrollKit/*.{swift}"
 
  spec.requires_arc = true
  
end
