//
//  PageControlDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class PageControlDemoViewController: DemoPagerBaseViewController {
    
    init() {
        super.init(title: "页面指示器")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 2.5
        pagerView.itemSize = TFYSwiftPagerView.automaticSize
        pageControl.contentInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        setStatus("指示器样式演示")
        
        let styles: [(String, () -> Void)] = [
            ("默认", { [weak self] in self?.resetStyle() }),
            ("镂空圆环", { [weak self] in
                self?.resetStyle()
                self?.pageControl.setStrokeColor(.systemGreen, for: .normal)
                self?.pageControl.setFillColor(.systemGreen, for: .selected)
            }),
            ("自定义图片", { [weak self] in
                self?.resetStyle()
                self?.pageControl.setImage(UIImage(named: "normalImage"), for: .normal)
                self?.pageControl.setImage(UIImage(named: "currentImage"), for: .selected)
            }),
            ("五角星路径", { [weak self] in
                self?.resetStyle()
                let path = self?.starPath(size: self?.pageControl.itemSpacing ?? 8)
                self?.pageControl.setStrokeColor(.systemYellow, for: .normal)
                self?.pageControl.setFillColor(.systemYellow, for: .selected)
                self?.pageControl.setPath(path, for: .normal)
                self?.pageControl.setPath(path, for: .selected)
            }),
            ("半透明", { [weak self] in
                self?.resetStyle()
                self?.pageControl.setFillColor(.systemBlue, for: .selected)
                self?.pageControl.setFillColor(.systemGray, for: .normal)
                self?.pageControl.setAlpha(0.35, for: .normal)
                self?.pageControl.setAlpha(1, for: .selected)
            })
        ]
        
        for (title, action) in styles {
            controlsContainer.addArrangedSubview(makeButton(title, action: action))
        }
        
        controlsContainer.addArrangedSubview(
            makeButton("对齐：左 / 中 / 右 循环") { [weak self] in
                guard let self else { return }
                let next: [UIControl.ContentHorizontalAlignment] = [.left, .center, .right]
                let current = self.pageControl.contentHorizontalAlignment
                let idx = ((next.firstIndex(of: current) ?? -1) + 1) % next.count
                self.pageControl.contentHorizontalAlignment = next[idx]
                self.setStatus("alignment index = \(idx)")
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "指示器大小", value: 0.3) { [weak self] v in
                self?.pageControl.itemSpacing = 6 + CGFloat(v) * 12
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "指示器间距", value: 0.3) { [weak self] v in
                self?.pageControl.interitemSpacing = 4 + CGFloat(v) * 16
            }
        )
        controlsContainer.addArrangedSubview(
            makeSwitchRow(title: "hidesForSinglePage", isOn: false) { [weak self] on in
                self?.pageControl.hidesForSinglePage = on
            }
        )
    }
    
    private func resetStyle() {
        pageControl.setStrokeColor(nil, for: .normal)
        pageControl.setStrokeColor(nil, for: .selected)
        pageControl.setFillColor(.systemGray3, for: .normal)
        pageControl.setFillColor(.systemBlue, for: .selected)
        pageControl.setImage(nil, for: .normal)
        pageControl.setImage(nil, for: .selected)
        pageControl.setPath(nil, for: .normal)
        pageControl.setPath(nil, for: .selected)
        pageControl.setAlpha(1, for: .normal)
        pageControl.setAlpha(1, for: .selected)
    }
    
    private func starPath(size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size * 0.5, y: 0))
        path.addLine(to: CGPoint(x: size * 0.677, y: size * 0.257))
        path.addLine(to: CGPoint(x: size * 0.975, y: size * 0.345))
        path.addLine(to: CGPoint(x: size * 0.785, y: size * 0.593))
        path.addLine(to: CGPoint(x: size * 0.794, y: size * 0.905))
        path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.8))
        path.addLine(to: CGPoint(x: size * 0.206, y: size * 0.905))
        path.addLine(to: CGPoint(x: size * 0.215, y: size * 0.593))
        path.addLine(to: CGPoint(x: size * 0.025, y: size * 0.345))
        path.addLine(to: CGPoint(x: size * 0.323, y: size * 0.257))
        path.close()
        return path
    }
}
