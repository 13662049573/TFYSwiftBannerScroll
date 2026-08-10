//
//  ChromeControlDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class ChromeControlDemoViewController: DemoPagerBaseViewController {
    
    init() {
        super.init(title: "外观与控制")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.isInfinite = true
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 120, height: 170)
        pagerView.contentInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: .overlap)
        
        let bg = UIView()
        bg.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.15)
        pagerView.backgroundView = bg
        setStatus("backgroundView + contentInsets + 编程控制")
        
        controlsContainer.addArrangedSubview(
            makeSwitchRow(title: "isPagingEnabled", isOn: false) { [weak self] on in
                self?.pagerView.isPagingEnabled = on
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "contentInsets.left/right", value: 0.4) { [weak self] v in
                let inset = CGFloat(v) * 80
                self?.pagerView.contentInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
            }
        )
        controlsContainer.addArrangedSubview(
            makeButton("selectItem(at: 2)") { [weak self] in
                self?.pagerView.selectItem(at: 2, animated: true)
                self?.setStatus("selectItem 2")
            }
        )
        controlsContainer.addArrangedSubview(
            makeButton("deselectItem(at: 2)") { [weak self] in
                self?.pagerView.deselectItem(at: 2, animated: true)
            }
        )
        controlsContainer.addArrangedSubview(
            makeButton("cellForItem / index(for:)") { [weak self] in
                guard let self else { return }
                if let cell = self.pagerView.cellForItem(at: self.pagerView.currentIndex) {
                    let idx = self.pagerView.index(for: cell)
                    self.setStatus("cellForItem ok, index(for:)=\(idx)")
                } else {
                    self.setStatus("当前页 cell 不可见")
                }
            }
        )
        controlsContainer.addArrangedSubview(
            makeButton("切换 backgroundView") { [weak self] in
                guard let self else { return }
                if self.pagerView.backgroundView == nil {
                    let view = UIView()
                    view.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.2)
                    self.pagerView.backgroundView = view
                    self.setStatus("backgroundView 已设置")
                } else {
                    self.pagerView.backgroundView = nil
                    self.setStatus("backgroundView 已清除")
                }
            }
        )
    }
}
