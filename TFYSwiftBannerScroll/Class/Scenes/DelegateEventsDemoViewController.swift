import UIKit

final class DelegateEventsDemoViewController: DemoPagerBaseViewController {
    private let logView = UITextView()
    private var lines: [String] = []
    private var allowHighlight = true
    private var allowSelection = true
    private var ready = false
    private var lastScrollLog = Date.distantPast
    private let formatter: DateFormatter = {
        let formatter = DateFormatter(); formatter.dateFormat = "HH:mm:ss.SSS"; return formatter
    }()
    init() { super.init(title: "数据源与代理事件") }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func configureDemo() {
        describe("点击、拖动或程序翻页，对照真实回调顺序。didScroll 最多每 0.25 秒记录一次。")
        useCardSize()
        pagerView.isInfinite = true
        let behavior = addSection("回调与拦截")
        behavior.addArrangedSubview(makeSwitchRow(title: "允许高亮 shouldHighlight", isOn: true) { [weak self] in self?.allowHighlight = $0 })
        behavior.addArrangedSubview(makeSwitchRow(title: "允许选择 shouldSelect", isOn: true) { [weak self] in self?.allowSelection = $0 })
        behavior.addArrangedSubview(makeSwitchRow(title: "自动轮播产生回调", isOn: false) { [weak self] in self?.pagerView.automaticSlidingInterval = $0 ? 2 : 0 })
        behavior.addArrangedSubview(makeButton("重载并观察数据源回调") { [weak self] in self?.pagerView.reloadData() })
        behavior.addArrangedSubview(makeButton("程序翻页并观察动画结束") { [weak self] in
            guard let self else { return }; self.pagerView.scrollToItem(at: (self.pagerView.currentIndex + 1) % self.imageNames.count, animated: true)
        })
        let log = addSection("事件日志", detail: "包含两个数据源方法及全部 12 个可选代理方法；最多保留 100 条。")
        logView.isEditable = false
        logView.font = .preferredFont(forTextStyle: .caption1)
        logView.adjustsFontForContentSizeCategory = true
        logView.backgroundColor = .secondarySystemGroupedBackground
        logView.layer.cornerRadius = 14
        logView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        logView.accessibilityIdentifier = "delegate.log"
        logView.heightAnchor.constraint(equalToConstant: 260).isActive = true
        log.addArrangedSubview(logView)
        log.addArrangedSubview(makeButton("清空日志") { [weak self] in self?.lines.removeAll(); self?.logView.text = "" })
        ready = true
        append("ready：开始交互")
    }
    private func append(_ message: String) {
        guard ready else { return }
        lines.append("[\(formatter.string(from: Date()))] \(message)")
        if lines.count > 100 { lines.removeFirst(lines.count - 100) }
        logView.text = lines.joined(separator: "\n")
        logView.scrollRangeToVisible(NSRange(location: max(logView.text.utf16.count - 1, 0), length: 1))
        setStatus(message)
    }
    override func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int {
        append("numberOfItems → \(imageNames.count)"); return imageNames.count
    }
    override func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        append("cellForItemAt \(index)"); return super.pagerView(pagerView, cellForItemAt: index)
    }
    func pagerView(_ pagerView: TFYSwiftPagerView, shouldHighlightItemAt index: Int) -> Bool {
        append("shouldHighlight \(index) → \(allowHighlight)"); return allowHighlight
    }
    func pagerView(_ pagerView: TFYSwiftPagerView, didHighlightItemAt index: Int) { append("didHighlight \(index)") }
    func pagerView(_ pagerView: TFYSwiftPagerView, shouldSelectItemAt index: Int) -> Bool {
        append("shouldSelect \(index) → \(allowSelection)"); return allowSelection
    }
    override func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        append("didSelect \(index)"); pagerView.deselectItem(at: index, animated: true)
    }
    func pagerView(_ pagerView: TFYSwiftPagerView, willDisplay cell: TFYSwiftPagerViewCell, forItemAt index: Int) { append("willDisplay \(index)") }
    func pagerView(_ pagerView: TFYSwiftPagerView, didEndDisplaying cell: TFYSwiftPagerViewCell, forItemAt index: Int) { append("didEndDisplaying \(index)") }
    func pagerViewWillBeginDragging(_ pagerView: TFYSwiftPagerView) { append("willBeginDragging") }
    override func pagerViewWillEndDragging(_ pagerView: TFYSwiftPagerView, targetIndex: Int) { append("willEndDragging → \(targetIndex)") }
    override func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView) {
        super.pagerViewDidScroll(pagerView)
        if Date().timeIntervalSince(lastScrollLog) >= 0.25 {
            lastScrollLog = Date(); append(String(format: "didScroll offset=%.2f", pagerView.scrollOffset))
        }
    }
    override func pagerViewDidEndScrollAnimation(_ pagerView: TFYSwiftPagerView) {
        append("didEndScrollAnimation \(pagerView.currentIndex)"); syncPageControl(to: pagerView.currentIndex)
    }
    override func pagerViewDidEndDecelerating(_ pagerView: TFYSwiftPagerView) {
        append("didEndDecelerating \(pagerView.currentIndex)"); syncPageControl(to: pagerView.currentIndex)
    }
    override func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int) {
        append("didChangeIndex \(index)"); syncPageControl(to: index)
    }
}
