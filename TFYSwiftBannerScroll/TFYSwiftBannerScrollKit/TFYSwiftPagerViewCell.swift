//
//  TFYSwiftPagerViewCell.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/19.
//

import UIKit

open class TFYSwiftPagerViewCell: UICollectionViewCell {
    
    /// 返回用于页导航视图单元格的主要文本内容的标签。
    @objc
    open var textLabel: UILabel? {
        if let _ = _textLabel {
            return _textLabel
        }
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        let textLabel = UILabel(frame: .zero)
        textLabel.textColor = .white
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.adjustsFontForContentSizeCategory = true
        self.contentView.addSubview(view)
        view.addSubview(textLabel)

        _textLabel = textLabel
        return textLabel
    }
    
    /// 返回页导航视图单元格的图像视图。
    @objc
    open var imageView: UIImageView? {
        if let _ = _imageView {
            return _imageView
        }
        let imageView = UIImageView(frame: .zero)
        self.contentView.insertSubview(imageView, at: 0)
        _imageView = imageView
        return imageView
    }
    
    /// 是否显示默认阴影。默认 false，降低滚动时的绘制开销。
    @objc open var isShadowEnabled: Bool = false {
        didSet {
            self.applyShadowSettings()
        }
    }
    
    fileprivate weak var _textLabel: UILabel?
    fileprivate weak var _imageView: UIImageView?
    
    fileprivate let selectionColor = UIColor(white: 0.2, alpha: 0.2)
    
    fileprivate weak var _selectedForegroundView: UIView?
    fileprivate var selectedForegroundView: UIView? {
        guard _selectedForegroundView == nil else {
            return _selectedForegroundView
        }
        guard let imageView = _imageView else {
            return nil
        }
        let view = UIView(frame: imageView.bounds)
        imageView.addSubview(view)
        _selectedForegroundView = view
        return view
    }
    
    open override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            if newValue {
                self.selectedForegroundView?.layer.backgroundColor = self.selectionColor.cgColor
            } else if !super.isSelected {
                self.selectedForegroundView?.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        get {
            return super.isHighlighted
        }
    }
    
    open override var isSelected: Bool {
        set {
            super.isSelected = newValue
            self.selectedForegroundView?.layer.backgroundColor = newValue ? self.selectionColor.cgColor : UIColor.clear.cgColor
        }
        get {
            return super.isSelected
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.applyShadowSettings()
    }
    
    fileprivate func applyShadowSettings() {
        if self.isShadowEnabled {
            self.contentView.layer.shadowColor = UIColor.black.cgColor
            self.contentView.layer.shadowRadius = 5
            self.contentView.layer.shadowOpacity = 0.35
            self.contentView.layer.shadowOffset = .zero
        } else {
            self.contentView.layer.shadowOpacity = 0
            self.contentView.layer.shadowRadius = 0
            self.contentView.layer.shadowPath = nil
        }
        self.setNeedsLayout()
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard _textLabel != nil else { return }
        if self.traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            self.setNeedsLayout()
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = _imageView {
            imageView.frame = self.contentView.bounds
        }
        if let textLabel = _textLabel, let container = textLabel.superview {
            var rect = self.contentView.bounds
            let height = textLabel.font.pointSize * 1.5
            rect.size.height = height
            rect.origin.y = self.contentView.frame.height - height
            container.frame = rect
            var labelRect = container.bounds.insetBy(dx: 8, dy: 0)
            labelRect.size.height -= 1
            labelRect.origin.y += 1
            textLabel.frame = labelRect
        }
        self.contentView.layer.shadowPath = self.isShadowEnabled ? UIBezierPath(rect: self.contentView.bounds).cgPath : nil
        if let selectedForegroundView = _selectedForegroundView {
            selectedForegroundView.frame = self.contentView.bounds
        }
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.transform = .identity
        self.transform3D = CATransform3DIdentity
        self.alpha = 1.0
        self.layer.zPosition = 0
    }
}
