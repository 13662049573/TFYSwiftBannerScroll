import UIKit

final class TransformersDemoViewController: DemoPagerBaseViewController {
    private let types = PagerViewTransformerType.allCases
    private let parameterRows = UIStackView()
    private let direction = UISegmentedControl(items: ["水平", "垂直"])
    private var selection = 6
    private var inspector: UILabel?
    private var styleChoice: UIButton?
    private let currentStyleLabel = UILabel()
    init(styleIndex: Int = 6) {
        selection = styleIndex
        super.init(title: "转场动画实验室")
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func configureDemo() {
        describe("\(types.count) 种内置样式，加上无转场和自定义 Transformer。使用上一种 / 下一种逐项体验。")
        pagerView.register(DemoPosterCell.self, forCellWithReuseIdentifier: "poster")
        useCardSize(width: 0.78, height: 0.84)
        let styles = addSection("选择样式", detail: "部分转场仅支持水平；不兼容时，垂直选项会禁用。")
        let choice = makeChoiceRow(title: "转场样式", options: styleNames, selected: selection) { [weak self] in self?.selectStyle(at: $0) }
        styleChoice = choice
        styles.addArrangedSubview(choice)
        currentStyleLabel.font = .preferredFont(forTextStyle: .subheadline)
        currentStyleLabel.adjustsFontForContentSizeCategory = true
        currentStyleLabel.numberOfLines = 0
        currentStyleLabel.accessibilityIdentifier = "style.current"
        styles.addArrangedSubview(currentStyleLabel)
        let navigation = UIStackView(arrangedSubviews: [
            makeButton("上一种卡片") { [weak self] in self?.step(-1) },
            makeButton("下一种卡片") { [weak self] in self?.step(1) }
        ])
        navigation.spacing = 12
        navigation.distribution = .fillEqually
        styles.addArrangedSubview(navigation)
        direction.selectedSegmentIndex = 0
        direction.accessibilityIdentifier = "转场方向"
        direction.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        direction.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.pagerView.scrollDirection = self.direction.selectedSegmentIndex == 0 ? .horizontal : .vertical
        }, for: .valueChanged)
        styles.addArrangedSubview(direction)
        styles.addArrangedSubview(makeSwitchRow(title: "自动预览", isOn: false) { [weak self] in self?.pagerView.automaticSlidingInterval = $0 ? 2.5 : 0 })
        let parameters = addSection("参数调节", detail: "拖动滑块立即应用，数值显示为属性的实际值。切换样式会恢复该样式默认参数。")
        parameterRows.axis = .vertical
        parameterRows.spacing = 12
        parameters.addArrangedSubview(parameterRows)
        let debug = addSection("自定义扩展与布局属性", detail: "自定义示例覆盖 applyTransform(to:) 和 proposedInteritemSpacing()；读取真实可见布局属性。")
        debug.addArrangedSubview(makeButton("读取 Transformer 和 LayoutAttributes") { [weak self] in self?.inspectLayout() })
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.accessibilityIdentifier = "transformer.inspector"
        debug.addArrangedSubview(label)
        inspector = label
        applySelection()
    }

    private var styleNames: [String] { ["无转场"] + types.map(\.displayName) + ["自定义倾斜"] }
    private func step(_ delta: Int) { selectStyle(at: (selection + delta + styleNames.count) % styleNames.count) }

    func selectStyle(at index: Int) {
        guard (0...types.count + 1).contains(index) else { return }
        selection = index
        applySelection()
    }

    private func applySelection() {
        currentStyleLabel.text = "\(selection + 1) / \(styleNames.count) · \(styleNames[selection])"
        styleChoice?.configuration?.title = "转场样式：\(styleNames[selection])"
        for (index, item) in (styleChoice?.menu?.children ?? []).enumerated() {
            (item as? UIAction)?.state = index == selection ? .on : .off
        }
        for view in parameterRows.arrangedSubviews { parameterRows.removeArrangedSubview(view); view.removeFromSuperview() }
        let transformer: TFYSwiftPagerViewTransformer?
        if selection == 0 { transformer = nil }
        else if selection == types.count + 1 { transformer = DemoTiltTransformer(type: .zoomOut) }
        else { transformer = TFYSwiftPagerViewTransformer(type: types[selection - 1]) }
        let vertical = transformer?.type.supportsVertical ?? true
        direction.setEnabled(vertical, forSegmentAt: 1)
        if !vertical { direction.selectedSegmentIndex = 0; pagerView.scrollDirection = .horizontal }
        pagerView.isPagingEnabled = false
        pagerView.transformer = transformer
        if transformer?.type == .grid {
            pagerView.configureGridLayout(rows: 2, columns: 3, spacing: 10)
        } else { pagerView.isInfinite = true }
        updatePageCount()
        guard let transformer else { setStatus("transformer = nil：原生卡片滚动"); return }
        typealias Parameter = (String, ReferenceWritableKeyPath<TFYSwiftPagerViewTransformer, CGFloat>, Float, Float)
        var values: [Parameter] = []
        if transformer is DemoTiltTransformer {
            values = [("minimumScale", \.minimumScale, 0.2, 1), ("minimumAlpha", \.minimumAlpha, 0, 1), ("rotationAngle", \.rotationAngle, 0, 3.14)]
        } else {
            switch transformer.type {
            case .zoomOut, .overlap, .linear: values = [("minimumScale", \.minimumScale, 0.2, 1), ("minimumAlpha", \.minimumAlpha, 0, 1)]
            case .depth: values = [("minimumScale", \.minimumScale, 0.2, 1)]
            case .ferrisWheel, .invertedFerrisWheel: values = [("minimumAlpha", \.minimumAlpha, 0, 1)]
            case .rotate3D: values = [("rotationAngle", \.rotationAngle, 0, 6.28), ("perspective", \.perspective, -0.01, 0)]
            case .parallax: values = [("parallaxFactor", \.parallaxFactor, 0, 2)]
            case .springy: values = [("springDamping", \.springDamping, 0, 2)]
            case .flip: values = [("flipAngle", \.flipAngle, 0, 6.28), ("perspective", \.perspective, -0.01, 0)]
            case .cards: values = [("cardSpacing", \.cardSpacing, 0, 48)]
            case .cylinder: values = [("cylinderRadius", \.cylinderRadius, 20, 500), ("perspective", \.perspective, -0.01, 0)]
            case .wave: values = [("waveHeight", \.waveHeight, 0, 120)]
            case .windmill: values = [("windmillSpeed", \.windmillSpeed, 0, 3)]
            case .accordion: values = [("accordionFactor", \.accordionFactor, 0, 1)]
            case .carousel: values = [("carouselRadius", \.carouselRadius, 20, 600), ("perspective", \.perspective, -0.01, 0)]
            case .stack: values = [("stackOffset", \.stackOffset, 0, 48)]
            case .posterStack: values = [("minimumScale", \.minimumScale, 0.7, 1), ("minimumAlpha", \.minimumAlpha, 0.2, 1), ("rotationAngle", \.rotationAngle, 0, 0.35), ("cardSpacing", \.cardSpacing, 0, 36)]
            case .grid:
                parameterRows.addArrangedSubview(makeSliderRow(title: "gridRows", value: 2, min: 1, max: 4, step: 1) { [weak self] in self?.pagerView.transformer?.gridRows = Int($0.rounded()); self?.updatePageCount() })
                parameterRows.addArrangedSubview(makeSliderRow(title: "gridColumns", value: 3, min: 1, max: 5, step: 1) { [weak self] in self?.pagerView.transformer?.gridColumns = Int($0.rounded()); self?.updatePageCount() })
                values = [("gridSpacing", \.gridSpacing, 0, 30)]
            case .crossFading, .coverFlow, .cubic: break
            }
        }
        for (name, key, minimum, maximum) in values {
            parameterRows.addArrangedSubview(makeSliderRow(title: name, value: Float(transformer[keyPath: key]), min: minimum, max: maximum) { [weak self] value in
                guard let self, let current = self.pagerView.transformer else { return }
                // Also exercise the pager's convenience forwarding APIs.
                if key == \.parallaxFactor { self.pagerView.parallaxFactor = CGFloat(value) }
                else if key == \.rotationAngle { self.pagerView.rotationAngle = CGFloat(value) }
                else { current[keyPath: key] = CGFloat(value) }
                self.pagerView.reloadData()
            })
        }
        parameterRows.addArrangedSubview(makeSliderRow(title: "卡片间距（由 Transformer 决定是否覆盖）", value: Float(pagerView.interitemSpacing), min: 0, max: 40) { [weak self] in self?.pagerView.interitemSpacing = CGFloat($0) })
        setStatus("\(transformer.type.displayName) · \(vertical ? "支持水平与垂直" : "仅支持水平")")
    }

    override func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        guard pagerView.transformer?.type == .posterStack else { return super.pagerView(pagerView, cellForItemAt: index) }
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "poster", at: index) as! DemoPosterCell
        cell.configure(imageName: imageNames[index], title: "海报 \(index + 1)")
        cell.onPlay = { [weak self] in self?.setStatus("已点击海报 \(index + 1) 的播放按钮") }
        return cell
    }

    private func inspectLayout() {
        guard let cell = pagerView.cellForItem(at: pagerView.currentIndex),
              let collection = cell.superview as? UICollectionView,
              let indexPath = collection.indexPath(for: cell),
              let attributes = collection.collectionViewLayout.layoutAttributesForItem(at: indexPath) as? TFYSwiftPagerViewLayoutAttributes else {
            inspector?.text = "请先等待预览完成布局"; return
        }
        let copy = attributes.copy() as! TFYSwiftPagerViewLayoutAttributes
        let spacing = pagerView.transformer?.proposedInteritemSpacing() ?? pagerView.interitemSpacing
        inspector?.text = "type: \(pagerView.transformer?.type.displayName ?? "nil")\nowner: \(pagerView.transformer?.pagerView === pagerView)\nposition: \(String(format: "%.2f", attributes.position))\nspacing: \(String(format: "%.2f", spacing))\ncopy.isEqual: \(copy.isEqual(attributes))"
    }
}

/// Demonstrates both documented extension points without changing the library.
final class DemoTiltTransformer: TFYSwiftPagerViewTransformer {
    override func proposedInteritemSpacing() -> CGFloat { pagerView?.interitemSpacing ?? 0 }
    override func applyTransform(to attributes: TFYSwiftPagerViewLayoutAttributes) {
        let distance = min(abs(attributes.position), 1)
        let scale = max(minimumScale, 1 - distance * 0.2)
        attributes.transform = CGAffineTransform(rotationAngle: attributes.position * rotationAngle * 0.15).scaledBy(x: scale, y: scale)
        attributes.alpha = max(minimumAlpha, 1 - distance)
        attributes.zIndex = 100 - Int(distance * 10)
    }
}
