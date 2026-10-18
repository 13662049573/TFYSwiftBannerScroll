//
//  TFYSwiftPageControl.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/19.
//

import UIKit

open class TFYSwiftPageControl: UIControl {

    /// 页面控件的页面指示器数量。默认值为0。
    open var numberOfPages: Int = 0 {
        didSet {
            self.numberOfPages = max(self.numberOfPages, 0)
            self.currentPage = min(max(self.currentPage, 0), max(self.numberOfPages - 1, 0))
            self.setNeedsCreateIndicators()
        }
    }
    
    /// 当前页，由页面控件高亮显示。默认值为0。
    open var currentPage: Int = 0 {
        didSet {
            self.currentPage = min(max(self.currentPage, 0), max(self.numberOfPages - 1, 0))
            self.setNeedsUpdateIndicators()
        }
    }
    
    /// 页控件中使用的页指示器的间距。
    open var itemSpacing: CGFloat = 6 {
        didSet {
            self.setNeedsUpdateIndicators()
        }
    }
    
    /// 页控件中页指示器之间使用的间距。
    open var interitemSpacing: CGFloat = 6 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 插入的页指示符与外围页控件的距离。
    open var contentInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 控件边界内内容的水平对齐方式。默认是中心。
    open override var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 如果只有一个页面，则隐藏该指示器。默认是 false。
    open var hidesForSinglePage: Bool = false {
        didSet {
            self.setNeedsUpdateIndicators()
        }
    }
    
    /// 便捷隐藏开关（例如网格模式）。设置后会同步 `isHidden`。
    @objc open var isHiddenInGridMode: Bool = false {
        didSet {
            self.isHidden = isHiddenInGridMode
            self.setNeedsLayout()
        }
    }
    
    fileprivate var strokeColors: [UInt: UIColor] = [:]
    fileprivate var fillColors: [UInt: UIColor] = [:]
    fileprivate var paths: [UInt: UIBezierPath] = [:]
    fileprivate var images: [UInt: UIImage] = [:]
    fileprivate var alphas: [UInt: CGFloat] = [:]
    
    fileprivate weak var contentView: UIView!
    
    fileprivate var needsUpdateIndicators = false
    fileprivate var needsCreateIndicators = false
    fileprivate var indicatorLayers = [CAShapeLayer]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.createIndicatorsIfNecessary()
        self.updateIndicatorsIfNecessary()
        self.contentView.frame = {
            let x = self.contentInsets.left
            let y = self.contentInsets.top
            let width = max(self.bounds.width - self.contentInsets.left - self.contentInsets.right, 0)
            let height = max(self.bounds.height - self.contentInsets.top - self.contentInsets.bottom, 0)
            return CGRect(x: x, y: y, width: width, height: height)
        }()
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let diameter = self.itemSpacing
        let spacing = self.interitemSpacing
        var x: CGFloat = {
            switch self.contentHorizontalAlignment {
            case .left, .leading:
                return 0
            case .center, .fill:
                let midX = self.contentView.bounds.midX
                let contentWidth = diameter * CGFloat(self.numberOfPages) + spacing * CGFloat(max(self.numberOfPages - 1, 0))
                return midX - contentWidth * 0.5
            case .right, .trailing:
                let contentWidth = diameter * CGFloat(self.numberOfPages) + CGFloat(max(self.numberOfPages - 1, 0)) * spacing
                return contentView.frame.width - contentWidth
            default:
                return 0
            }
        }()
        for (index, value) in self.indicatorLayers.enumerated() {
            let state: UIControl.State = (index == self.currentPage) ? .selected : .normal
            let image = self.images[state.rawValue]
            let size = image?.size ?? CGSize(width: diameter, height: diameter)
            let origin = CGPoint(x: x - (size.width - diameter) * 0.5, y: self.contentView.bounds.midY - size.height * 0.5)
            value.frame = CGRect(origin: origin, size: size)
            x = x + spacing + diameter
        }
    }
    
    @objc(setStrokeColor:forState:)
    open func setStrokeColor(_ strokeColor: UIColor?, for state: UIControl.State) {
        let key = state.rawValue
        guard self.strokeColors[key] != strokeColor else { return }
        self.strokeColors[key] = strokeColor
        self.setNeedsUpdateIndicators()
    }
    
    @objc(setFillColor:forState:)
    open func setFillColor(_ fillColor: UIColor?, for state: UIControl.State) {
        let key = state.rawValue
        guard self.fillColors[key] != fillColor else { return }
        self.fillColors[key] = fillColor
        self.setNeedsUpdateIndicators()
    }
    
    @objc(setImage:forState:)
    open func setImage(_ image: UIImage?, for state: UIControl.State) {
        let key = state.rawValue
        guard self.images[key] != image else { return }
        self.images[key] = image
        self.setNeedsUpdateIndicators()
    }
    
    @objc(setAlpha:forState:)
    open func setAlpha(_ alpha: CGFloat, for state: UIControl.State) {
        let key = state.rawValue
        guard self.alphas[key] != alpha else { return }
        self.alphas[key] = alpha
        self.setNeedsUpdateIndicators()
    }
    
    @objc(setPath:forState:)
    open func setPath(_ path: UIBezierPath?, for state: UIControl.State) {
        let key = state.rawValue
        guard self.paths[key] != path else { return }
        self.paths[key] = path
        self.setNeedsUpdateIndicators()
    }
    
    fileprivate func commonInit() {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        self.addSubview(view)
        self.contentView = view
        self.isUserInteractionEnabled = false
    }
    
    fileprivate func setNeedsUpdateIndicators() {
        self.needsUpdateIndicators = true
        self.setNeedsLayout()

    }
    
    fileprivate func updateIndicatorsIfNecessary() {
        guard self.needsUpdateIndicators else { return }
        guard !self.indicatorLayers.isEmpty else { return }
        self.needsUpdateIndicators = false
        self.contentView.isHidden = self.hidesForSinglePage && self.numberOfPages <= 1
        if !self.contentView.isHidden {
            for (index, layer) in self.indicatorLayers.enumerated() {
                layer.isHidden = false
                self.updateIndicatorAttributes(for: layer, at: index)
            }
        }
    }
    
    fileprivate func updateIndicatorAttributes(for layer: CAShapeLayer, at index: Int) {
        let state: UIControl.State = index == self.currentPage ? .selected : .normal
        let key = state.rawValue
        if let image = self.images[key] {
            layer.strokeColor = nil
            layer.fillColor = nil
            layer.path = nil
            layer.contents = image.cgImage
        } else {
            layer.contents = nil
            let strokeColor = self.strokeColors[key]
            let fillColor = self.fillColors[key]
            if strokeColor == nil && fillColor == nil {
                layer.fillColor = (state == .selected ? UIColor.white : UIColor.gray).cgColor
                layer.strokeColor = nil
            } else {
                layer.strokeColor = strokeColor?.cgColor
                layer.fillColor = fillColor?.cgColor
            }
            layer.path = self.paths[key]?.cgPath
                ?? UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.itemSpacing, height: self.itemSpacing)).cgPath
        }
        layer.opacity = Float(self.alphas[key] ?? 1.0)
    }
    
    fileprivate func setNeedsCreateIndicators() {
        self.needsCreateIndicators = true
        self.setNeedsLayout()
    }
    
    fileprivate func createIndicatorsIfNecessary() {
        guard self.needsCreateIndicators else { return }
        self.needsCreateIndicators = false
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if self.numberOfPages <= 0 {
            self.currentPage = 0
        } else if self.currentPage >= self.numberOfPages {
            self.currentPage = self.numberOfPages - 1
        }
        while self.indicatorLayers.count > self.numberOfPages {
            self.indicatorLayers.removeLast().removeFromSuperlayer()
        }
        while self.indicatorLayers.count < self.numberOfPages {
            let layer = CAShapeLayer()
            layer.actions = ["bounds": NSNull()]
            self.contentView.layer.addSublayer(layer)
            self.indicatorLayers.append(layer)
        }
        self.setNeedsUpdateIndicators()
        self.updateIndicatorsIfNecessary()
        CATransaction.commit()
    }
}
