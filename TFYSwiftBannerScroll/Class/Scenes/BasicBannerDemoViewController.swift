//
//  BasicBannerDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class BasicBannerDemoViewController: DemoPagerBaseViewController {
    
    init() {
        super.init(title: "基础轮播")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.isInfinite = false
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 80, height: 180)
        pagerView.interitemSpacing = 12
        setStatus("基础轮播：固定 itemSize")
        
        controlsContainer.addArrangedSubview(
            makeSwitchRow(title: "使用 automaticSize（铺满）", isOn: false) { [weak self] on in
                guard let self else { return }
                self.pagerView.itemSize = on ? TFYSwiftPagerView.automaticSize : CGSize(width: UIScreen.main.bounds.width - 80, height: 180)
                self.pagerView.reloadData()
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "item 间距", value: 0.3) { [weak self] value in
                self?.pagerView.interitemSpacing = CGFloat(value) * 40
            }
        )
        controlsContainer.addArrangedSubview(
            makeButton("滚动到第 3 页") { [weak self] in
                self?.pagerView.scrollToItem(at: 2, animated: true)
            }
        )
        controlsContainer.addArrangedSubview(
            makeButton("reloadData") { [weak self] in
                self?.pagerView.reloadData()
                self?.setStatus("reloadData 完成, currentIndex=\(self?.pagerView.currentIndex ?? 0)")
            }
        )
    }
}
