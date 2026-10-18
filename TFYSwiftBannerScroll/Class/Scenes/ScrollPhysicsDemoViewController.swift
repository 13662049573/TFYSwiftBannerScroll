import UIKit

final class ScrollPhysicsDemoViewController: DemoPagerBaseViewController {
    init() { super.init(title: "滚动物理") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func configureDemo() {
        describe("在预览区域拖动。参数面板独立滚动，垂直轮播也能直接操作。")
        useCardSize(width: 0.78, height: 0.72)
        pagerView.interitemSpacing = 12
        pagerView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        let section = addSection("方向与手势")
        section.addArrangedSubview(makeChoiceRow(title: "滚动方向", options: ["水平", "垂直"]) { [weak self] in
            self?.pagerView.scrollDirection = $0 == 0 ? .horizontal : .vertical
        })
        section.addArrangedSubview(makeSwitchRow(title: "允许滚动 isScrollEnabled", isOn: true) { [weak self] in self?.pagerView.isScrollEnabled = $0 })
        section.addArrangedSubview(makeSwitchRow(title: "启用手势 panGestureRecognizer", isOn: true) { [weak self] in self?.pagerView.panGestureRecognizer.isEnabled = $0 })
        section.addArrangedSubview(makeSwitchRow(title: "整页分页 isPagingEnabled", isOn: false) { [weak self] in self?.pagerView.isPagingEnabled = $0 })
        let bounce = addSection("边缘与减速")
        bounce.addArrangedSubview(makeSwitchRow(title: "边缘回弹 bounces", isOn: true) { [weak self] in self?.pagerView.bounces = $0 })
        bounce.addArrangedSubview(makeSwitchRow(title: "始终水平回弹", isOn: false) { [weak self] in self?.pagerView.alwaysBounceHorizontal = $0 })
        bounce.addArrangedSubview(makeSwitchRow(title: "始终垂直回弹", isOn: false) { [weak self] in self?.pagerView.alwaysBounceVertical = $0 })
        bounce.addArrangedSubview(makeChoiceRow(title: "减速距离", options: ["自动", "1 项", "2 项", "3 项"], selected: 1) { [weak self] in
            self?.pagerView.decelerationDistance = $0 == 0 ? TFYSwiftPagerView.automaticDistance : UInt($0)
        })
        bounce.addArrangedSubview(makeButton("读取当前状态") { [weak self] in
            guard let self else { return }
            self.setStatus("isTracking = \(self.pagerView.isTracking)，手势状态 = \(self.pagerView.panGestureRecognizer.state.rawValue)")
        })
        addDataControls()
        setStatus("拖动预览，实时查看上方索引与偏移")
    }
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: pagerView)
        setStatus(String(format: "panGestureRecognizer：state=%d，速度 %.0f / %.0f", gesture.state.rawValue, velocity.x, velocity.y))
    }
}
