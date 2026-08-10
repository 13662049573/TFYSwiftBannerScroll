//
//  DelegateEventsDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class DelegateEventsDemoViewController: DemoPagerBaseViewController {
    
    private let logView = UITextView()
    private var lines: [String] = []
    
    init() {
        super.init(title: "代理事件")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 2
        pagerView.itemSize = TFYSwiftPagerView.automaticSize
        
        logView.translatesAutoresizingMaskIntoConstraints = false
        logView.isEditable = false
        logView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logView.backgroundColor = .secondarySystemBackground
        logView.layer.cornerRadius = 8
        logView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        controlsContainer.addArrangedSubview(logView)
        controlsContainer.addArrangedSubview(makeButton("清空日志") { [weak self] in
            self?.lines.removeAll()
            self?.logView.text = ""
        })
        append("ready")
    }
    
    private func append(_ text: String) {
        let stamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        lines.append("[\(stamp)] \(text)")
        if lines.count > 80 { lines.removeFirst(lines.count - 80) }
        logView.text = lines.joined(separator: "\n")
        let bottom = NSRange(location: max(logView.text.count - 1, 0), length: 1)
        logView.scrollRangeToVisible(bottom)
        setStatus(text)
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, shouldHighlightItemAt index: Int) -> Bool {
        append("shouldHighlight \(index)")
        return true
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, didHighlightItemAt index: Int) {
        append("didHighlight \(index)")
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, shouldSelectItemAt index: Int) -> Bool {
        append("shouldSelect \(index)")
        return true
    }
    
    override func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int) {
        append("didSelect \(index)")
        pagerView.deselectItem(at: index, animated: true)
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, willDisplay cell: TFYSwiftPagerViewCell, forItemAt index: Int) {
        append("willDisplay \(index)")
    }
    
    func pagerView(_ pagerView: TFYSwiftPagerView, didEndDisplaying cell: TFYSwiftPagerViewCell, forItemAt index: Int) {
        append("didEndDisplaying \(index)")
    }
    
    func pagerViewWillBeginDragging(_ pagerView: TFYSwiftPagerView) {
        append("willBeginDragging")
    }
    
    override func pagerViewWillEndDragging(_ pagerView: TFYSwiftPagerView, targetIndex: Int) {
        append("willEndDragging target=\(targetIndex)")
        syncPageControl(to: targetIndex)
    }
    
    override func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView) {
        setStatus(String(format: "didScroll offset=%.2f", pagerView.scrollOffset))
    }
    
    override func pagerViewDidEndScrollAnimation(_ pagerView: TFYSwiftPagerView) {
        append("didEndScrollAnimation index=\(pagerView.currentIndex)")
        syncPageControl(to: pagerView.currentIndex)
    }
    
    override func pagerViewDidEndDecelerating(_ pagerView: TFYSwiftPagerView) {
        append("didEndDecelerating index=\(pagerView.currentIndex)")
        syncPageControl(to: pagerView.currentIndex)
    }
    
    override func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int) {
        append("didChangeIndex \(index)")
        syncPageControl(to: index)
    }
}
