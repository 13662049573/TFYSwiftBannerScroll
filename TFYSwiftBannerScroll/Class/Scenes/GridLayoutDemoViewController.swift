//
//  GridLayoutDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class GridLayoutDemoViewController: DemoPagerBaseViewController {
    
    init() {
        super.init(title: "网格布局", imageNames: DemoImages.all)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pageControl.numberOfPages = imageNames.count
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: .grid)
        pagerView.configureGridLayout(rows: 2, columns: 3, spacing: 10)
        pagerView.automaticSlidingInterval = 0
        pageControl.isHiddenInGridMode = true
        setStatus("网格：2x3，分页滑动")
        
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "行数", value: 2, min: 1, max: 4) { [weak self] v in
                self?.pagerView.configureGridLayout(rows: Int(v), columns: self?.pagerView.transformer?.gridColumns ?? 3, spacing: 10)
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "列数", value: 3, min: 1, max: 5) { [weak self] v in
                self?.pagerView.configureGridLayout(rows: self?.pagerView.transformer?.gridRows ?? 2, columns: Int(v), spacing: 10)
            }
        )
        controlsContainer.addArrangedSubview(
            makeButton("退出网格 → 封面流") { [weak self] in
                guard let self else { return }
                self.pageControl.isHiddenInGridMode = false
                self.pageControl.isHidden = false
                self.pagerView.isPagingEnabled = false
                self.pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 100, height: 180)
                self.pagerView.transformer = TFYSwiftPagerViewTransformer(type: .coverFlow)
                self.pagerView.automaticSlidingInterval = 3
                self.setStatus("已退出网格")
            }
        )
    }
}
