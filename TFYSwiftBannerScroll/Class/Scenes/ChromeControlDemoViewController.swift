import UIKit

final class ChromeControlDemoViewController: DemoPagerBaseViewController {
    private var observation: NSKeyValueObservation?
    private var targetIndex = 2
    private var animated = true
    private var insets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
    init() { super.init(title: "外观与编程控制") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func configureDemo() {
        describe("独立调节四边边距，选择、定位和查询 Cell，并观察 currentIndex 的 KVO 变化。")
        useAutomaticSize()
        pagerView.contentInsets = insets
        let background = UIView()
        background.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
        pagerView.backgroundView = background
        observation = pagerView.observe(\.currentIndex, options: [.new]) { [weak self] _, change in
            Task { @MainActor [weak self] in self?.setStatus("KVO：currentIndex = \(change.newValue ?? 0)") }
        }
        let section = addSection("编程控制")
        section.addArrangedSubview(makeSliderRow(title: "目标索引", value: 2, min: 0, max: Float(imageNames.count - 1), step: 1) { [weak self] in self?.targetIndex = Int($0.rounded()) })
        section.addArrangedSubview(makeSwitchRow(title: "使用动画", isOn: true) { [weak self] in self?.animated = $0 })
        section.addArrangedSubview(makeButton("滚动到目标项") { [weak self] in
            guard let self else { return }; self.pagerView.scrollToItem(at: self.targetIndex, animated: self.animated)
        })
        section.addArrangedSubview(makeButton("选择目标项") { [weak self] in
            guard let self else { return }; self.pagerView.selectItem(at: self.targetIndex, animated: self.animated)
        })
        section.addArrangedSubview(makeButton("取消选择目标项") { [weak self] in
            guard let self else { return }; self.pagerView.deselectItem(at: self.targetIndex, animated: self.animated); self.setStatus("已取消选择")
        })
        section.addArrangedSubview(makeButton("查询可见 Cell 和索引") { [weak self] in
            guard let self else { return }
            if let cell = self.pagerView.cellForItem(at: self.pagerView.currentIndex) {
                self.setStatus("cellForItem → \(type(of: cell))，index(for:) = \(self.pagerView.index(for: cell))")
            } else { self.setStatus("该项当前不可见，返回 nil") }
        })
        let edges = addSection("内容边距 contentInsets", detail: "使用 automaticSize 直接观察四边留白。")
        let values: [(String, WritableKeyPath<UIEdgeInsets, CGFloat>)] = [("上边距", \.top), ("左边距", \.left), ("下边距", \.bottom), ("右边距", \.right)]
        for (name, key) in values {
            edges.addArrangedSubview(makeSliderRow(title: name, value: Float(insets[keyPath: key]), min: 0, max: 64) { [weak self] value in
                guard let self else { return }; self.insets[keyPath: key] = CGFloat(value); self.pagerView.contentInsets = self.insets
            })
        }
        edges.addArrangedSubview(makeSwitchRow(title: "显示背景视图 backgroundView", isOn: true) { [weak self] on in
            let background = UIView(); background.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
            self?.pagerView.backgroundView = on ? background : nil
        })
        setStatus("滑动后，KVO 结果显示在这里")
    }
}
