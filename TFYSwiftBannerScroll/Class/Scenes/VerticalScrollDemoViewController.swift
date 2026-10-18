import UIKit

final class VerticalScrollDemoViewController: DemoPagerBaseViewController {
    private let types = PagerViewTransformerType.allCases.filter(\.supportsVertical)
    init() { super.init(title: "垂直滚动") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func configureDemo() {
        describe("直接在上方预览中上下滑动。只列出 supportsVertical 为 true 的样式。")
        useCardSize(width: 0.92, height: 0.7)
        pagerView.scrollDirection = .vertical
        pagerView.isInfinite = true
        let styles = addSection("垂直布局", detail: "仅水平：overlap、linear、coverFlow、ferrisWheel、invertedFerrisWheel。")
        styles.addArrangedSubview(makeChoiceRow(title: "垂直转场", options: ["无转场"] + types.map(\.displayName)) { [weak self] index in
            guard let self else { return }
            self.pagerView.isPagingEnabled = false
            self.pagerView.transformer = index == 0 ? nil : TFYSwiftPagerViewTransformer(type: self.types[index - 1])
            if self.pagerView.transformer?.type == .grid { self.pagerView.configureGridLayout(rows: 2, columns: 3, spacing: 8) }
            else { self.pagerView.isInfinite = true }
            self.updatePageCount()
        })
        styles.addArrangedSubview(makeSwitchRow(title: "自动上下翻页", isOn: false) { [weak self] in self?.pagerView.automaticSlidingInterval = $0 ? 2.5 : 0 })
        styles.addArrangedSubview(makeSwitchRow(title: "始终垂直回弹", isOn: false) { [weak self] in self?.pagerView.alwaysBounceVertical = $0 })
        styles.addArrangedSubview(makeSliderRow(title: "垂直卡片间距", value: 0, min: 0, max: 40) { [weak self] in self?.pagerView.interitemSpacing = CGFloat($0) })
        setStatus("scrollDirection = .vertical")
    }
}
