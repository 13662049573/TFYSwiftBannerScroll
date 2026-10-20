Pod::Spec.new do |spec|

  spec.name         = "TFYSwiftBannerScrollKit"

  spec.version      = "3.2.0"

  spec.summary      = "Swift 无限轮播组件：自定义 Cell、页面指示器、多种卡片转场，最低 iOS 16 / Swift 5.7+。"

  spec.description  = <<-DESC
TFYSwiftBannerScrollKit 是 Swift 版无限轮播组件。
支持水平/垂直滚动、自动轮播、无限循环、自定义 Cell 与页面指示器，
内置 25 种转场动画（含扇形、飞出叠牌、翻书与网格布局），并提供 contentInsets、isPagingEnabled、
didChangeIndex 等公开 API。支持 CocoaPods、Swift Package Manager 和源码集成，
附带 12 个交互 Demo 场景。最低支持 iOS 16、Swift 5.7+，使用 Swift 5 语言模式。
                   DESC

  spec.homepage     = "https://github.com/13662049573/TFYSwiftBannerScroll"

  spec.license      = "MIT"
  
  spec.author       = { "田风有" => "420144542@qq.com" }

  spec.platform     = :ios, "16.0"

  spec.swift_version = '5.0'

  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  spec.source       = { :git => "https://github.com/13662049573/TFYSwiftBannerScroll.git", :tag => spec.version.to_s }

  spec.frameworks = "UIKit"

  spec.source_files  = "TFYSwiftBannerScroll/TFYSwiftBannerScrollKit/*.{swift}"
 
  spec.requires_arc = true
  
end
