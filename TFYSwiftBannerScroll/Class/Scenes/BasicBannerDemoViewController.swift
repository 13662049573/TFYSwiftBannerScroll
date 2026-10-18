import UIKit

final class BasicBannerDemoViewController: DemoPagerBaseViewController {
    init() { super.init(title: "基础轮播") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func configureDemo() {
        describe("从最简单的无转场轮播开始。切换数据量与卡片尺寸，观察定位和索引变化。")
        useCardSize()
        pagerView.interitemSpacing = 12
        setStatus("手势滑动，或使用下方按钮切换页面")
        let section = addSection("尺寸与布局")
        section.addArrangedSubview(makeSwitchRow(title: "自动铺满 automaticSize", isOn: false) { [weak self] on in
            if on { self?.useAutomaticSize() } else { self?.useCardSize() }
        })
        section.addArrangedSubview(makeSliderRow(title: "卡片宽度比例", value: 0.82, min: 0.4, max: 1) { [weak self] value in
            self?.useCardSize(width: CGFloat(value))
        })
        section.addArrangedSubview(makeSliderRow(title: "卡片高度比例", value: 0.86, min: 0.4, max: 1) { [weak self] value in
            guard let self else { return }
            let ratio = self.pagerView.bounds.width > 0 ? self.pagerView.itemSize.width / self.pagerView.bounds.width : 0.82
            self.useCardSize(width: ratio == 0 ? 0.82 : ratio, height: CGFloat(value))
        })
        section.addArrangedSubview(makeSliderRow(title: "卡片间距 interitemSpacing", value: 12, min: 0, max: 40) { [weak self] in
            self?.pagerView.interitemSpacing = CGFloat($0)
        })
        let navigation = addSection("页面导航", detail: "动画开关同时影响前后翻页与索引跳转。")
        navigation.addArrangedSubview(makeSwitchRow(title: "使用滚动动画", isOn: true) { [weak self] in self?.animated = $0 })
        navigation.addArrangedSubview(makeButton("上一项") { [weak self] in self?.move(-1) })
        navigation.addArrangedSubview(makeButton("下一项") { [weak self] in self?.move(1) })
        navigation.addArrangedSubview(makeSliderRow(title: "跳转索引", value: 0, min: 0, max: Float(imageNames.count - 1), step: 1) { [weak self] value in
            guard let self else { return }
            self.pagerView.scrollToItem(at: Int(value.rounded()), animated: self.animated)
        })
        addDataControls()
    }
    private var animated = true
    private func move(_ delta: Int) {
        guard !imageNames.isEmpty else { setStatus("当前为空数据，请先增加数据"); return }
        let next = (pagerView.currentIndex + delta + imageNames.count) % imageNames.count
        pagerView.scrollToItem(at: next, animated: animated)
    }
}
