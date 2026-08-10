//
//  InfiniteAutoplayDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class InfiniteAutoplayDemoViewController: DemoPagerBaseViewController {
    
    init() {
        super.init(title: "无限循环 + 自动轮播")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 2.5
        pagerView.itemSize = TFYSwiftPagerView.automaticSize
        setStatus("自动轮播中（进后台会暂停）")
        
        controlsContainer.addArrangedSubview(
            makeSwitchRow(title: "无限循环 isInfinite", isOn: true) { [weak self] on in
                self?.pagerView.isInfinite = on
            }
        )
        controlsContainer.addArrangedSubview(
            makeSwitchRow(title: "单页时移除无限循环", isOn: false) { [weak self] on in
                self?.pagerView.removesInfiniteLoopForSingleItem = on
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "自动轮播间隔（0=关闭）", value: 0.5, min: 0, max: 1) { [weak self] value in
                let interval = CGFloat(value) * 5
                self?.pagerView.automaticSlidingInterval = interval
                self?.setStatus(interval > 0 ? "间隔 \(String(format: "%.1f", interval))s" : "自动轮播已关闭")
            }
        )
    }
}
