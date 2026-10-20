# TFYSwiftBannerScrollKit

原生 UIKit 轮播组件：水平 / 垂直、有限 / 无限轮播、自动翻页、22 种转场、自定义 Cell、网格分页和页面指示器。无第三方依赖。

- 最低 **iOS 16.0**
- Swift 5.7+ / Xcode 14+，使用 Swift 5 语言模式
- Swift Package Manager、CocoaPods、源码集成
- 当前版本 **3.1.0**（3.x 最低支持 iOS 16，升级前请检查宿主部署版本）

## 安装

### Swift Package Manager

清单配置遵循 [Swift PackageDescription 官方文档](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)。

Xcode → File → Add Package Dependencies，填入仓库地址：

```text
https://github.com/13662049573/TFYSwiftBannerScroll.git
```

发布 `3.1.0` tag 后，选择 **Up to Next Major Version / 3.1.0**，添加产品 **TFYSwiftBannerScrollKit**。
当前工作区可直接通过 **Add Local** 选择仓库目录验证。Swift Package 的版本由 Git tag 管理，`Package.swift` 声明产品、平台和 Swift 语言模式；本地 tag 需要推送后才能用于远程版本解析。

其他 Package 的清单示例：

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MyAppFeature",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/13662049573/TFYSwiftBannerScroll.git", from: "3.1.0")
    ],
    targets: [
        .target(name: "MyAppFeature", dependencies: [
            .product(name: "TFYSwiftBannerScrollKit", package: "TFYSwiftBannerScroll")
        ])
    ]
)
```

### CocoaPods

对应版本发布到 CocoaPods 后：

```ruby
platform :ios, '16.0'
pod 'TFYSwiftBannerScrollKit', '~> 3.1.0'
```

### 手动集成

将 `TFYSwiftBannerScroll/TFYSwiftBannerScrollKit` 下的 7 个 Swift 文件加入目标。不要同时加入源码和 Package / Pod，否则会产生重复类型。

## 快速开始

```swift
import UIKit
import TFYSwiftBannerScrollKit // 手动将源码加入同一个目标时省略

final class BannerController: UIViewController, TFYSwiftPagerViewDataSource, TFYSwiftPagerViewDelegate {
    private let pager = TFYSwiftPagerView()
    private let indicator = TFYSwiftPageControl()
    private var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        pager.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pager)
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            pager.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pager.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pager.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pager.heightAnchor.constraint(equalToConstant: 220),
            indicator.topAnchor.constraint(equalTo: pager.bottomAnchor, constant: 8),
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            indicator.heightAnchor.constraint(equalToConstant: 28)
        ])
        pager.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "banner")
        pager.dataSource = self
        pager.delegate = self
        pager.isInfinite = true
        pager.automaticSlidingInterval = 3
        indicator.setFillColor(.systemGray3, for: .normal)
        indicator.setFillColor(.systemIndigo, for: .selected)
    }

    func update(images: [UIImage]) {
        loadViewIfNeeded()
        self.images = images
        indicator.numberOfPages = images.count
        pager.reloadData()
    }

    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int { images.count }

    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "banner", at: index)
        cell.imageView?.image = images[index]
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }

    func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int) {
        indicator.currentPage = index
    }
}
```

所有视图及数据源 / 代理操作在主线程执行。数据源和代理为弱引用，宿主负责持有；数据变化后调用 `reloadData()`。

## 交互 Demo

打开 `TFYSwiftBannerScroll.xcodeproj`，运行共享 Scheme `TFYSwiftBannerScroll`。

菜单按功能分组，支持搜索；每个场景顶部保留实时预览，下方独立滚动参数面板。滑块显示实际数值，支持深色外观和动态字体。卡片尺寸根据预览容器计算，适应 iPhone、iPad 和旋转。

| 场景 | 可操作内容 |
| --- | --- |
| 全部卡片类型 | 22 种内置类型逐项独立预览，外加默认轮播和自定义倾斜；可搜索与直达调参页 |
| 海报层叠 | 大圆角海报、两侧缩小倾斜、后景变暗、独立播放按钮、分页点与参数调节 |
| 基础轮播 | 自动 / 自定尺寸、宽高比例、间距、动画跳转、空 / 单 / 多项重载 |
| 无限循环与自动轮播 | 无限开关、单项循环移除、间隔、暂停恢复、离窗重挂载 |
| 滚动物理 | 双向滚动、分页、滚动和手势开关、双向回弹、减速距离、手势状态 |
| 外观与编程控制 | 四边边距、背景、选择取消、定位、Cell / 索引查询、KVO |
| 转场动画实验室 | 无转场、全部 22 种内置样式、自定义扩展、全部 17 个可调参数、布局属性检查 |
| 垂直滚动 | 支持垂直的全部类型、自动翻页、垂直回弹、间距 |
| 网格分页 | 行列间距、双向分页、按项定位、自动按页轮播、进出网格、空数据 |
| 页面指示器 | 双状态颜色 / 描边 / 透明度、路径 / 图片、所有对齐方式、边距、单页隐藏 |
| Cell 与注册方式 | 默认类、自定义类 + CTA、真实 Xib 注册、图片模式、文字、阴影、选中高亮 |
| 数据源与代理事件 | 2 个数据源与全部 12 个代理回调、选择高亮拦截、节流日志 |

## 公共 API 展示清单

范围：核心库自定义的公共配置、方法、协议与扩展点。下表表示展示入口；未触发场景不据此标记验收通过。UIKit 通用生命周期由真实布局、注册与复用过程执行。

### TFYSwiftPagerView

| 公共接口 | 交互入口 / 可见结果 |
| --- | --- |
| `dataSource`、`delegate` | 所有场景真实绑定；数据源与代理事件页提供日志 |
| `scrollDirection`、`ScrollDirection.horizontal / vertical` | 滚动物理、动画实验室、垂直滚动、网格方向选择 |
| `automaticSlidingInterval` | 自动轮播间隔滑块、暂停恢复；其他场景的自动预览开关 |
| `interitemSpacing` | 基础、滚动物理、垂直、动画实验室间距滑块 |
| `itemSize`、`automaticSize` | 基础页自动铺满、宽高比例；旋转后按容器更新 |
| `isInfinite` | 自动轮播页开关；配合单项 / 多项数据观察 |
| `decelerationDistance`、`automaticDistance` | 滚动物理页自动 / 1 / 2 / 3 项选择 |
| `isScrollEnabled` | 滚动物理页开关 |
| `bounces`、`alwaysBounceHorizontal`、`alwaysBounceVertical` | 滚动物理页独立开关，垂直页补充垂直回弹 |
| `removesInfiniteLoopForSingleItem` | 自动轮播页开关 + 数据数量切到 1 项 |
| `backgroundView` | 外观页显示 / 移除背景开关 |
| `transformer`（含 nil） | 动画实验室样式选择；网格页进出切换 |
| `contentInsets` 四边 | 外观页上 / 左 / 下 / 右滑块 |
| `isPagingEnabled` | 滚动物理页开关；网格实际开启 |
| `parallaxFactor`、`rotationAngle` | 动画实验室视差 / 3D 旋转滑块调用 Pager 转发接口 |
| `isTracking`、`scrollOffset` | 所有场景顶部实时状态；滚动物理页手势反馈 |
| `panGestureRecognizer` | 滚动物理页手势开关、addTarget 读取状态与速度 |
| `currentIndex` | 实时索引；外观页通过 `observe` 展示 KVO；代理页展示 didChangeIndex |
| `register(_: AnyClass?, ...)` | 基础默认类；Cell 页自定义类 |
| `register(_: UINib?, ...)` | Cell 页「Nib 注册」加载真实 DemoNibBannerCell.xib |
| `dequeueReusableCell` | 所有场景数据源；Cell 页切换三种复用标识 |
| `reloadData()` | 基础 / 自动 / 网格 / 指示器页空 / 单 / 多项与重载按钮；代理页重载日志 |
| `selectItem`、`deselectItem` | 外观页目标索引、选择与取消选择按钮 |
| `scrollToItem` | 基础导航、外观定位、网格按 item 定位 |
| `index(for:)`、`cellForItem` | 外观页「查询可见 Cell 和索引」 |
| `configureGridLayout` | 网格行列间距；首次故意先 configure 后赋 transformer 验证缓存顺序 |
| `init(frame:)`、`init(coder:)` | 代码布局实际使用 frame 构造；UIKit 归档构造不作为独立配置功能，Cell 页演示真实 Nib 集成 |

`UICollectionViewDataSource` / `UICollectionViewDelegate` 的公开桥接方法由 UIKit 在真实滚动中调用，不要求宿主直接调用。

### 数据源与代理

「数据源与代理事件」页展示：

| 类型 | 实际记录的方法 |
| --- | --- |
| 数据源 | `numberOfItems(in:)`、`pagerView(_:cellForItemAt:)` |
| 高亮与选择 | `shouldHighlightItemAt`、`didHighlightItemAt`、`shouldSelectItemAt`、`didSelectItemAt` |
| 可见生命周期 | `willDisplay`、`didEndDisplaying` |
| 手势与滚动 | `pagerViewWillBeginDragging`、`pagerViewWillEndDragging(targetIndex:)`、`pagerViewDidScroll` |
| 结束与索引 | `pagerViewDidEndScrollAnimation`、`pagerViewDidEndDecelerating`、`didChangeIndex` |

高亮和选择可单独拦截；didScroll 日志每 0.25 秒至多一条，避免日志渲染拖慢滚动。原始日志保留最近 100 条，时间标记来自当前设备时间。

### TFYSwiftPagerViewTransformer 与类型枚举

| 公共接口 | 展示入口 |
| --- | --- |
| `PagerViewTransformerType` 全部 22 个 case、`allCases`、`displayName` | 全部卡片类型独立预览、实验室完整选择与前后切换，无转场 + 22 种内置 + 自定义 |
| `supportsVertical` | 垂直页过滤；动画实验室自动禁用不兼容方向 |
| `type`、`pagerView` | 「读取 Transformer 和 LayoutAttributes」显示当前类型和所属 Pager |
| `init(type:)` | 每次选择样式创建对应实例 |
| `minimumScale`、`minimumAlpha` | zoomOut / overlap / linear / posterStack 等相关样式滑块；custom 同时展示 |
| `perspective`、`rotationAngle` | rotate3D / posterStack；flip / cylinder / carousel 也提供透视滑块 |
| `parallaxFactor` | parallax |
| `springDamping` | springy |
| `waveHeight` | wave |
| `cylinderRadius` | cylinder |
| `flipAngle` | flip |
| `cardSpacing` | cards / posterStack |
| `windmillSpeed` | windmill |
| `accordionFactor` | accordion |
| `carouselRadius` | carousel |
| `stackOffset` | stack |
| `gridRows`、`gridColumns`、`gridSpacing` | grid 动态滑块；专门网格页配置方法 |
| `applyTransform(to:)` | 每种真实转场调用；DemoTiltTransformer 覆盖并可调缩放、透明度、倾角 |
| `proposedInteritemSpacing()` | 属性检查显示实际间距；DemoTiltTransformer 覆盖并使用 Pager 间距 |

自动化应用宿主测试遍历 24 个选项，检查全部 17 个参数均有实际滑块；这不替代每个动画的真机视觉验收。

### TFYSwiftPagerViewLayoutAttributes

`position`、`copy(with:)`、`isEqual(_:)` 在动画实验室检查按钮读取真实可见布局属性、复制并比较。自定义转场使用 position 并修改 transform / alpha / zIndex。

### TFYSwiftPageControl

| 公共接口 | 展示入口 |
| --- | --- |
| `numberOfPages` | 指示器页数据数量切换；网格页按页计算 |
| `currentPage` | 手动 currentPage 滑块、跳转到指示器选中页按钮；各场景代理同步 |
| `itemSpacing`、`interitemSpacing` | 指示器直径与点间距滑块 |
| `contentInsets` 四边 | 指示器页四边滑块 |
| `contentHorizontalAlignment` | center / left / right / leading / trailing / fill 全部选项 |
| `hidesForSinglePage` | 开关 + 切换到 1 项数据 |
| `isHiddenInGridMode` | 指示器页隐藏开关；网格页隐藏网格指示器 |
| `setStrokeColor`、`setFillColor` | 普通和选中状态独立颜色选择，包括透明 |
| `setImage` | 自定义图片样式为两种状态生成实际位图；切回其他样式清除图片 |
| `setAlpha` | 普通和选中状态独立透明度滑块 |
| `setPath` | 五角星 / 圆角路径，同时覆盖两种状态；切回圆点清除路径 |

### TFYSwiftPagerViewCell

| 公共接口 / 扩展点 | 展示入口 |
| --- | --- |
| `textLabel`、`imageView` | Cell 页默认 / Nib 视图开关、填充模式；先访问文字再访问图片验证层级 |
| `isShadowEnabled` | Cell 页阴影开关，默认关闭 |
| `isSelected`、`isHighlighted` | 独立模拟开关；外观选择与代理真实点击 |
| `init(frame:)`、`init(coder:)` | Class 注册和真实 Nib 注册；自定义类实现两种构造器 |
| `layoutSubviews`、`prepareForReuse` | 默认布局与复用；自定义 Cell 清空图片、标题和 CTA 回调 |
| `observeValue`（字体观察） | 默认 textLabel 动态字体；可在系统调整字体大小验证重新布局 |


## 使用边界

| 能力 | 约定 |
| --- | --- |
| `itemSize = .zero` / `automaticSize` | 默认铺满可见区域，扣除 `contentInsets` |
| `contentInsets` | 四边留白；手动卡片尺寸下边缘至少保留指定间距，非对称时首尾不保证几何居中 |
| `isPagingEnabled` | 按视口分页；卡片尺寸小于视口时，通常用默认卡片吸附 |
| `decelerationDistance` | `1` 为一项，`automaticDistance` 为按速度自动计算；网格以页计 |
| `scrollOffset` | 普通模式以 item 计；网格以页计；有限模式限制到有效范围，无限模式归一化 |
| `currentIndex` / `didChangeIndex` / KVO | 普通模式代表数据索引；网格代表当前页第一项 |
| `scrollToItem` / `selectItem` | 网格定位到包含目标 item 的整页；空数据或越界请求忽略 |
| `cellForItem` | 仅返回当前可见的 Cell；不可见或越界返回 `nil` |
| `index(for:)` | 返回数据索引；Cell 不属于当前 Pager 时返回 `NSNotFound` |
| `automaticSlidingInterval` | `0` 关闭；离窗、后台、拖动和减速时暂停；空 / 单项不自动翻页 |
| 网格模式 | 有限分页，配置时关闭无限并开启视口分页；退出时自行设置后续循环 / 分页行为 |
| `TFYSwiftPageControl` | 展示型控件，默认不接收点击；宿主同步索引，负页数和越界索引会被限制 |

### 转场与自定义扩展

`PagerViewTransformerType.allCases` 列举全部 22 种类型；`displayName` 提供名称，`supportsVertical` 指示方向兼容性。
仅水平：`overlap`、`linear`、`coverFlow`、`ferrisWheel`、`invertedFerrisWheel`、`posterStack`。

```swift
let transformer = TFYSwiftPagerViewTransformer(type: .zoomOut)
transformer.minimumScale = 0.8
transformer.minimumAlpha = 0.5
pager.transformer = transformer
```

继承 `TFYSwiftPagerViewTransformer`，覆盖 `applyTransform(to:)` 与 `proposedInteritemSpacing()` 可实现自定义样式。参考 Demo 的 `DemoTiltTransformer`。
修改自定义转场参数后可调用 `reloadData()` 刷新；`minimumScale`、`minimumAlpha` 和网格参数会自行使布局失效。

### 网格

```swift
pager.configureGridLayout(rows: 2, columns: 3, spacing: 10)
pager.transformer = TFYSwiftPagerViewTransformer(type: .grid)
// 上述顺序与先设置 transformer 均可。
// 指示器：页数 = ceil(itemCount / 6)，currentPage = currentIndex / 6。
```

### 海报层叠卡片

`.posterStack` 提供中间海报突出、左右卡片缩小倾斜的水平轮播布局：

```swift
pager.itemSize = CGSize(width: 280, height: 370)
pager.isInfinite = true
let poster = TFYSwiftPagerViewTransformer(type: .posterStack)
poster.minimumScale = 0.9
poster.minimumAlpha = 0.55
poster.rotationAngle = .pi / 24
poster.cardSpacing = 10
pager.transformer = poster
```

圆角和播放按钮由 Cell 自定义；完整实现参考 `PosterStackDemoViewController` / `DemoPosterCell`。Demo 的播放按钮只展示点击回调，不包含视频源或播放器。

### 自定义 Cell

继承 `TFYSwiftPagerViewCell`，将内容加入 `contentView`。可使用类或 `UINib` 注册。
默认 `imageView`、`textLabel` 按需创建；`isShadowEnabled` 默认为 `false`。宿主负责网络图片加载与取消请求，重用时清除宿主创建的异步状态。

## 优点与限制

优点：无依赖、UIKit 原生、可复用 Cell、按可见区域计算布局、弱引用代理与计时器回调、22 种样式及公开扩展点；Package 与 Pod 使用同一份核心源码。

限制：只发布 iOS UIKit 产品；SwiftUI 需要宿主包装 `UIViewRepresentable`。不包含图片下载 / 缓存、SwiftUI 原生接口或点击式页面指示器。部分转场仅水平；网格不提供无限循环。复杂 3D 动画仍需在目标真机评估视觉与性能。

## 3.1.0 更新

- 新增 `.posterStack` 海报层叠类型：中心突出、左右倾斜缩放、后景淡出；保留已有枚举原始值。
- 增加「全部卡片类型」总览：22 种内置样式 + 默认轮播 + 自定义倾斜，共 24 项可独立滑动预览，支持搜索、暂停与直达调参。
- 新增参考图形式的海报场景，提供大圆角、自定义播放按钮、分页点与布局参数。
- 动画实验室增加上一种 / 下一种及当前序号，完整展示全部类型。
- 修复 `.stack` 手动拖动时远处重复卡片透叠、前后遮挡层级过粗的问题。
- 修正总览类型名称与搜索标识，将 API 展示、使用边界和维护说明合并到本 README，移除原 docs 目录。
- CocoaPods、Demo 版本同步至 3.1.0；最低支持 iOS 16，Package 产品名保持一致。

## 3.0.1 更新

- 同步 CocoaPods 版本、安装示例与 Demo 版本信息为 3.0.1。
- Package 清单明确使用 Swift 5 语言模式，与 CocoaPods 和示例工程保持一致；最低工具链仍为 Swift 5.7 / Xcode 14。
- 补充 Podspec 中的集成方式、10 个交互 Demo 与语言模式说明。
- 保留 3.0.0 的轮播能力、公共 API 和 iOS 16 最低系统要求。

## 3.0.0 更新

- 正式加入 `Package.swift`，产品 / 模块名 `TFYSwiftBannerScrollKit`，包含独立测试目标。
- Package、Pod、Demo 和测试部署版本统一为 iOS 16；补充共享 Scheme。
- 修复空数据、数据缩减、负索引回弹、有限跳转、超大数据源和弱数据源释放的边界。
- 统一网格可见布局、单项布局、按项定位、索引回调与自动轮播的分页计算。
- 修复吸附边界、无限轮播重复区边界、短间隔动画重启及计时器生命周期问题。
- 修复指示器奇偶数量居中、负页数和刷新时序；按数量增减复用图层，状态更新由平方降为线性复杂度。
- 修复 Cell 图片文字创建顺序，支持动态字体并缓存阴影路径；修复 `minimumScale = 1` 的透明度计算。
- Demo 全面补齐公共 API 展示，增加分组搜索、固定预览、全部参数调节、Nib、自定义转场、数据边界和回调日志。

历史：2.1.0 加入 contentInsets / isPagingEnabled / didChangeIndex 与基础网格修复；2.0.6 修复自动滚动与分页；2.0.5 为初始版本。

## 验证与发布

核心库和 Demo 使用同一份源码；Package 测试目标覆盖核心行为，应用宿主测试补充 Demo 参数、注册和布局；UI 测试覆盖目录导航、24 项总览、海报播放按钮及手动拖动。测试结果与运行环境应分别记录，编译通过不能代替真机视觉验收。

当前真机验证受到签名限制：现有描述文件未包含连接的 iPad，尚未完成安装和交互验收。iOS 16 真机运行、复杂转场性能仍待验证。

### 2026-10-20 本轮维护记录

时间窗口：北京时间 21:40–21:45；本机账号 `tianfengyou`，无业务登录账号。环境：Xcode 27.1 / SDK 27.1，iPhone 18 Pro Max 与 iPad Pro 13-inch (M5) 模拟器（iOS 27.0）。原始输出保存在本机 `/tmp/tfy-banner-20261020/`，系统清理临时目录后需重新运行。

| 要求 / 场景 | 提交 / 版本 | 状态与依据 | 原始证据 |
| --- | --- | --- | --- |
| 堆叠手动滑动、遮挡与远处卡片 | `57b4c44` | 模拟器通过；水平 / 垂直、有限 / 无限、84 个中间偏移及正反拖动；真机未测 | `stack-fix.log`（155671 bytes）、`stack-fix.xcresult` |
| 22 种内置 + 默认与自定义、海报与参数 | 3.1.0 | 38 项应用单元测试 + 修复后 2 项 UI 测试通过；UI 逐项遍历 24 种并操作海报按钮 | `stack-fix.log`；截图位于 `fixed-screenshots/` |
| 目录、固定预览、Nib / CTA、代理、深色横屏 | 3.1.0 | 堆叠修复前完整 6 项 UI 测试通过；修复后对总览及海报重跑，未重复全部 6 项 | `final-demo.log`（207932 bytes）、`final-demo.xcresult` |
| 独立 Package 消费 | 3.1.0 | 35 项执行：33 通过、2 跳过、0 失败；跳过的前台动画 / 生命周期由应用宿主测试覆盖 | `package-stack-final.log`（65219 bytes）、`package-stack-final.xcresult` |
| iOS 16 部署与 Release 构建 | 3.1.0 | 无签名 Release 编译通过，Mach-O `minos 16.0`；iOS 16 运行未测 | `release-final.log`（82335 bytes）、`deployment.txt`（252 bytes） |
| Podspec / Package / Demo 版本配置 | 3.1.0 / build 5 | 清单解析、Podspec 语法及版本、最低系统、Swift 语言模式校验通过 | `version-validation.json`（298 bytes）、`package.json`、`podspec.json` |
| 连接的 iPad 安装交互 | 3.1.0 | 受阻：现有描述文件未包含该设备，未修改签名或注册设备 | `device-build.log`（2318 bytes） |
| 远程 Package / CocoaPods 发布 | 3.1.0 | 未执行；本地版本准备不作为远程发布证明 | 需推送及发布后另行验证 |

保留工具链提示：XCTest 动态库最低系统高于测试目标的 iOS 16；AppIntents 元数据提取不适用。当前未宣称零警告。原 `docs/` 按用户要求删除，接口映射、能力边界与维护说明统一保留于 README。

复现应用测试与 Release 编译：

```sh
xcodebuild -project TFYSwiftBannerScroll.xcodeproj -scheme TFYSwiftBannerScroll \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro Max' \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test
xcodebuild -project TFYSwiftBannerScroll.xcodeproj -scheme TFYSwiftBannerScroll \
  -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

独立 Package 验证：临时消费包使用 `.package(path:)` 依赖本仓库产品 `TFYSwiftBannerScrollKit`，复制核心测试到消费包测试目标，在 iPad 模拟器执行。该结果证明本地产品可编译与导入；远程 tag 解析尚未验证。

发布前检查：

1. 使用共享 Scheme 运行应用测试与 UI 测试，并用独立消费工程验证 Package。
2. 检查 Podspec、Demo 与 README 的版本一致；Package 版本以 Git tag 为准。
3. 完成目标真机与最低系统验收，再推送提交及对应 tag，发布 CocoaPods。
4. 本地提交 / tag 不等于远程发布；未推送版本不能通过远程版本号安装。

## 作者与许可

田风有 · MIT，详见 [LICENSE](LICENSE)。
