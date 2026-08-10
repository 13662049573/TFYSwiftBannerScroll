//
//  ScrollPhysicsDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class ScrollPhysicsDemoViewController: DemoPagerBaseViewController {
    
    init() {
        super.init(title: "滚动物理")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.isInfinite = false
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 100, height: 180)
        pagerView.decelerationDistance = 1
        pagerView.bounces = true
        setStatus("拖动查看 scrollOffset / isTracking")
        
        controlsContainer.addArrangedSubview(
            makeSwitchRow(title: "isScrollEnabled", isOn: true) { [weak self] on in
                self?.pagerView.isScrollEnabled = on
            }
        )
        controlsContainer.addArrangedSubview(
            makeSwitchRow(title: "bounces", isOn: true) { [weak self] on in
                self?.pagerView.bounces = on
            }
        )
        controlsContainer.addArrangedSubview(
            makeSwitchRow(title: "alwaysBounceHorizontal", isOn: false) { [weak self] on in
                self?.pagerView.alwaysBounceHorizontal = on
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "decelerationDistance (0=automatic)", value: 0.2, min: 0, max: 1) { [weak self] value in
                let distance = UInt(round(value * 5))
                self?.pagerView.decelerationDistance = distance == 0 ? TFYSwiftPagerView.automaticDistance : distance
                self?.setStatus("decelerationDistance = \(distance == 0 ? "automatic" : "\(distance)")")
            }
        )
        controlsContainer.addArrangedSubview(
            makeButton("读取 scrollOffset / isTracking") { [weak self] in
                guard let self else { return }
                self.setStatus(String(format: "offset=%.2f tracking=%@", self.pagerView.scrollOffset, "\(self.pagerView.isTracking)"))
            }
        )
    }
    
    override func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView) {
        setStatus(String(format: "scrollOffset=%.2f  tracking=%@", pagerView.scrollOffset, "\(pagerView.isTracking)"))
    }
}
