//
//  VerticalScrollDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class VerticalScrollDemoViewController: DemoPagerBaseViewController {
    
    private let verticalTypes = PagerViewTransformerType.allCases.filter(\.supportsVertical)
    private var typeIndex = 0
    private let typeLabel = UILabel()
    
    init() {
        super.init(title: "垂直滚动")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.scrollDirection = .vertical
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 3
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 160)
        applyType(at: 0)
        
        typeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        typeLabel.textAlignment = .center
        controlsContainer.addArrangedSubview(typeLabel)
        
        let tip = UILabel()
        tip.text = "已过滤仅水平动画：overlap / linear / coverFlow / ferrisWheel"
        tip.font = .preferredFont(forTextStyle: .caption1)
        tip.textColor = .secondaryLabel
        tip.numberOfLines = 0
        controlsContainer.addArrangedSubview(tip)
        
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        row.addArrangedSubview(makeButton("上一个") { [weak self] in self?.step(-1) })
        row.addArrangedSubview(makeButton("下一个") { [weak self] in self?.step(1) })
        controlsContainer.addArrangedSubview(row)
    }
    
    private func step(_ delta: Int) {
        typeIndex = (typeIndex + delta + verticalTypes.count) % verticalTypes.count
        applyType(at: typeIndex)
    }
    
    private func applyType(at index: Int) {
        let type = verticalTypes[index]
        pagerView.transformer = TFYSwiftPagerViewTransformer(type: type)
        typeLabel.text = "\(type.displayName)（\(index + 1)/\(verticalTypes.count)）"
        setStatus("vertical + \(type.displayName)")
    }
}
