# 维护记录

## 2026-10-18 · 3.0.0

- 用户要求：全面熟悉、补充优缺点并优化，添加新版本，支持 Swift Package Manager，最低 iOS 16。
- 本轮补充要求：所有公共 API 在 Demo 中提供可操作展示，并优化 Demo UI。采用 10 个场景、固定预览与独立参数面板、分组搜索和逐项 API 映射。
- 指定的跨项目记忆入口 `/Users/admin/Documents/Codex/2026-10-14/obsidian-codex-obsidian/outputs/Codex跨项目记忆库/00-入口.md` 和开发规则在当前机器不存在；本机也未找到对应入口或本项目短期记忆。此文件作为项目最小维护记录，未改动全局记忆。
- 代码知识图谱工具和 CodeRabbit CLI 当前不可用；采用逐文件审查与定向测试。
- 原有 Xcode 用户界面状态文件改动由用户持有，不纳入提交。
- 验证环境：默认真机；当前未连接真机。模拟器与构建作为补充证据，不代表真机验收。

## 结构与优点

- `TFYSwiftPagerView`：数据源、代理、索引、自动轮播；弱引用数据源/代理与 Timer 回调，避免常见循环引用。
- `TFYSwiftPagerViewLayout` / `TFYSwiftPagerViewLayoutAttributes`：按可见范围生成属性，支持水平、垂直与网格布局。
- `TFYSwiftPagerViewTransformer`：21 种内置样式，可继承扩展。
- `TFYSwiftPageControl`：支持形状、图片、颜色、透明度及对齐。
- `TFYSwiftPagerViewCell` / `TFYSwiftPagerCollectionView`：复用与滚动封装，阴影默认关闭。
- UIKit 原生实现，无外部依赖；Demo 提供 10 个功能场景。

## 原有问题与本轮范围

- README 声称支持 Package，但缺少 `Package.swift`；系统最低版本在 podspec 与 Xcode 中不一致。
- 数据数量缩小/清空后的索引、零数量回调、有限模式跳转和超大数据集循环节数缺少边界处理。
- 网格的单项属性、程序定位、自动轮播、索引回调与可见属性使用了不同坐标模型。
- 回弹可产生负索引；吸附上限未按可滚动范围计算；无限轮播靠近重复区边界时缺少回中处理。
- 自动轮播在离窗、拖动/减速和后台状态切换时管理不完整。
- 指示器奇数数量居中偏差、负数量范围崩溃、每点重复查找索引造成平方复杂度，以及异步刷新造成布局时序不确定。
- 默认图片/文字视图的创建顺序影响遮挡；缩放转场在 minimumScale 为 1 时产生非有限透明度。

## 保留限制与后续验收

- 仅发布 iOS UIKit 产品；SwiftUI 需自行用 UIViewRepresentable 包装，不承诺 macOS/tvOS。
- 5 种转场仅支持水平滚动；图片加载、缓存与请求取消由宿主负责。
- 网格采用有限分页，不支持无限循环；索引回调代表当前页的第一项。
- 自定义 contentInsets 影响内容边缘；非对称边距下首尾项不保证几何居中。
- 本轮没有真机、iOS 16 系统运行环境及全部动画的视觉/性能验收；不能据此宣称真机或所有系统通过。
- 远程推送、公开 tag、GitHub Release、CocoaPods 发布属于外部操作，待发布阶段单独处理。

## 当前验证（2026-10-18，北京时间）

环境：macOS 本机用户 `tianfengyou`，Xcode 27.1 / iOS SDK 27.1；无业务登录账号。运行验证使用 iOS 27.0 模拟器，未连接真机。

- iPhone 18 Pro Max：`51E2B765-0CD1-4D0C-9561-F515588A6019`，Demo 应用宿主。
- iPad Pro 13-inch (M5)：`D03B8086-3357-4B0C-85F8-3DDBAE257763`，独立 Package 消费测试。
- 原始输出与 `.xcresult` 位于 `/tmp/tfy-banner-validation-20261018/`，属于当前机器的临时验证产物；重启清理后按下列命令重现。

| 要求 / 问题 | 源码位置 | 提交 | 场景 / 状态 | 证据与依据 |
| --- | --- | --- | --- | --- |
| 索引、数据边界、吸附与计时器 | TFYSwiftPagerView.swift:359、533、649；TFYSwiftPagerViewLayout.swift:234 | f4e0385、b163d3d | 模拟器定向回归通过，真机未测 | Demo 宿主测试；包含空数据、缩减、负索引、有限定位、40000 项、重复区回中和后台恢复 |
| 网格一致性 | TFYSwiftPagerViewLayout.swift:217、287；TFYSwiftPagerView.swift:740 | f4e0385 | 双方向网格定位与属性通过；真机未测 | 单项 / 可见布局属性比对，分页索引与自动按页翻页测试 |
| 指示器居中与刷新 | TFYSwiftPageControl.swift:13、107、197 | ad07d09 | 模拟器定向回归通过 | 奇偶页数居中、同步刷新、负数量与图层复用 |
| Cell 图层与动态字体 | TFYSwiftPagerViewCell.swift:14、37、134 | 62e6987 | 层级测试通过；各辅助功能人工验收未测 | 先创建文字再创建图片的层级与字体属性断言 |
| Swift Package 产品 | Package.swift:1 | tag 3.0.0 | 独立消费构建通过；30 项通过，2 项在无前台宿主环境跳过 | package-final.log：32 项执行，0 失败；2 项动画 / 生命周期由 Demo 宿主覆盖 |
| iOS 16 部署与 Release | TFYSwiftBannerScrollKit.podspec:22、Package.swift:6、project.pbxproj:485 | tag 3.0.0 | Release 编译通过，最低系统配置通过；iOS 16 运行未测 | device-final.log；vtool 输出 `minos 16.0`（deployment.txt） |
| CocoaPods 兼容 | TFYSwiftBannerScrollKit.podspec:1 | tag 3.0.0 | 本地 lib lint 通过（允许警告） | pod-lint.log：`TFYSwiftBannerScrollKit passed validation.`，包含生成的独立 Pod 消费 App 编译 |
| Demo 全公共能力入口 | Class/Scenes/TransformersDemoViewController.swift:5、Shared/DemoPagerBaseViewController.swift:4、DEMO_API_COVERAGE.md:1 | 667582d | 23 个转场选项及 17 参数控件断言通过；4 项 UI 测试通过；深色横屏补充测试 1 项通过 | 包括 10 场景导航、固定预览、Nib / CTA、代理拦截、垂直网格、横屏深色 |
| 远程新版本 | README.md:15、TFYSwiftBannerScrollKit.podspec:5 | 本地 tag 3.0.0 | 本地版本已准备；远程发布未执行 | 不把本地修改视为 GitHub / CocoaPods 已发布 |

保留警告：Xcode 自带 XCTest 动态库最低为 iOS 17，测试目标仍配置 iOS 16 时产生链接警告；AppIntents 元数据提取提示不适用；Pod lint 有 GitHub URL 校验与本机 Metal 工具链搜索路径警告。本次不宣称零警告。

## 重现命令

```sh
swift package dump-package
pod lib lint TFYSwiftBannerScrollKit.podspec --allow-warnings --skip-tests --no-clean
xcodebuild -project TFYSwiftBannerScroll.xcodeproj -scheme TFYSwiftBannerScroll \
  -destination 'platform=iOS Simulator,id=51E2B765-0CD1-4D0C-9561-F515588A6019' \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test
xcodebuild -project TFYSwiftBannerScroll.xcodeproj -scheme TFYSwiftBannerScroll \
  -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

独立 Package 验证时生成临时工程 `/tmp/tfy-banner-package-consumer/Package.swift`（验证后已清理），通过本地 `.package(path:)` 依赖仓库，并从产品 `TFYSwiftBannerScrollKit` 导入同一组库测试；`SWIFT_PACKAGE` 分支不依赖 Demo 模块。命令与测试结果保存在 package-final.log / package-final.xcresult。

## 发布阶段

1. 检查本地 3.0.0 提交与 tag，并在真机 / iOS 16 上完成待测项。
2. 获得外部发布授权后，推送提交和 3.0.0 tag；从远程 tag 重新解析 Package。
3. 发布 CocoaPods spec / GitHub Release，然后才能将远程安装记为通过。

## 最终证据索引

运行与构建时间窗口：2026-10-18 19:56–20:04（北京时间）；账号为本机 `tianfengyou`，无业务账号。以下为同一轮最终源码的分项检查，最后仅修改文档与版本配置。

| 原始输出 | 大小 | 结论 |
| --- | ---: | --- |
| `/tmp/tfy-banner-validation-20261018/demo-reviewed.log` | 125522 bytes | 33 项宿主单元测试 + 4 项 UI 测试通过；包含修复后的宽度边界断言 |
| `/tmp/tfy-banner-validation-20261018/landscape-final.log` | 20907 bytes | 更新深色环境并等待旋转稳定后，定向 UI 测试 1 项通过；非 0 测试空跑 |
| `/tmp/tfy-banner-validation-20261018/package-final.log` | 60258 bytes | 独立 Package 32 项执行：30 项通过、2 项明确跳过、0 失败 |
| `/tmp/tfy-banner-validation-20261018/pod-lint.log` | 1707 bytes | 独立 Pod 消费 App 编译与 lib lint 通过，允许警告 |
| `/tmp/tfy-banner-validation-20261018/device-final.log` | 48245 bytes | 最终 Demo / 库 Release 无签名编译通过；不是设备安装运行 |
| `/tmp/tfy-banner-validation-20261018/deployment.txt` | 251 bytes | Mach-O LC_BUILD_VERSION minos 16.0 |

应用截图：`docs/images/demo-menu.png`（335126 bytes）、`docs/images/demo-transformers.png`（1057779 bytes），均来自 demo-reviewed.xcresult 的实际应用截图。横屏深色截图保留在 landscape-final.xcresult；部分图片查看器对横屏截图显示异常，横屏几何与交互以原始 XCTest 断言为准，不作真机视觉通过声明。
