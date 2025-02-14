# TFYSwiftBannerScroll

<p align="center">
    <img src="banner.png" alt="TFYSwiftBannerScroll" title="TFYSwiftBannerScroll" width="557"/>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-Swift%205.0+-f48041.svg?style=flat"></a>
    <a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS%2012.0+-blue.svg?style=flat"></a>
    <a href="https://github.com/13662049573/TFYSwiftBannerScroll/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
    <a href="https://cocoapods.org/pods/TFYSwiftBannerScroll"><img src="https://img.shields.io/cocoapods/v/TFYSwiftBannerScroll.svg?style=flat"></a>
    <a href="https://github.com/13662049573/TFYSwiftBannerScroll"><img src="https://img.shields.io/github/stars/13662049573/TFYSwiftBannerScroll.svg?style=social&label=Star"></a>
</p>

## 简介

TFYSwiftBannerScroll 是一个功能强大且高度可定制的 iOS 轮播图组件。它提供了丰富的动画效果和交互方式，可以轻松创建出精美的图片轮播、广告展示等效果。支持自定义 Cell、自定义页面指示器，并内置多种炫酷的过渡动画效果。

## 预览

<p align="center">
<img src="preview1.gif" width="210"/>
<img src="preview2.gif" width="210"/>
<img src="preview3.gif" width="210"/>
</p>

## ✨ 特性

- [x] 支持水平和垂直方向滚动
- [x] 支持无限循环滚动
- [x] 内置多种转场动画效果:
  - 🌊 渐变效果 (crossFading)
  - 🔍 缩放效果 (zoomOut) 
  - 🌈 深度效果 (depth)
  - 🎭 重叠效果 (overlap)
  - ➡️ 线性效果 (linear)
  - 📱 封面流效果 (coverFlow)
  - 🎡 摩天轮效果 (ferrisWheel)
  - 🎲 3D 立方体效果 (cubic)
- [x] 支持自动轮播，可自定义时间间隔
- [x] 自定义页面指示器样式
- [x] 支持自定义 Cell
- [x] 丰富的代理方法
- [x] 完全自定义的布局系统
- [x] 支持手势交互
- [x] 支持 Interface Builder
- [x] 完整的文档和示例代码

## 📋 系统要求

- iOS 15.0+
- Swift 5.0+
- Xcode 14.0+

## 📲 安装

### CocoaPods

```ruby
pod 'TFYSwiftBannerScroll'
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/13662049573/TFYSwiftBannerScroll.git", .upToNextMajor(from: "2.0.5"))
]
```

### 手动安装

将 `TFYSwiftBannerScrollKit` 文件夹拖入你的项目中即可。

## 🚀 快速开始

### 基础用法

```swift
import TFYSwiftBannerScroll

class ViewController: UIViewController {
    
    @IBOutlet weak var pagerView: TFYSwiftPagerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. 注册 Cell
        pagerView.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // 2. 设置数据源和代理
        pagerView.dataSource = self
        pagerView.delegate = self
        
        // 3. 配置基本属性
        pagerView.automaticSlidingInterval = 3.0  // 自动轮播间隔
        pagerView.isInfinite = true              // 无限循环
        
        // 4. 设置转场动画
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: .coverFlow)
    }
}

// MARK: - 数据源方法
extension ViewController: TFYSwiftPagerViewDataSource {
    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int {
        return items.count
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = items[index].image
        cell.textLabel?.text = items[index].title
        return cell
    }
}
```

### 自定义页面指示器

```swift
let pageControl = TFYSwiftPageControl()
pageControl.numberOfPages = 5
pageControl.currentPage = 0

// 自定义样式
pageControl.setStrokeColor(.white, for: .normal)
pageControl.setFillColor(.white, for: .selected)
pageControl.setPath(UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 8, height: 8), cornerRadius: 4), for: .normal)
pageControl.setPath(UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 16, height: 8), cornerRadius: 4), for: .selected)
```

## 📖 详细文档

### 转场动画类型

TFYSwiftBannerScroll 提供了多种内置的转场动画效果:

```swift
// 基础效果
pagerView.transformer = TFYSwiftPagerViewTransformer(type: .crossFading)

// 自定义参数
let transformer = TFYSwiftPagerViewTransformer(type: .zoomOut)
transformer.minimumScale = 0.8
transformer.minimumAlpha = 0.5
pagerView.transformer = transformer
```

### 代理方法

```swift
extension ViewController: TFYSwiftPagerViewDelegate {
    // 点击事件
    func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        print("点击了第 \(index) 个item")
    }
    
    // 滚动事件
    func pagerViewWillBeginDragging(_ pagerView: TFYSwiftPagerView) {
        print("开始拖动")
    }
    
    func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView) {
        print("正在滚动")
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: TFYSwiftPagerView) {
        print("停止滚动")
    }
}
```

## 🌟 高级用法

### 自定义 Cell

```swift
class CustomCell: TFYSwiftPagerViewCell {
    override func commonInit() {
        super.commonInit()
        // 自定义 UI
    }
}
```

### 垂直滚动

```swift
pagerView.scrollDirection = .vertical
```

## 📱 示例项目

克隆项目并运行 Example 工程:

```bash
git clone https://github.com/13662049573/TFYSwiftBannerScroll.git
cd TFYSwiftBannerScroll/Example
pod install
open TFYSwiftBannerScroll.xcworkspace
```

## 🔨 更新日志
### 2.0.6
- 修复自动滚动问题
- 修复分页问题
- 修复其他问题

### 2.0.5
- 初始版本发布
- 支持基础轮播功能
- 添加多种转场动画：
  ```swift
  case crossFading       // 渐变淡出效果
  case zoomOut           // 缩小淡出效果  
  case depth             // 立体深度效果
  case overlap           // 卡片重叠效果
  case linear            // 线性滑动效果
  case coverFlow         // 封面流效果
  case ferrisWheel       // 摩天轮效果
  case invertedFerrisWheel // 反向摩天轮效果
  case cubic             // 3D立方体效果
  case rotate3D          // 3D旋转效果
  case parallax          // 视差滚动效果
  case springy           // 弹性动画效果
  case flip              // 页面翻转效果  
  case cards             // 层叠卡片效果
  case cylinder          // 圆柱体排列效果
  case wave              // 波浪起伏效果
  case windmill          // 风车旋转效果
  case accordion         // 手风琴折叠效果
  case carousel          // 旋转木马效果
  case stack             // 卡片堆叠效果
  case grid              // 网格布局效果
  ```

### 2.0.5
- 初始版本发布
- 支持基础轮播功能
- 添加多种转场动画

## ❤️ 贡献

欢迎提交 Issue 和 Pull Request。

## 👨‍💻 作者

田风有

## 📄 许可证

TFYSwiftBannerScroll 基于 MIT 许可证开源。详细内容请查看 [LICENSE](LICENSE) 文件。
