# 公共 API → Demo 展示入口

范围：核心库自定义的全部公共配置、业务方法、协议与扩展点。UIKit 继承的通用生命周期不作为独立功能重复添加按钮；初始化、注册、复用和布局通过对应场景实际执行。此表表示已提供展示入口，运行验收状态以维护记录为准。

## TFYSwiftPagerView

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

## 数据源与代理

「数据源与代理事件」页展示：

| 类型 | 实际记录的方法 |
| --- | --- |
| 数据源 | `numberOfItems(in:)`、`pagerView(_:cellForItemAt:)` |
| 高亮与选择 | `shouldHighlightItemAt`、`didHighlightItemAt`、`shouldSelectItemAt`、`didSelectItemAt` |
| 可见生命周期 | `willDisplay`、`didEndDisplaying` |
| 手势与滚动 | `pagerViewWillBeginDragging`、`pagerViewWillEndDragging(targetIndex:)`、`pagerViewDidScroll` |
| 结束与索引 | `pagerViewDidEndScrollAnimation`、`pagerViewDidEndDecelerating`、`didChangeIndex` |

高亮和选择可单独拦截；didScroll 日志每 0.25 秒至多一条，避免日志渲染拖慢滚动。原始日志保留最近 100 条，时间标记来自当前设备时间。

## TFYSwiftPagerViewTransformer 与类型枚举

| 公共接口 | 展示入口 |
| --- | --- |
| `PagerViewTransformerType` 全部 21 个 case、`allCases`、`displayName` | 动画实验室完整下拉列表，无转场 + 21 种内置 + 自定义 |
| `supportsVertical` | 垂直页过滤；动画实验室自动禁用不兼容方向 |
| `type`、`pagerView` | 「读取 Transformer 和 LayoutAttributes」显示当前类型和所属 Pager |
| `init(type:)` | 每次选择样式创建对应实例 |
| `minimumScale`、`minimumAlpha` | zoomOut / overlap / linear 等相关样式滑块；custom 同时展示 |
| `perspective`、`rotationAngle` | rotate3D；flip / cylinder / carousel 也提供透视滑块 |
| `parallaxFactor` | parallax |
| `springDamping` | springy |
| `waveHeight` | wave |
| `cylinderRadius` | cylinder |
| `flipAngle` | flip |
| `cardSpacing` | cards |
| `windmillSpeed` | windmill |
| `accordionFactor` | accordion |
| `carouselRadius` | carousel |
| `stackOffset` | stack |
| `gridRows`、`gridColumns`、`gridSpacing` | grid 动态滑块；专门网格页配置方法 |
| `applyTransform(to:)` | 每种真实转场调用；DemoTiltTransformer 覆盖并可调缩放、透明度、倾角 |
| `proposedInteritemSpacing()` | 属性检查显示实际间距；DemoTiltTransformer 覆盖并使用 Pager 间距 |

自动化应用宿主测试遍历 23 个选项，检查全部 17 个参数均有实际滑块；这不替代每个动画的真机视觉验收。

## TFYSwiftPagerViewLayoutAttributes

`position`、`copy(with:)`、`isEqual(_:)` 在动画实验室检查按钮读取真实可见布局属性、复制并比较。自定义转场使用 position 并修改 transform / alpha / zIndex。

## TFYSwiftPageControl

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

## TFYSwiftPagerViewCell

| 公共接口 / 扩展点 | 展示入口 |
| --- | --- |
| `textLabel`、`imageView` | Cell 页默认 / Nib 视图开关、填充模式；先访问文字再访问图片验证层级 |
| `isShadowEnabled` | Cell 页阴影开关，默认关闭 |
| `isSelected`、`isHighlighted` | 独立模拟开关；外观选择与代理真实点击 |
| `init(frame:)`、`init(coder:)` | Class 注册和真实 Nib 注册；自定义类实现两种构造器 |
| `layoutSubviews`、`prepareForReuse` | 默认布局与复用；自定义 Cell 清空图片、标题和 CTA 回调 |
| `observeValue`（字体观察） | 默认 textLabel 动态字体；可在系统调整字体大小验证重新布局 |

## 验收边界

自动化覆盖结果、真机 / 旧系统缺口及证据位置见 [MAINTENANCE.md](MAINTENANCE.md)。未在真实环境触发的事件或视觉情况不可仅凭此表标记通过。
