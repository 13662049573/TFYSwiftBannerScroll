# TFYSwiftBannerScrollKit

原生 UIKit 轮播组件：水平 / 垂直、有限 / 无限轮播、自动翻页、25 种转场、自定义 Cell、网格分页和页面指示器。无第三方依赖。

- 最低 **iOS 16.0**
- Swift 5.7+ / Xcode 14+，使用 Swift 5 语言模式
- Swift Package Manager、CocoaPods、源码集成
- 当前版本 **3.2.0**（3.x 最低支持 iOS 16，升级前请检查宿主部署版本）

## 安装

### Swift Package Manager

清单配置遵循 [Swift PackageDescription 官方文档](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)。

Xcode → File → Add Package Dependencies，填入仓库地址：

```text
https://github.com/13662049573/TFYSwiftBannerScroll.git
```

`3.2.0` 已发布到 [GitHub Releases](https://github.com/13662049573/TFYSwiftBannerScroll/releases/tag/3.2.0)。选择 **Up to Next Major Version / 3.2.0**，添加产品 **TFYSwiftBannerScrollKit**。
当前工作区可直接通过 **Add Local** 选择仓库目录验证。Swift Package 的版本由 Git tag 管理，`Package.swift` 声明产品、平台和 Swift 语言模式；本地 tag 需要推送后才能用于远程版本解析。

其他 Package 的清单示例：

```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MyAppFeature",
    platforms: [.iOS(.v16)],
    dependencies: [
        .package(url: "https://github.com/13662049573/TFYSwiftBannerScroll.git", from: "3.2.0")
    ],
    targets: [
        .target(name: "MyAppFeature", dependencies: [
            .product(name: "TFYSwiftBannerScrollKit", package: "TFYSwiftBannerScroll")
        ])
    ]
)
```

### CocoaPods

`3.2.0` 已登记到 CocoaPods Trunk，公开 Specs 与单个 CDN Podspec 已核验。CDN 版本索引同步状态见下方发布记录。

```ruby
platform :ios, '16.0'
pod 'TFYSwiftBannerScrollKit', '~> 3.2.0'
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
| 全部卡片类型 | 25 种内置类型逐项独立预览，外加默认轮播和自定义倾斜，共 27 项；可搜索与直达调参页 |
| 海报层叠 | 大圆角海报、两侧缩小倾斜、后景变暗、独立播放按钮、分页点与参数调节 |
| 基础轮播 | 自动 / 自定尺寸、宽高比例、间距、动画跳转、空 / 单 / 多项重载 |
| 无限循环与自动轮播 | 无限开关、单项循环移除、间隔、暂停恢复、离窗重挂载 |
| 滚动物理 | 双向滚动、分页、滚动和手势开关、双向回弹、减速距离、手势状态 |
| 外观与编程控制 | 四边边距、背景、选择取消、定位、Cell / 索引查询、KVO |
| 转场动画实验室 | 无转场、全部 25 种内置样式、自定义扩展、全部 17 个可调参数、布局属性检查 |
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
| `transformer`（含 nil） | 动画实验室样式选择；网格页进出切换；每个 Pager 使用独立实例 |
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
| `PagerViewTransformerType` 全部 25 个 case、`allCases`、`displayName` | 全部卡片类型独立预览、实验室完整选择与前后切换，无转场 + 25 种内置 + 自定义 |
| `supportsVertical` | 垂直页过滤；动画实验室自动禁用不兼容方向 |
| `type`、`pagerView` | 「读取 Transformer 和 LayoutAttributes」显示当前类型和所属 Pager |
| `init(type:)` | 每次选择样式创建对应实例 |
| `minimumScale`、`minimumAlpha` | zoomOut / overlap / linear / posterStack / fan / throwCard 等；cards / wave 提供缩放参数，custom 同时展示 |
| `perspective`、`rotationAngle` | rotate3D / posterStack / fan / throwCard / bookFlip；coverFlow / cubic / flip / cylinder / carousel 也提供透视滑块 |
| `parallaxFactor` | parallax |
| `springDamping` | springy |
| `waveHeight` | wave |
| `cylinderRadius` | cylinder |
| `flipAngle` | flip |
| `cardSpacing` | cards / posterStack / fan / throwCard |
| `windmillSpeed` | windmill |
| `accordionFactor` | accordion |
| `carouselRadius` | carousel |
| `stackOffset` | stack |
| `gridRows`、`gridColumns`、`gridSpacing` | grid 动态滑块；专门网格页配置方法 |
| `applyTransform(to:)` | 每种真实转场调用；DemoTiltTransformer 覆盖并可调缩放、透明度、倾角 |
| `proposedInteritemSpacing()` | 属性检查显示实际间距；DemoTiltTransformer 覆盖并使用 Pager 间距 |

自动化应用宿主测试遍历 27 个选项，检查全部 17 个参数均有实际滑块；这不替代每个动画的真机视觉验收。

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

`PagerViewTransformerType.allCases` 列举全部 25 种类型；`displayName` 提供名称，`supportsVertical` 指示方向兼容性。
仅水平：`overlap`、`linear`、`coverFlow`、`ferrisWheel`、`invertedFerrisWheel`、`posterStack`。

```swift
let transformer = TFYSwiftPagerViewTransformer(type: .zoomOut)
transformer.minimumScale = 0.8
transformer.minimumAlpha = 0.5
pager.transformer = transformer
```

继承 `TFYSwiftPagerViewTransformer`，覆盖 `applyTransform(to:)` 与 `proposedInteritemSpacing()` 可实现自定义样式。参考 Demo 的 `DemoTiltTransformer`。
内置的 17 个参数修改后会自动使布局失效，不必调用 `reloadData()`。自定义子类新增参数仍由宿主触发布局刷新。

先设置 `pager.transformer`，再使用 `pager.parallaxFactor` / `pager.rotationAngle` 快捷接口；这两个接口读取当前 Transformer 的实际值。

### 全部转场类型

原有 `0...21` 的枚举原始值保持不变，新增类型追加到末尾。宿主若穷举匹配该枚举，需要补齐新增 case 或提供兜底处理。除标记「仅水平」的 6 种类型，其余支持水平和垂直。下表中的检查范围包括默认参数、滑动中间位置、边界值与方向；不能替代目标真机视觉与性能验收。

| rawValue | 类型 | 视觉行为 / 主要参数 |
| ---: | --- | --- |
| 0 | `crossFading` 渐变淡出 | 固定中心叠化 |
| 1 | `zoomOut` 缩小 | 缩放淡出；minimumScale / minimumAlpha |
| 2 | `depth` 深度 | 前景滑出、后景缩放；minimumScale |
| 3 | `overlap` 卡片重叠 · 仅水平 | 密集重叠；minimumScale / minimumAlpha |
| 4 | `linear` 卡片线性 · 仅水平 | 较宽间距缩放；minimumScale / minimumAlpha |
| 5 | `coverFlow` 封面流 · 仅水平 | 两侧透视倾斜；perspective |
| 6 | `ferrisWheel` 摩天轮 · 仅水平 | 沿下方圆心旋转；minimumAlpha |
| 7 | `invertedFerrisWheel` 反向摩天轮 · 仅水平 | 沿上方圆心旋转；minimumAlpha |
| 8 | `cubic` 立体立方 | 沿边缘转动；perspective |
| 9 | `rotate3D` 3D 旋转 | 围绕中心旋转；rotationAngle / perspective |
| 10 | `parallax` 视差滚动 | 卡片位移差；parallaxFactor（不是图片内部视差） |
| 11 | `springy` 弹性 | 有界弹性缩放；springDamping，越大超调越小 |
| 12 | `flip` 翻转 | 中心翻面、隐藏背面镜像；flipAngle / perspective |
| 13 | `cards` 卡片层叠 | 缩放与间距；minimumScale / cardSpacing |
| 14 | `cylinder` 圆柱体 | 沿柱面移动并旋转；cylinderRadius / perspective |
| 15 | `wave` 波浪 | 在滚动的垂直方向起伏；waveHeight / minimumScale |
| 16 | `windmill` 风车 | 围绕卡片中心平面旋转；windmillSpeed |
| 17 | `accordion` 手风琴 | 沿滚动轴压缩；accordionFactor |
| 18 | `carousel` 旋转木马 | 卡片保持朝前沿弧线移动；carouselRadius / perspective |
| 19 | `stack` 堆叠 | 前景不透明、近邻缩放错位；stackOffset |
| 20 | `grid` 网格 | 有限整页排列；gridRows / gridColumns / gridSpacing |
| 21 | `posterStack` 海报层叠 · 仅水平 | 中央海报、两侧倾斜；minimumScale / minimumAlpha / rotationAngle / cardSpacing |
| 22 | `fan` 扇形卡片 | 绕底边（垂直时右边）展开；rotationAngle / minimumScale / minimumAlpha / cardSpacing |
| 23 | `throwCard` 飞出叠牌 | 前卡飞出，下一张在底部放大接替；rotationAngle / minimumScale / minimumAlpha / cardSpacing |
| 24 | `bookFlip` 翻书 | 书脊固定，前页沿左边（垂直时上边）朝前翻起；rotationAngle / minimumAlpha / perspective |

### 参数边界

- `minimumScale`、`minimumAlpha`、`springDamping`、`accordionFactor` 限制在 `0...1`。
- `parallaxFactor`、圆柱 / 木马半径、`cardSpacing`、`stackOffset` 和网格间距不小于 0；网格行列至少为 1。
- 浮点参数拒绝 NaN / 无穷值并归一化；角度、透视、波高及风车速度保留有限值。翻书会按卡片尺寸限制透视，避免穿过镜头。其他极端透视或超大角度不保证视觉效果，建议使用 Demo 给出的范围。
- 内置变换不会修改布局源中心；非有限 position 隐藏，远处卡片限制可见范围，避免负缩放和重复堆叠。自定义子类仍需自行处理边界。

新增样式直接使用相同 API：

```swift
pager.transformer = TFYSwiftPagerViewTransformer(type: .fan) // 或 .throwCard / .bookFlip
pager.itemSize = CGSize(width: 280, height: 200)
pager.isInfinite = true
pager.transformer?.rotationAngle = .pi / 12
```

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

优点：无依赖、UIKit 原生、可复用 Cell、按可见区域计算布局、弱引用代理与计时器回调、25 种样式及公开扩展点；Package 与 Pod 使用同一份核心源码。

限制：只发布 iOS UIKit 产品；SwiftUI 需要宿主包装 `UIViewRepresentable`。不包含图片下载 / 缓存、SwiftUI 原生接口或点击式页面指示器。部分转场仅水平；网格不提供无限循环。复杂 3D 动画仍需在目标真机评估视觉与性能。

## 3.2.0 更新

- 补充 `fan` 扇形卡片、`throwCard` 飞出叠牌、`bookFlip` 翻书，内置类型增至 25 种；原有枚举值不变。
- 总览增至 27 项，实验室、垂直列表和参数面板同步覆盖新增样式。
- 全部 17 个 Transformer 参数支持自动刷新，规范非有限输入和有效范围；快捷属性读取当前 Transformer 的实际值。
- 修复重叠卡片漏显示、重复位移、远处负缩放 / 透明度、摩天轮透明度跳变、翻转背面镜像和木马中心后缩。
- 立方体变换保留布局源中心，可重复应用；封面流和立方体使用公开透视参数；网格公开间距返回实际 gridSpacing。
- 统一梳理全部类型、方向、参数与验证边界；最低 iOS 16，无新增依赖。

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

核心库和 Demo 使用同一份源码；Package 测试目标覆盖核心行为，应用宿主测试补充 Demo 参数、注册和布局；UI 测试覆盖目录导航、27 项总览、海报播放按钮及手动拖动。测试结果与运行环境应分别记录，编译通过不能代替真机视觉验收。

真机安装、iOS 16 运行和复杂转场性能仍待验证。本轮连接的 iPad 需要解锁才能启用开发服务；此前签名验证也遇到描述文件未包含该设备的问题。

### 2026-10-21 · 3.2.0 发布与总览布局修复

本轮使用已公开的 `3.2.0` 标签（`0bf160b`），未移动远端标签。本地标签已对齐；Package、Podspec 和 7 个核心 Swift 文件与远端逐一校验一致。总览布局修复已在主分支的 `beca9bc`、`0a3b4c1` 提交中，晚于该标签，仅影响 Demo，不包含在已发布的 3.2.0 示例源码中。

| # / 要求 | 源码 / 提交 | 场景与状态 | 证据 |
| --- | --- | --- | --- |
| 1 / 海报行复用时约束冲突 | `Class/Scenes/DemoCardGalleryViewController.swift:149` / `beca9bc` | 底部约束优先级设为 999，兼容表格暂时沿用 341.667 点旧行高；海报保持 300 点、按钮不小于 44 点。普通 / 海报往返复用、320 / 440 / 844 点宽度通过 | 布局回归修复前失败，修复后通过；`before.log`、`final.log`、`final.xcresult` |
| 2 / 窗口外提前布局 | 同文件 `:54`、`:71` / `beca9bc` | 出现后才更新可见预览，访问前检查 window；窗口外读取次数由 2 降到 0 | 最终 3 项应用定向测试通过 |
| 3 / 全类型实际交互 | `TFYSwiftBannerScrollUITests.swift:120` / `0a3b4c1` | 1 项 UI 测试通过：27 项逐项搜索、行高 / 按钮尺寸、正反拖动与详情跳转；海报截图已检查 | `final.log`（195244 bytes）、`screenshots/`；`runtime-final.log`（61320674 bytes），约束冲突 / 窗口外布局 / 未配对生命周期消息均为 0 |
| 4 / 远程 Package 3.2.0 | `Package.swift:1` / `0bf160b` | 独立消费包按远端精确版本解析，43 项执行，41 通过、2 因缺少前台应用宿主而跳过、0 失败 | `Package.resolved` 固定 `0bf160b`；`package.log`（115585 bytes）、`package.xcresult` |
| 5 / CocoaPods 公开发布 | `TFYSwiftBannerScrollKit.podspec:5` / `0bf160b` | 远程 Podspec lint 通过；Trunk 和公开 Specs 已出现 3.2.0，规范内容一致。发布命令返回 GitHub API 超时后先回查，未重复提交 | `spec-lint.log`（1626 bytes）、`trunk-push.log`（1566 bytes）、`trunk-spec.json`、`github-spec.json`、`cdn-follow.body` |
| 6 / 公开 Podspec 消费 | 同上 | 独立 App 从公开 Specs Podspec 安装并编译通过，已安装的 7 个核心文件与标签一致；arm64 / x86_64 最低部署均为 iOS 16.0 | `published-spec-install.log`（830 bytes）、`pod-build.log`（354372 bytes）、`pod-deployment.txt`。此消费方式指定公开 Podspec，不能代替普通按版本解析 |
| 7 / CocoaPods CDN 版本索引 | 公开 CDN | 暂未同步：普通 `= 3.2.0` 安装尚未解析成功；单个版本 Podspec 已可读取。保留为待复验项 | `pod-consumer-install.log`、`cdn-index-current.txt`、`cdn-index.headers` |
| 8 / 真机与剩余诊断 | — | 真机开发服务受锁屏阻挡，真机 / iOS 16 运行未测；保留图片解码、听写与 PointerUI 信息，不宣称控制台零警告 | `device.log`；最终运行日志仍有 7 条 `CVPixelBufferCreate`、30 条听写、2 条 PointerUI 信息 |

验证时间：北京时间 05:19–05:29，本机 `tianfengyou`，无业务账号；Xcode 27.1 / SDK 27.1，iPhone 18 Pro Max 与 iPad Pro 13-inch (M5) 的 iOS 27.0 模拟器。布局证据目录 `/tmp/tfy-banner-gallery-layout-20261021/`，发布证据目录 `/tmp/tfy-banner-release-3.2.0-20261021/`；汇总及完整文件大小见各目录的 `verification.json`。本轮未增加依赖、分支，也未改动现有签名设置；保留 Metal 工具链搜索路径、AppIntents 与 XCTest 平台提示。

### 2026-10-20 · 3.2.0 转场完整梳理与验证

范围：现有 22 种类型逐项检查，补充 3 种，核心 API、方向、参数、可见布局、Demo 与版本同步。验证窗口：北京时间 21:58–22:27，本机 `tianfengyou`、无业务账号；Xcode 27.1 / SDK 27.1，iPhone 18 Pro Max 和 iPad Pro 13-inch (M5) 的 iOS 27.0 模拟器。原始证据保存在 `/tmp/tfy-banner-transformer-20261020/`，临时目录清理后需重新执行验证。

| # / 要求 | 源码位置 | 提交 / 版本 | 场景与状态 | 证据 / 依据 |
| --- | --- | --- | --- | --- |
| 1 / 参数及时刷新与边界 | `TFYSwiftPagerViewTransformer.swift:84` | `316e44e` | 15 个浮点参数自动刷新 / 非有限值回归；网格行列在既有网格测试覆盖；通过 | 最终应用测试 48 项通过；`final-reviewed.log`（110197 bytes） |
| 2 / 全类型中间态与布局 | `TFYSwiftPagerViewTransformer.swift:214`、`TFYSwiftPagerViewLayout.swift:154` | `f5e10cc` | 25 类型在支持方向的 1012 个有限 position 组合，检查数值、透明度、重复变换；部分可见卡片与非对称尾项；通过 | `final-reviewed.xcresult`；布局返回范围依据 [Apple 可见元素约定](https://developer.apple.com/documentation/uikit/uicollectionviewlayout/layoutattributesforelements(in:)) |
| 3 / 快捷属性与网格间距一致 | `TFYSwiftPagerView.swift:212`、`TFYSwiftPagerViewTransformer.swift:714` | `826ceb9`、`43935a1` | 读取当前转场实际值、非有限快捷赋值、双向 gridSpacing；通过 | 应用及 Package 定向断言 |
| 4 / 扇形、飞出叠牌、翻书与 Demo | `TFYSwiftPagerViewTransformer.swift:33`、`:571`；`Class/Scenes/DemoCardGalleryViewController.swift:17` | 3.2.0 | 旧 rawValue 不变；27 项独立预览和搜索；翻书书脊、前后页遮挡和大卡片镜头平面；通过 | 48 张支持方向的半程渲染截图位于 `reviewed-mid-screenshots/`；全部已检查 |
| 5 / 实际交互和 UI | `TFYSwiftBannerScrollUITests.swift:100` | 3.2.0 | 最后完整 6 项 UI 测试通过：27 项逐项搜索 / 前后拖动 / 跳转，10 场景、深色横屏、网格、Nib / CTA、代理与海报按钮 | `ui-reviewed.log`（187198 bytes）、`ui-reviewed.xcresult` |
| 6 / 独立 Package | `Package.swift:1` | 3.2.0 | 43 项执行，41 通过、2 跳过、0 失败；跳过项需要前台宿主，已由应用测试覆盖 | `package-reviewed.log`（74911 bytes）、对应 `.xcresult` |
| 7 / CocoaPods 消费与 iOS 16 部署 | `TFYSwiftBannerScrollKit.podspec:5` | 3.2.0 | 本地 lib lint 和独立 Pod 消费 App 编译通过（允许警告）；无签名 Release 通过，Mach-O minos 16.0 | `pod-lint-reviewed.log`（1703 bytes）、`release-reviewed.log`（49230 bytes）、`deployment.txt` |
| 8 / 版本与兼容说明 | `README.md:8`、`Info.plist:18` | 3.2.0 / build 6 | Package / Pod / Demo 平台与语言模式、25 类型、文档链接校验通过 | `version-validation.json`、`package.json`、`podspec.json` |
| 9 / 真机、iOS 16 运行与远程发布 | — | 3.2.0 | 真机签名构建受阻：现有描述文件未包含连接的 iPad；真机交互、iOS 16 运行和性能未测；未推送 / 发布 | `device.log`（2283 bytes）；不将构建和模拟器结果标记为真机验收 |

源码校验值及原始输出大小见 `verification.json`。本轮没有新增依赖、分支或远程写入。原有本地提交保留。CodeRabbit CLI 未安装（[官方安装入口](https://www.coderabbit.ai/cli)），代码图谱工具和指定跨项目记忆入口仍不可用；本轮为源码审查与运行验证，不是 CodeRabbit 审查结果。保留 CocoaPods 的 GitHub URL 校验、Metal 工具链搜索路径、AppIntents 与 XCTest 平台提示；不宣称零警告。

### 2026-10-20 首页约束修复

- #1 / `Class/DemoMenuViewController.swift:83`、`:101`：首页头部延后到表格宽度大于左右边距总和时测量，计算好高度后再赋值；底部约束优先级为 999，兼容表格临时零高度测量。旋转时同时检查宽度与高度，避免旧尺寸残留。
- 验证：北京时间 21:51–21:53，本机 `tianfengyou`、无业务账号，iOS 27.0 模拟器。1 项布局回归（零宽、零高、4 种宽度及两档字体环境）与 2 项 UI 测试（10 场景导航、深色横屏）通过；测试夹具调整后重跑 1 项布局回归通过；iPad 模拟器启动截图与日志已检查。真机和 iOS 16 运行未测。
- 原始证据目录 `/tmp/tfy-banner-header-20261020/`：`header-final.log`（103947 bytes）、`header-fixture.log`（42256 bytes）、对应 `.xcresult`、`ipad-launch.log`（681 bytes）、`ipad-header.png`，汇总 `verification.json`。三份运行日志中 `Unable to simultaneously satisfy constraints` 均为 0 条。
- 剩余诊断：听写按钮、PointerUI 及 AX 类重复消息在模拟器日志中仍有出现，不能据此宣称控制台已清空。AX 重复类消息指向模拟器运行时的 `WebKit.axbundle` / `WebCore.axbundle`；XCTest capabilities 为测试会话输出。`NSMapGet ... NULL` 尚未定位到项目调用，保留为未归因信息，不将其标记为已修复。

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
