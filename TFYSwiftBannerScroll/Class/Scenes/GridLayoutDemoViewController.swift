import UIKit

final class GridLayoutDemoViewController: DemoPagerBaseViewController {
    private var rows = 2
    private var columns = 3
    private var spacing: CGFloat = 10
    init() { super.init(title: "网格分页", imageNames: DemoImages.all) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func configureDemo() {
        describe("网格以页为单位滚动，currentIndex 代表当前页第一项。支持不满一页和垂直分页。")
        // Intentionally configure before transformer assignment to demonstrate cached configuration.
        pagerView.configureGridLayout(rows: rows, columns: columns, spacing: spacing)
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: .grid)
        updatePageCount()
        let config = addSection("网格参数")
        config.addArrangedSubview(makeSliderRow(title: "行数 gridRows", value: 2, min: 1, max: 4, step: 1) { [weak self] in self?.rows = Int($0.rounded()); self?.applyGrid() })
        config.addArrangedSubview(makeSliderRow(title: "列数 gridColumns", value: 3, min: 1, max: 5, step: 1) { [weak self] in self?.columns = Int($0.rounded()); self?.applyGrid() })
        config.addArrangedSubview(makeSliderRow(title: "网格间距 gridSpacing", value: 10, min: 0, max: 30) { [weak self] in self?.spacing = CGFloat($0); self?.applyGrid() })
        config.addArrangedSubview(makeChoiceRow(title: "分页方向", options: ["水平", "垂直"]) { [weak self] in self?.pagerView.scrollDirection = $0 == 0 ? .horizontal : .vertical })
        config.addArrangedSubview(makeSwitchRow(title: "自动按页轮播", isOn: false) { [weak self] in self?.pagerView.automaticSlidingInterval = $0 ? 2.5 : 0 })
        config.addArrangedSubview(makeSwitchRow(title: "隐藏网格指示器", isOn: false) { [weak self] in self?.pageControl.isHiddenInGridMode = $0 })
        let navigation = addSection("网格导航")
        navigation.addArrangedSubview(makeSliderRow(title: "定位到指定 item", value: 0, min: 0, max: Float(imageNames.count - 1), step: 1) { [weak self] in self?.pagerView.scrollToItem(at: Int($0.rounded()), animated: false) })
        navigation.addArrangedSubview(makeButton("退出网格 / 恢复网格") { [weak self] in
            guard let self else { return }
            if self.pagerView.transformer?.type == .grid {
                self.pagerView.transformer = nil; self.pagerView.isPagingEnabled = false; self.useCardSize()
            } else { self.pagerView.transformer = TFYSwiftPagerViewTransformer(type: .grid); self.applyGrid() }
            self.updatePageCount()
        })
        addDataControls()
        setStatus("configureGridLayout 先调用、transformer 后设置：缓存参数已应用")
    }
    private func applyGrid() {
        pagerView.configureGridLayout(rows: rows, columns: columns, spacing: spacing)
        updatePageCount()
        setStatus("\(rows) × \(columns)，共 \(pageControl.numberOfPages) 页")
    }
}
