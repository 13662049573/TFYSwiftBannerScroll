import UIKit

final class DemoCardGalleryViewController: UITableViewController, UISearchResultsUpdating {
    struct Style {
        let type: PagerViewTransformerType?
        let selectionIndex: Int
        let name: String
        let title: String
        var isCustom: Bool { selectionIndex == PagerViewTransformerType.allCases.count + 1 }
        var identifier: String { "gallery.\(name)" }
        func makeTransformer() -> TFYSwiftPagerViewTransformer? {
            if isCustom { return DemoTiltTransformer(type: .zoomOut) }
            return type.map { TFYSwiftPagerViewTransformer(type: $0) }
        }
    }

    // Derived from the public enum so newly added types cannot be left out of this gallery.
    static let styles: [Style] = PagerViewTransformerType.allCases.enumerated().map { index, type in
        Style(type: type, selectionIndex: index + 1, name: type.demoCaseName, title: type.displayName)
    } + [
        Style(type: nil, selectionIndex: 0, name: "plain", title: "默认轮播"),
        Style(type: nil, selectionIndex: PagerViewTransformerType.allCases.count + 1, name: "custom", title: "自定义倾斜")
    ]
    private var query = ""
    private var autoplay = true
    private var isScreenVisible = false
    private var filteredStyles: [Style] {
        guard !query.isEmpty else { return Self.styles }
        return Self.styles.filter { ($0.title + " " + $0.name).localizedCaseInsensitiveContains(query) }
    }

    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "全部卡片类型"
        view.tintColor = .systemIndigo
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "暂停预览", style: .plain, target: self, action: #selector(toggleAutoplay))
        tableView.accessibilityIdentifier = "card.gallery"
        tableView.register(DemoCardGalleryCell.self, forCellReuseIdentifier: "preview")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 310
        tableView.isPrefetchingEnabled = false
        tableView.keyboardDismissMode = .onDrag
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "搜索名称或类型，如 coverFlow"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isScreenVisible = true
        updateVisibleAutoplay()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isScreenVisible = false
        updateVisibleAutoplay()
    }
    @objc private func toggleAutoplay() {
        autoplay.toggle()
        navigationItem.rightBarButtonItem?.title = autoplay ? "暂停预览" : "播放预览"
        updateVisibleAutoplay()
    }
    private func updateVisibleAutoplay() {
        // Reading visibleCells before attachment forces UITableView to lay out off-window.
        guard isViewLoaded, tableView.window != nil else { return }
        for case let cell as DemoCardGalleryCell in tableView.visibleCells {
            cell.setAutoplay(autoplay && isScreenVisible)
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "\(PagerViewTransformerType.allCases.count) 种内置 + 默认与自定义 · \(filteredStyles.count) 项"
    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        "每一项都是可滑动的真实卡片。点击卡片或调节按钮，进入对应类型的完整参数页。"
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { filteredStyles.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let style = filteredStyles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "preview", for: indexPath) as! DemoCardGalleryCell
        cell.configure(style: style)
        cell.onShowDetails = { [weak self] in self?.showDetails(for: style) }
        return cell
    }
    private func showDetails(for style: Style) {
        let scene: UIViewController = style.type == .posterStack
            ? PosterStackDemoViewController() : TransformersDemoViewController(styleIndex: style.selectionIndex)
        navigationController?.pushViewController(scene, animated: true)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? DemoCardGalleryCell)?.setAutoplay(autoplay && isScreenVisible)
    }
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? DemoCardGalleryCell)?.setAutoplay(false)
    }
}

final class DemoCardGalleryCell: UITableViewCell, TFYSwiftPagerViewDataSource, TFYSwiftPagerViewDelegate {
    let pager = TFYSwiftPagerView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let detailButton = UIButton(type: .system)
    private var previewHeight: NSLayoutConstraint!
    private var style: DemoCardGalleryViewController.Style?
    private var images = DemoImages.banners
    var onShowDetails: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        detailLabel.font = .preferredFont(forTextStyle: .caption1)
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        pager.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "card")
        pager.register(DemoPosterCell.self, forCellWithReuseIdentifier: "poster")
        pager.dataSource = self
        pager.delegate = self
        pager.layer.cornerRadius = 18
        pager.clipsToBounds = true
        pager.backgroundColor = .tertiarySystemGroupedBackground
        var configuration = UIButton.Configuration.tinted()
        configuration.title = "调节此类型"
        detailButton.configuration = configuration
        detailButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        detailButton.addAction(UIAction { [weak self] _ in self?.onShowDetails?() }, for: .touchUpInside)
        let column = UIStackView(arrangedSubviews: [titleLabel, detailLabel, pager, detailButton])
        column.axis = .vertical
        column.spacing = 10
        column.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(column)
        let width = column.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -32)
        width.priority = .defaultHigh
        previewHeight = pager.heightAnchor.constraint(equalToConstant: 200)
        // Reuse can retain the previous row height until UITableView finishes self-sizing.
        // Yield only the bottom inset during that pass, preserving the preview and touch target.
        let bottom = column.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        bottom.priority = .init(999)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            bottom,
            column.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            column.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, constant: -32),
            column.widthAnchor.constraint(lessThanOrEqualToConstant: 760), width, previewHeight
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(style: DemoCardGalleryViewController.Style) {
        self.style = style
        accessibilityIdentifier = style.identifier
        pager.accessibilityIdentifier = "preview.\(style.name)"
        detailButton.accessibilityIdentifier = "details.\(style.name)"
        titleLabel.text = style.title
        let direction = style.type?.supportsVertical == false ? "仅水平" : "水平 / 垂直"
        detailLabel.text = "\(style.name)  ·  \(direction)  ·  左右滑动体验"
        images = style.type == .grid ? DemoImages.all : DemoImages.banners
        pager.automaticSlidingInterval = 0
        pager.transformer = style.makeTransformer()
        pager.isPagingEnabled = style.type == .grid
        pager.isInfinite = style.type != .grid
        let poster = style.type == .posterStack
        pager.backgroundColor = poster ? UIColor(white: 0.06, alpha: 1) : .tertiarySystemGroupedBackground
        previewHeight.constant = poster ? 300 : 200
        pager.reloadData()
        setNeedsLayout()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard pager.bounds.width > 0 else { return }
        let poster = style?.type == .posterStack
        let size = poster
            ? CGSize(width: min(pager.bounds.width * 0.66, pager.bounds.height * 0.9 * 0.76), height: pager.bounds.height * 0.9)
            : CGSize(width: pager.bounds.width * 0.72, height: pager.bounds.height * 0.84)
        if pager.itemSize != size { pager.itemSize = size }
    }
    func setAutoplay(_ enabled: Bool) { pager.automaticSlidingInterval = enabled ? 2.8 : 0 }
    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int { images.count }
    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        if style?.type == .posterStack {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "poster", at: index) as! DemoPosterCell
            cell.configure(imageName: images[index], title: "海报 \(index + 1)")
            cell.onPlay = { [weak self] in self?.onShowDetails?() }
            return cell
        }
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "card", at: index)
        cell.contentView.layer.cornerRadius = 14
        cell.contentView.clipsToBounds = true
        cell.imageView?.image = DemoImages.image(named: images[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = "\(index + 1)"
        return cell
    }
    func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) { onShowDetails?() }
    override func prepareForReuse() {
        super.prepareForReuse()
        setAutoplay(false)
        onShowDetails = nil
    }
}

// @objc enums stringify as raw-value descriptions; provide stable names for search and UI IDs.
extension PagerViewTransformerType {
    var demoCaseName: String {
        switch self {
        case .crossFading: return "crossFading"
        case .zoomOut: return "zoomOut"
        case .depth: return "depth"
        case .overlap: return "overlap"
        case .linear: return "linear"
        case .coverFlow: return "coverFlow"
        case .ferrisWheel: return "ferrisWheel"
        case .invertedFerrisWheel: return "invertedFerrisWheel"
        case .cubic: return "cubic"
        case .rotate3D: return "rotate3D"
        case .parallax: return "parallax"
        case .springy: return "springy"
        case .flip: return "flip"
        case .cards: return "cards"
        case .cylinder: return "cylinder"
        case .wave: return "wave"
        case .windmill: return "windmill"
        case .accordion: return "accordion"
        case .carousel: return "carousel"
        case .stack: return "stack"
        case .grid: return "grid"
        case .posterStack: return "posterStack"
        case .fan: return "fan"
        case .throwCard: return "throwCard"
        case .bookFlip: return "bookFlip"
        }
    }
}
