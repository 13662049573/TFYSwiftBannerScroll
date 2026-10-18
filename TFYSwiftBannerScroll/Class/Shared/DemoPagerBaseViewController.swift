import UIKit

/// Keeps the preview visible while the parameter panel scrolls independently.
class DemoPagerBaseViewController: UIViewController, TFYSwiftPagerViewDataSource, TFYSwiftPagerViewDelegate {
    var imageNames: [String]
    private let originalImages: [String]
    private var cardRatios: CGSize?
    private var lastPreviewSize: CGSize = .zero
    private var previewHeight: NSLayoutConstraint!
    private let preview = UIView()
    private let subtitleLabel = UILabel()
    private let statusLabel = UILabel()
    private let metricsLabel = UILabel()
    let controlsContainer = UIStackView()

    lazy var pagerView: TFYSwiftPagerView = {
        let pager = TFYSwiftPagerView()
        pager.translatesAutoresizingMaskIntoConstraints = false
        pager.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pager.dataSource = self
        pager.delegate = self
        pager.accessibilityIdentifier = "banner.preview"
        return pager
    }()

    lazy var pageControl: TFYSwiftPageControl = {
        let control = TFYSwiftPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.numberOfPages = imageNames.count
        control.setFillColor(.systemGray3, for: .normal)
        control.setFillColor(.systemIndigo, for: .selected)
        return control
    }()

    init(title: String, imageNames: [String] = DemoImages.banners) {
        self.imageNames = imageNames
        self.originalImages = imageNames
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        view.tintColor = .systemIndigo
        navigationItem.largeTitleDisplayMode = .never
        setupBaseLayout()
        configureDemo()
        refreshMetrics()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let compact = view.bounds.height < 450
        subtitleLabel.isHidden = compact
        previewHeight.constant = compact ? 100 : min(260, max(160, view.bounds.height * 0.28))
        if pagerView.bounds.size != lastPreviewSize {
            lastPreviewSize = pagerView.bounds.size
            updateCardSize()
        }
    }

    func attachPagerAfterRemoval() {
        guard pagerView.superview == nil else { return }
        preview.addSubview(pagerView)
        NSLayoutConstraint.activate([
            pagerView.topAnchor.constraint(equalTo: preview.topAnchor),
            pagerView.leadingAnchor.constraint(equalTo: preview.leadingAnchor),
            pagerView.trailingAnchor.constraint(equalTo: preview.trailingAnchor),
            pagerView.bottomAnchor.constraint(equalTo: preview.bottomAnchor)
        ])
    }

    func configureDemo() {}
    func describe(_ text: String) { subtitleLabel.text = text }
    func setStatus(_ text: String) { statusLabel.text = text; refreshMetrics() }

    func useCardSize(width: CGFloat = 0.82, height: CGFloat = 0.86) {
        cardRatios = CGSize(width: width, height: height)
        updateCardSize()
    }

    func useAutomaticSize() { cardRatios = nil; pagerView.itemSize = .zero }

    private func updateCardSize() {
        guard let ratios = cardRatios, pagerView.bounds.width > 0 else { return }
        let size = CGSize(width: pagerView.bounds.width * ratios.width, height: pagerView.bounds.height * ratios.height)
        if pagerView.itemSize != size { pagerView.itemSize = size }
    }

    func setItemCount(_ count: Int) {
        imageNames = Array(originalImages.prefix(max(count, 0)))
        pagerView.reloadData()
        updatePageCount()
        setStatus("数据已更新：\(imageNames.count) 项，currentIndex = \(pagerView.currentIndex)")
    }

    var gridPageSize: Int {
        guard let transformer = pagerView.transformer, transformer.type == .grid else { return 1 }
        return max(transformer.gridRows * transformer.gridColumns, 1)
    }

    func updatePageCount() {
        pageControl.numberOfPages = imageNames.isEmpty ? 0 : (imageNames.count - 1) / gridPageSize + 1
        syncPageControl(to: pagerView.currentIndex)
    }

    func syncPageControl(to index: Int) { pageControl.currentPage = index / gridPageSize }

    func refreshMetrics() {
        guard isViewLoaded else { return }
        metricsLabel.text = String(format: "索引 %d  ·  偏移 %.2f  ·  %@", pagerView.currentIndex,
                                   pagerView.scrollOffset, pagerView.isTracking ? "触摸中" : "待交互")
    }

    private func setupBaseLayout() {
        let column = UIStackView()
        column.axis = .vertical
        column.spacing = 12
        column.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(column)
        let guide = view.safeAreaLayoutGuide
        let preferredWidth = column.widthAnchor.constraint(equalTo: guide.widthAnchor, constant: -32)
        preferredWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            column.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            column.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            column.widthAnchor.constraint(lessThanOrEqualTo: guide.widthAnchor, constant: -32),
            column.widthAnchor.constraint(lessThanOrEqualToConstant: 900), preferredWidth
        ])

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        column.addArrangedSubview(subtitleLabel)
        preview.backgroundColor = .secondarySystemGroupedBackground
        preview.layer.cornerRadius = 22
        preview.layer.cornerCurve = .continuous
        preview.clipsToBounds = true
        preview.addSubview(pagerView)
        column.addArrangedSubview(preview)
        previewHeight = preview.heightAnchor.constraint(equalToConstant: 220)
        NSLayoutConstraint.activate([
            previewHeight,
            pagerView.topAnchor.constraint(equalTo: preview.topAnchor),
            pagerView.leadingAnchor.constraint(equalTo: preview.leadingAnchor),
            pagerView.trailingAnchor.constraint(equalTo: preview.trailingAnchor),
            pagerView.bottomAnchor.constraint(equalTo: preview.bottomAnchor)
        ])
        column.addArrangedSubview(pageControl)
        let indicatorHeight = pageControl.heightAnchor.constraint(equalToConstant: 24)
        indicatorHeight.priority = UILayoutPriority(999)
        indicatorHeight.isActive = true
        let status = UIStackView(arrangedSubviews: [metricsLabel, statusLabel])
        status.axis = .vertical
        status.spacing = 4
        metricsLabel.font = .preferredFont(forTextStyle: .caption1)
        metricsLabel.textColor = .systemIndigo
        statusLabel.font = .preferredFont(forTextStyle: .caption1)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 2
        statusLabel.accessibilityIdentifier = "demo.status"
        for label in [metricsLabel, statusLabel] { label.adjustsFontForContentSizeCategory = true }
        column.addArrangedSubview(status)

        let scroll = UIScrollView()
        scroll.accessibilityIdentifier = "demo.parameters"
        scroll.heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        column.addArrangedSubview(scroll)
        controlsContainer.axis = .vertical
        controlsContainer.spacing = 12
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(controlsContainer)
        NSLayoutConstraint.activate([
            controlsContainer.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            controlsContainer.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            controlsContainer.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            controlsContainer.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            controlsContainer.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
        ])
    }

    @discardableResult
    func addSection(_ title: String, detail: String? = nil) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        let heading = UILabel()
        heading.text = title
        heading.font = .preferredFont(forTextStyle: .headline)
        heading.adjustsFontForContentSizeCategory = true
        heading.numberOfLines = 0
        stack.addArrangedSubview(heading)
        if let detail {
            let label = UILabel()
            label.text = detail
            label.font = .preferredFont(forTextStyle: .caption1)
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
            stack.addArrangedSubview(label)
        }
        controlsContainer.addArrangedSubview(stack)
        return stack
    }

    private func card(_ views: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        stack.backgroundColor = .secondarySystemGroupedBackground
        stack.layer.cornerRadius = 14
        return stack
    }

    func makeSwitchRow(title: String, isOn: Bool, action: @escaping (Bool) -> Void) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.accessibilityLabel = title
        toggle.accessibilityIdentifier = title
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.addAction(UIAction { [weak toggle] _ in
            guard let toggle else { return }; action(toggle.isOn)
        }, for: .valueChanged)
        let row = UIStackView(arrangedSubviews: [label, toggle])
        row.spacing = 12
        row.alignment = .center
        row.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        return card([row])
    }

    func makeSliderRow(title: String, value: Float, min: Float = 0, max: Float = 1, step: Float? = nil,
                       action: @escaping (Float) -> Void) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        let valueLabel = UILabel()
        let format = max <= 0.01 && min >= -0.01 ? "%.4f" : "%.2f"
        valueLabel.text = String(format: format, value)
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)
        valueLabel.textColor = .systemIndigo
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [label, valueLabel])
        row.spacing = 8
        let slider = UISlider()
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.accessibilityLabel = title
        slider.accessibilityIdentifier = title
        slider.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        slider.addAction(UIAction { [weak slider, weak valueLabel] _ in
            guard let slider else { return }
            if let step { slider.value = (slider.value / step).rounded() * step }
            valueLabel?.text = String(format: format, slider.value)
            action(slider.value)
        }, for: .valueChanged)
        return card([row, slider])
    }

    func makeButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        var config = UIButton.Configuration.tinted()
        config.title = title
        config.baseForegroundColor = .systemIndigo
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        let button = UIButton(configuration: config)
        button.titleLabel?.numberOfLines = 0
        button.accessibilityIdentifier = title
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }

    func makeChoiceRow(title: String, options: [String], selected: Int = 0,
                       action: @escaping (Int) -> Void) -> UIButton {
        let button = makeButton("\(title)：\(options[selected])", action: {})
        button.accessibilityIdentifier = title
        button.showsMenuAsPrimaryAction = true
        button.menu = UIMenu(title: title, children: options.enumerated().map { index, name in
            UIAction(title: name, state: index == selected ? .on : .off) { [weak button] chosen in
                for case let entry as UIAction in button?.menu?.children ?? [] { entry.state = .off }
                chosen.state = .on
                button?.configuration?.title = "\(title)：\(name)"
                action(index)
            }
        })
        return button
    }

    func addDataControls() {
        let section = addSection("数据与重载", detail: "切换为空、单项和多项，观察索引重置与单页循环。")
        section.addArrangedSubview(makeChoiceRow(title: "数据数量", options: ["空数据", "1 项", "3 项", "全部"], selected: 3) { [weak self] choice in
            guard let self else { return }
            self.setItemCount([0, 1, 3, self.originalImages.count][choice])
        })
        section.addArrangedSubview(makeButton("重新加载数据") { [weak self] in
            self?.pagerView.reloadData(); self?.updatePageCount(); self?.setStatus("reloadData 已调用")
        })
    }

    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int { imageNames.count }

    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = DemoImages.image(named: imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = "\(index + 1) / \(imageNames.count)   ·   滑动探索"
        return cell
    }

    func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int) {
        syncPageControl(to: index); refreshMetrics()
    }
    func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true); setStatus("点击第 \(index + 1) 项")
    }
    func pagerViewWillEndDragging(_ pagerView: TFYSwiftPagerView, targetIndex: Int) { refreshMetrics() }
    func pagerViewDidEndScrollAnimation(_ pagerView: TFYSwiftPagerView) { syncPageControl(to: pagerView.currentIndex); refreshMetrics() }
    func pagerViewDidEndDecelerating(_ pagerView: TFYSwiftPagerView) { syncPageControl(to: pagerView.currentIndex); refreshMetrics() }
    func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView) { refreshMetrics() }
}
