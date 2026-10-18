import UIKit

final class InfiniteAutoplayDemoViewController: DemoPagerBaseViewController {
    private var savedInterval: CGFloat = 2.5
    init() { super.init(title: "无限循环与自动轮播") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func configureDemo() {
        describe("拖动时暂停，结束减速后恢复；将 App 切到后台再返回，验证真实的生命周期。")
        useAutomaticSize()
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = savedInterval
        setStatus("自动轮播中；0 或 1 项数据不会启动自动翻页")
        let section = addSection("循环与计时")
        section.addArrangedSubview(makeSwitchRow(title: "无限循环 isInfinite", isOn: true) { [weak self] in self?.pagerView.isInfinite = $0 })
        section.addArrangedSubview(makeSwitchRow(title: "单页移除无限循环", isOn: false) { [weak self] in self?.pagerView.removesInfiniteLoopForSingleItem = $0 })
        section.addArrangedSubview(makeSliderRow(title: "自动轮播间隔（秒，0 = 关闭）", value: 2.5, min: 0, max: 6) { [weak self] value in
            self?.savedInterval = CGFloat(value)
            self?.pagerView.automaticSlidingInterval = CGFloat(value)
            self?.setStatus(String(format: "automaticSlidingInterval = %.2f 秒", value))
        })
        section.addArrangedSubview(makeButton("暂停自动轮播") { [weak self] in self?.pagerView.automaticSlidingInterval = 0; self?.setStatus("已暂停") })
        section.addArrangedSubview(makeButton("恢复自动轮播") { [weak self] in
            guard let self else { return }; self.pagerView.automaticSlidingInterval = self.savedInterval; self.setStatus("已恢复设置的间隔")
        })
        section.addArrangedSubview(makeSwitchRow(title: "移除预览以验证离窗暂停", isOn: false) { [weak self] detached in
            guard let self else { return }
            if detached { self.pagerView.removeFromSuperview() }
            else {
                self.attachPagerAfterRemoval()
            }
            self.setStatus(detached ? "预览已离窗；定时器应暂停" : "预览已重新挂载")
        })
        addDataControls()
    }
}
