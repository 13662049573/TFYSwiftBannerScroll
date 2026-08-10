//
//  TransformersDemoViewController.swift
//  TFYSwiftBannerScroll
//

import UIKit

final class TransformersDemoViewController: DemoPagerBaseViewController {
    
    private let types = PagerViewTransformerType.allCases
    private var typeIndex = 0
    private let typeLabel = UILabel()
    
    init() {
        super.init(title: "转场动画画廊")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureDemo() {
        pagerView.isInfinite = true
        pagerView.automaticSlidingInterval = 3
        pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 100, height: 180)
        applyType(at: 0)
        
        typeLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        typeLabel.textAlignment = .center
        typeLabel.numberOfLines = 2
        controlsContainer.addArrangedSubview(typeLabel)
        
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        row.addArrangedSubview(makeButton("上一个") { [weak self] in self?.step(-1) })
        row.addArrangedSubview(makeButton("下一个") { [weak self] in self?.step(1) })
        controlsContainer.addArrangedSubview(row)
        
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "minimumScale", value: 0.65) { [weak self] v in
                self?.pagerView.transformer?.minimumScale = CGFloat(v)
                self?.pagerView.reloadData()
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "minimumAlpha", value: 0.6) { [weak self] v in
                self?.pagerView.transformer?.minimumAlpha = CGFloat(v)
                self?.pagerView.reloadData()
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "parallaxFactor", value: 0.25) { [weak self] v in
                self?.pagerView.parallaxFactor = CGFloat(v) * 2
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "rotationAngle", value: 0.5) { [weak self] v in
                self?.pagerView.rotationAngle = CGFloat(v) * .pi
            }
        )
        controlsContainer.addArrangedSubview(
            makeSliderRow(title: "waveHeight", value: 0.5) { [weak self] v in
                self?.pagerView.transformer?.waveHeight = CGFloat(v) * 100
                self?.pagerView.reloadData()
            }
        )
    }
    
    private func step(_ delta: Int) {
        typeIndex = (typeIndex + delta + types.count) % types.count
        applyType(at: typeIndex)
    }
    
    private func applyType(at index: Int) {
        let type = types[index]
        let transformer = TFYSwiftPagerViewTransformer(type: type)
        pagerView.transformer = transformer
        if type == .grid {
            pagerView.configureGridLayout(rows: 2, columns: 3, spacing: 8)
            pageControl.isHiddenInGridMode = true
            pagerView.automaticSlidingInterval = 0
        } else {
            pageControl.isHiddenInGridMode = false
            pageControl.isHidden = false
            pagerView.isPagingEnabled = false
            pagerView.itemSize = CGSize(width: UIScreen.main.bounds.width - 100, height: 180)
            if pagerView.automaticSlidingInterval == 0 {
                pagerView.automaticSlidingInterval = 3
            }
        }
        let verticalNote = type.supportsVertical ? "支持垂直" : "仅水平"
        typeLabel.text = "\(type.displayName)（\(index + 1)/\(types.count)）\n\(verticalNote)"
        setStatus("transformer = \(type.displayName)")
    }
}

extension PagerViewTransformerType: CaseIterable {
    public static var allCases: [PagerViewTransformerType] {
        (0..<21).compactMap { PagerViewTransformerType(rawValue: $0) }
    }
}
