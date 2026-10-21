import UIKit

final class DemoMenuViewController: UITableViewController, UISearchResultsUpdating {
    private struct Item {
        let id: String
        let title: String
        let subtitle: String
        let symbol: String
        let factory: () -> UIViewController
    }
    private let groups: [(String, [Item])] = [
        ("卡片类型总览", [
            Item(id: "gallery", title: "全部卡片类型", subtitle: "逐项预览全部内置类型 · 默认与自定义", symbol: "rectangle.stack", factory: { DemoCardGalleryViewController() }),
            Item(id: "poster", title: "海报层叠", subtitle: "中间突出 · 两侧倾斜 · 独立播放按钮", symbol: "play.rectangle.fill", factory: { PosterStackDemoViewController() })
        ]),
        ("入门与交互", [
            Item(id: "basic", title: "基础轮播", subtitle: "卡片尺寸 · 间距 · 空数据与重载", symbol: "rectangle.on.rectangle", factory: { BasicBannerDemoViewController() }),
            Item(id: "autoplay", title: "无限循环与自动轮播", subtitle: "单页行为 · 前后台 · 暂停与恢复", symbol: "repeat", factory: { InfiniteAutoplayDemoViewController() }),
            Item(id: "physics", title: "滚动物理", subtitle: "水平与垂直 · 回弹 · 减速 · 手势", symbol: "hand.draw", factory: { ScrollPhysicsDemoViewController() }),
            Item(id: "control", title: "外观与编程控制", subtitle: "四边边距 · 选择定位 · KVO · Cell 查询", symbol: "slider.horizontal.3", factory: { ChromeControlDemoViewController() })
        ]),
        ("布局与转场", [
            Item(id: "transformers", title: "转场动画实验室", subtitle: "\(PagerViewTransformerType.allCases.count) 种样式 · 全部参数 · 自定义扩展", symbol: "sparkles.rectangle.stack", factory: { TransformersDemoViewController() }),
            Item(id: "vertical", title: "垂直滚动", subtitle: "方向兼容 · 上下翻页 · 垂直回弹", symbol: "arrow.up.arrow.down", factory: { VerticalScrollDemoViewController() }),
            Item(id: "grid", title: "网格分页", subtitle: "行列与间距 · 双向分页 · 按项定位", symbol: "square.grid.2x2", factory: { GridLayoutDemoViewController() })
        ]),
        ("内容与反馈", [
            Item(id: "indicator", title: "页面指示器", subtitle: "颜色 · 路径 · 图片 · 对齐 · 单页隐藏", symbol: "ellipsis", factory: { PageControlDemoViewController() }),
            Item(id: "cell", title: "Cell 与注册方式", subtitle: "类与 Nib · 图片文字 · 阴影 · 点击交互", symbol: "rectangle.stack.badge.plus", factory: { CustomCellDemoViewController() }),
            Item(id: "events", title: "数据源与代理事件", subtitle: "全部回调 · 选择拦截 · 实时日志", symbol: "waveform.path", factory: { DelegateEventsDemoViewController() })
        ])
    ]
    private var query = ""
    private var menuHeader: UIView?
    private var sections: [(String, [Item])] {
        guard !query.isEmpty else { return groups }
        return groups.compactMap { name, items in
            let matches = items.filter { ($0.title + $0.subtitle).localizedCaseInsensitiveContains(query) }
            return matches.isEmpty ? nil : (name, matches)
        }
    }

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "轮播实验室"
        view.tintColor = .systemIndigo
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        tableView.accessibilityIdentifier = "demo.menu"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "搜索功能、参数或交互"
        navigationItem.searchController = search
        definesPresentationContext = true
        menuHeader = makeHeader()
    }

    private func makeHeader() -> UIView {
        let host = UIView()
        let title = UILabel()
        title.text = "TFYSwiftBannerScrollKit"
        title.font = .preferredFont(forTextStyle: .headline)
        title.adjustsFontForContentSizeCategory = true
        title.numberOfLines = 0
        let detail = UILabel()
        detail.text = "iOS 16+  /  Swift Package Manager\n\(PagerViewTransformerType.allCases.count) 种内置卡片，\(groups.reduce(0) { $0 + $1.1.count }) 个交互场景。\n从全部卡片类型进入，逐项浏览真实预览。"
        detail.font = .preferredFont(forTextStyle: .subheadline)
        detail.adjustsFontForContentSizeCategory = true
        detail.textColor = .secondaryLabel
        detail.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [title, detail])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(stack)
        // UITableView can temporarily impose a zero height while measuring its header.
        let bottom = stack.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -16)
        bottom.priority = .init(999)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: host.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -20),
            bottom
        ])
        return host
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Before the first layout, width can be zero. Measure and attach only with usable bounds.
        guard let header = menuHeader, tableView.bounds.width > 40 else { return }
        let height = header.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0),
            withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
        if tableView.tableHeaderView !== header || abs(header.frame.height - height) > 1 || abs(header.frame.width - tableView.bounds.width) > 1 {
            header.frame.size = CGSize(width: tableView.bounds.width, height: height)
            tableView.tableHeaderView = header
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { sections[section].1.count }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { sections[section].0 }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].1[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.secondaryText = item.subtitle
        config.image = UIImage(systemName: item.symbol)
        config.imageProperties.tintColor = .systemIndigo
        config.textProperties.font = .preferredFont(forTextStyle: .headline)
        config.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
        config.secondaryTextProperties.color = .secondaryLabel
        config.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 12)
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "demo.\(item.id)"
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(sections[indexPath.section].1[indexPath.row].factory(), animated: true)
    }
}
