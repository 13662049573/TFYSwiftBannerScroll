//
//  CustomCellDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class CustomCellDemoViewController: DemoPagerBaseViewController {
    
    init() {
        super.init(title: "自定义 Cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.register(DemoBannerCell.self, forCellWithReuseIdentifier: "custom")
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 3
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 64, height: 200)
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: .linear)
        setStatus("自定义 Cell + CTA 按钮")
        
        controlsContainer.addArrangedSubview(
            makeButton("切换 linear / coverFlow") { [weak self] in
                guard let self else { return }
                let next: PagerViewTransformerType = self.pagerView.transformer?.type == .linear ? .coverFlow : .linear
                self.pagerView.transformer = TFYSwiftPagerViewTransformer(type: next)
                self.setStatus("transformer = \(next.displayName)")
            }
        )
    }
    
    override func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "custom", at: index) as! DemoBannerCell
        cell.configure(imageName: imageNames[index], title: "自定义 Banner #\(index + 1)")
        cell.onActionTap = { [weak self] in
            self?.setStatus("点击了 CTA，index=\(index)")
        }
        return cell
    }
}
