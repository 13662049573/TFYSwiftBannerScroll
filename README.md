# TFYSwiftBannerScroll

<p align="center">
    <img src="banner.png" alt="TFYSwiftBannerScroll" title="TFYSwiftBannerScroll" width="557"/>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-Swift%205.0+-f48041.svg?style=flat"></a>
    <a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS%2015.0+-blue.svg?style=flat"></a>
    <a href="https://github.com/13662049573/TFYSwiftBannerScroll/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
    <a href="https://cocoapods.org/pods/TFYSwiftBannerScrollKit"><img src="https://img.shields.io/cocoapods/v/TFYSwiftBannerScrollKit.svg?style=flat"></a>
    <a href="https://github.com/13662049573/TFYSwiftBannerScroll"><img src="https://img.shields.io/github/stars/13662049573/TFYSwiftBannerScroll.svg?style=social&label=Star"></a>
</p>

## 简介

TFYSwiftBannerScroll 是一个高度可定制的 iOS 轮播组件（`TFYSwiftBannerScrollKit`）。支持水平/垂直滚动、无限循环、自动轮播、自定义 Cell 与页面指示器，并内置 21 种转场动画（含网格布局）。

## 预览

<p align="center">
<img src="preview1.gif" width="210"/>
<img src="preview2.gif" width="210"/>
<img src="preview3.gif" width="210"/>
</p>

## 特性

- [x] 水平 / 垂直滚动（部分动画仅水平，见 `supportsVertical`）
- [x] 无限循环与自动轮播（进后台自动暂停，回前台恢复）
- [x] 21 种转场动画（crossFading / zoomOut / depth / overlap / linear / coverFlow / ferrisWheel / invertedFerrisWheel / cubic / rotate3D / parallax / springy / flip / cards / cylinder / wave / windmill / accordion / carousel / stack / grid）
- [x] 自定义页面指示器（颜色 / 图片 / 路径 / alpha / 对齐）
- [x] 自定义 Cell（继承 `TFYSwiftPagerViewCell`）
- [x] 公开布局控制：`itemSize`、`interitemSpacing`、`contentInsets`、`isPagingEnabled`
- [x] 索引变化回调：`pagerView(_:didChangeIndex:)`（同时支持 KVO `currentIndex`）
- [x] 完整 Demo：功能菜单 + 10 个场景覆盖全部公开 API

## 系统要求

- iOS 15.0+
- Swift 5.0+
- Xcode 14.0+

## 安装

### CocoaPods

```ruby
pod 'TFYSwiftBannerScrollKit', '~> 2.1.0'
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/13662049573/TFYSwiftBannerScroll.git", .upToNextMajor(from: "2.1.0"))
]
```

### 手动安装

将 `TFYSwiftBannerScroll/TFYSwiftBannerScrollKit` 文件夹拖入工程即可。

## 快速开始

```swift
import UIKit
// 手动集成时无需 import；CocoaPods 模块名为 TFYSwiftBannerScrollKit

class ViewController: UIViewController, TFYSwiftPagerViewDataSource, TFYSwiftPagerViewDelegate {

    let pagerView = TFYSwiftPagerView()
    let pageControl = TFYSwiftPageControl()
    let items: [UIImage] = [] // 你的数据

    override func viewDidLoad() {
        super.viewDidLoad()

        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 3.0
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: .coverFlow)

        pageControl.numberOfPages = items.count
        pageControl.setFillColor(.lightGray, for: .normal)
        pageControl.setFillColor(.white, for: .selected)
    }

    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int {
        items.count
    }

    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = items[index]
        cell.imageView?.contentMode = .scaleAspectFill
        cell.textLabel?.text = "Item \(index)"
        return cell
    }

    func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int) {
        pageControl.currentPage = index
    }

    func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
}
```

## API 要点

### 常用属性

| 属性 | 说明 |
| --- | --- |
| `scrollDirection` | `.horizontal` / `.vertical` |
| `isInfinite` | 无限循环 |
| `automaticSlidingInterval` | 自动轮播间隔，`0` 关闭 |
| `itemSize` | 卡片尺寸；`TFYSwiftPagerView.automaticSize` 铺满 |
| `interitemSpacing` | 卡片间距 |
| `contentInsets` | 内容边距（由 Layout 消费，用于露出相邻卡片） |
| `isPagingEnabled` | 整页分页 |
| `decelerationDistance` | 减速距离；`automaticDistance` 自动计算 |
| `transformer` | 转场动画 |
| `currentIndex` / `scrollOffset` | 当前索引 / 滚动偏移 |

### 转场动画

```swift
let transformer = TFYSwiftPagerViewTransformer(type: .zoomOut)
transformer.minimumScale = 0.8
transformer.minimumAlpha = 0.5
pagerView.transformer = transformer

// 仅使用支持垂直滚动的类型
if type.supportsVertical {
    pagerView.scrollDirection = .vertical
    pagerView.transformer = TFYSwiftPagerViewTransformer(type: type)
}
```

仅水平支持：`overlap`、`linear`、`coverFlow`、`ferrisWheel`、`invertedFerrisWheel`。

### 网格布局

```swift
pagerView.transformer = TFYSwiftPagerViewTransformer(type: .grid)
pagerView.configureGridLayout(rows: 2, columns: 3, spacing: 10)
// 也可先 configure 再设置 transformer，参数会缓存后自动应用
```

### 页面指示器

```swift
pageControl.numberOfPages = 5
pageControl.contentHorizontalAlignment = .center
pageControl.setStrokeColor(.white, for: .normal)
pageControl.setFillColor(.white, for: .selected)
pageControl.setImage(UIImage(named: "dot"), for: .normal)
pageControl.setAlpha(0.4, for: .normal)
pageControl.setPath(customPath, for: .selected)
pageControl.hidesForSinglePage = true
```

### 自定义 Cell

```swift
final class BannerCell: TFYSwiftPagerViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isShadowEnabled = true // 默认关闭阴影，按需开启
        // 在 contentView 上添加自定义子视图
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

pagerView.register(BannerCell.self, forCellWithReuseIdentifier: "banner")
```

### 代理

```swift
func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int)
func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int)
func pagerViewWillBeginDragging(_ pagerView: TFYSwiftPagerView)
func pagerViewWillEndDragging(_ pagerView: TFYSwiftPagerView, targetIndex: Int)
func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView)
func pagerViewDidEndScrollAnimation(_ pagerView: TFYSwiftPagerView)
func pagerViewDidEndDecelerating(_ pagerView: TFYSwiftPagerView)
```

## 示例项目

仓库内置 Demo（功能菜单 + 10 个场景），直接打开工程运行即可：

```bash
git clone https://github.com/13662049573/TFYSwiftBannerScroll.git
cd TFYSwiftBannerScroll
open TFYSwiftBannerScroll.xcodeproj
```

Demo 场景：

1. 基础轮播  
2. 无限循环 + 自动轮播  
3. 滚动物理  
4. 转场动画画廊  
5. 垂直滚动  
6. 网格布局  
7. 页面指示器  
8. 自定义 Cell  
9. 代理事件  
10. 外观与控制  

## 更新日志

### 2.1.0

- 修复：无 `transformer` 时布局为空
- 修复：垂直滚动减速仍读取 `velocity.x` 的问题
- 修复：`itemSpacing == 0` 时的除零风险；Grid 布局更稳健
- 修复：`configureGridLayout` 需先设置 `.grid` 的调用顺序问题（支持参数缓存）
- 新增：`contentInsets`、`isPagingEnabled`
- 新增：`pagerView(_:didChangeIndex:)`
- 新增：前后台自动暂停 / 恢复自动轮播
- 新增：`PagerViewTransformerType.supportsVertical` / `displayName`
- 优化：Cell 默认关闭阴影（`isShadowEnabled`）；Timer 弱引用；密封内部 collectionView
- Demo：全面重置为功能菜单 + 多场景展示

### 2.0.6

- 修复自动滚动问题
- 修复分页问题
- 修复其他问题

### 2.0.5

- 初始版本发布
- 支持基础轮播与多种转场动画

## 贡献

欢迎提交 Issue 和 Pull Request。

## 作者

田风有

## 许可证

TFYSwiftBannerScroll 基于 MIT 许可证开源。详见 [LICENSE](LICENSE)。
