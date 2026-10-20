//
//  TFYSwiftPagerViewLayout.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/19.
//

import UIKit

class TFYSwiftPagerViewLayout: UICollectionViewLayout {

    internal var contentSize: CGSize = .zero
    internal var leadingSpacing: CGFloat = 0
    fileprivate var trailingSpacing: CGFloat = 0

    internal var itemsPerPage: Int {
        guard let transformer = self.pagerView?.transformer, transformer.type == .grid else { return 1 }
        let product = transformer.gridRows.multipliedReportingOverflow(by: transformer.gridColumns)
        return product.overflow ? Int.max : product.partialValue
    }

    internal var pageCount: Int {
        return self.numberOfItems > 0 ? (self.numberOfItems - 1) / self.itemsPerPage + 1 : 0
    }
    internal var itemSpacing: CGFloat = 0
    internal var needsReprepare = true
    internal var scrollDirection: TFYSwiftPagerView.ScrollDirection = .horizontal
    
    open override class var layoutAttributesClass: AnyClass {
        return TFYSwiftPagerViewLayoutAttributes.self
    }
    
    fileprivate var pagerView: TFYSwiftPagerView? {
        return self.collectionView?.superview?.superview as? TFYSwiftPagerView
    }
    
    fileprivate var collectionViewSize: CGSize = .zero
    fileprivate var numberOfSections = 1
    fileprivate var numberOfItems = 0
    fileprivate var actualInteritemSpacing: CGFloat = 0
    fileprivate var actualItemSize: CGSize = .zero
    
    override init() {
        super.init()
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    deinit {
        #if !os(tvOS)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
    }
    
    override open func prepare() {
        guard let collectionView = self.collectionView, let pagerView = self.pagerView else {
            return
        }
        guard self.needsReprepare || self.collectionViewSize != collectionView.frame.size else {
            return
        }
        self.needsReprepare = false
        
        self.collectionViewSize = collectionView.frame.size

        // 计算基本参数/变量
        self.numberOfSections = collectionView.numberOfSections
        self.numberOfItems = self.numberOfSections > 0 ? collectionView.numberOfItems(inSection: 0) : 0
        self.actualItemSize = {
            var size = pagerView.itemSize
            if size == .zero {
                let insets = pagerView.contentInsets
                size = CGSize(width: max(collectionView.bounds.width - insets.left - insets.right, 0),
                              height: max(collectionView.bounds.height - insets.top - insets.bottom, 0))
            }
            return size
        }()
        
        if let transformer = pagerView.transformer, transformer.type == .grid {
            self.adjustLayoutForGridMode()
        } else {
            // 原有的布局计算逻辑
            self.actualInteritemSpacing = {
                if let transformer = pagerView.transformer {
                    return transformer.proposedInteritemSpacing()
                }
                return pagerView.interitemSpacing
            }()
            self.scrollDirection = pagerView.scrollDirection
            let insets = pagerView.contentInsets
            switch self.scrollDirection {
            case .horizontal:
                let centered = (collectionView.frame.width - self.actualItemSize.width) * 0.5
                self.leadingSpacing = pagerView.itemSize == .zero ? insets.left : max(centered, insets.left)
                self.trailingSpacing = pagerView.itemSize == .zero ? insets.right : max(centered, insets.right)
            case .vertical:
                let centered = (collectionView.frame.height - self.actualItemSize.height) * 0.5
                self.leadingSpacing = pagerView.itemSize == .zero ? insets.top : max(centered, insets.top)
                self.trailingSpacing = pagerView.itemSize == .zero ? insets.bottom : max(centered, insets.bottom)
            }
            self.itemSpacing = (self.scrollDirection == .horizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing
            
            self.contentSize = {
                let numberOfItems = self.numberOfItems * self.numberOfSections
                switch self.scrollDirection {
                case .horizontal:
                    var contentSizeWidth: CGFloat = self.leadingSpacing + self.trailingSpacing
                    contentSizeWidth += CGFloat(max(numberOfItems - 1, 0)) * self.actualInteritemSpacing
                    contentSizeWidth += CGFloat(numberOfItems) * self.actualItemSize.width
                    return CGSize(width: max(contentSizeWidth, collectionView.bounds.width), height: collectionView.bounds.height)
                case .vertical:
                    var contentSizeHeight: CGFloat = self.leadingSpacing + self.trailingSpacing
                    contentSizeHeight += CGFloat(max(numberOfItems - 1, 0)) * self.actualInteritemSpacing
                    contentSizeHeight += CGFloat(numberOfItems) * self.actualItemSize.height
                    return CGSize(width: collectionView.bounds.width, height: max(contentSizeHeight, collectionView.bounds.height))
                }
            }()
        }
        self.adjustCollectionViewBounds()
    }
    
    override open var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView,
              let pagerView = self.pagerView else {
            return []
        }
        
        if let transformer = pagerView.transformer, transformer.type == .grid {
            return self.gridLayoutAttributes(in: rect, collectionView: collectionView, pagerView: pagerView, transformer: transformer)
        }
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        guard self.itemSpacing > 0, !rect.isEmpty else {
            return layoutAttributes
        }
        let clippedRect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))
        guard !clippedRect.isEmpty else {
            return layoutAttributes
        }
        let axisSize = self.scrollDirection == .horizontal ? self.actualItemSize.width : self.actualItemSize.height
        // Include partially visible leading cards and neighbours moved into view by a transformer.
        let padding = pagerView.transformer == nil ? axisSize : max(axisSize, self.itemSpacing * 5)
        let minimum = self.scrollDirection == .horizontal ? clippedRect.minX : clippedRect.minY
        let maximum = self.scrollDirection == .horizontal ? clippedRect.maxX : clippedRect.maxY
        let count = self.numberOfItems * self.numberOfSections
        guard count > 0 else { return layoutAttributes }
        let first = Int(max(0, min(CGFloat(count - 1), floor((minimum - self.leadingSpacing - padding) / self.itemSpacing))))
        let last = Int(max(0, min(CGFloat(count - 1), ceil((maximum - self.leadingSpacing + padding) / self.itemSpacing))))
        guard first <= last else { return layoutAttributes }
        for itemIndex in first...last {
            let indexPath = IndexPath(item: itemIndex % self.numberOfItems, section: itemIndex / self.numberOfItems)
            if let attributes = self.layoutAttributesForItem(at: indexPath), attributes.alpha > 0 {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    private func gridLayoutAttributes(
        in rect: CGRect,
        collectionView: UICollectionView,
        pagerView: TFYSwiftPagerView,
        transformer: TFYSwiftPagerViewTransformer
    ) -> [UICollectionViewLayoutAttributes] {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        let numberOfItems = self.numberOfItems
        guard numberOfItems > 0 else { return layoutAttributes }
        
        let itemsPerPage = self.itemsPerPage
        let pageWidth = collectionView.bounds.width
        let pageHeight = collectionView.bounds.height
        let totalPages = self.pageCount

        let minPage: Int
        let maxPage: Int
        switch pagerView.scrollDirection {
        case .horizontal:
            guard pageWidth > 0 else { return layoutAttributes }
            minPage = max(Int(floor(rect.minX / pageWidth)), 0)
            maxPage = min(Int(ceil(rect.maxX / pageWidth)), totalPages - 1)
        case .vertical:
            guard pageHeight > 0 else { return layoutAttributes }
            minPage = max(Int(floor(rect.minY / pageHeight)), 0)
            maxPage = min(Int(ceil(rect.maxY / pageHeight)), totalPages - 1)
        }
        guard minPage <= maxPage else { return layoutAttributes }
        
        for page in minPage...maxPage {
            let startIndex = page * itemsPerPage
            let endIndex = startIndex + min(itemsPerPage, numberOfItems - startIndex)
            guard startIndex < numberOfItems && startIndex < endIndex else { continue }
            
            for index in startIndex..<endIndex {
                guard let attributes = self.layoutAttributesForItem(at: IndexPath(item: index, section: 0)),
                      attributes.frame.intersects(rect) else { continue }
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard (0..<self.numberOfSections).contains(indexPath.section),
              (0..<self.numberOfItems).contains(indexPath.item) else { return nil }
        let attributes = TFYSwiftPagerViewLayoutAttributes(forCellWith: indexPath)
        attributes.indexPath = indexPath
        let frame = self.frame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = self.actualItemSize
        if self.pagerView?.transformer?.type == .grid {
            attributes.position = CGFloat(indexPath.item / self.itemsPerPage)
        } else {
            self.applyTransform(to: attributes, with: self.pagerView?.transformer)
        }
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView, let pagerView = self.pagerView, self.itemSpacing > 0 else {
            return proposedContentOffset
        }
        
        let axisVelocity = self.scrollDirection == .horizontal ? velocity.x : velocity.y
        let currentOffset = self.scrollDirection == .horizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y
        
        func calculateTargetOffset(by proposedOffset: CGFloat, boundedOffset: CGFloat) -> CGFloat {
            var targetOffset: CGFloat
            if pagerView.decelerationDistance == TFYSwiftPagerView.automaticDistance {
                if abs(axisVelocity) >= 0.3 {
                    let vector: CGFloat = axisVelocity >= 0 ? 1.0 : -1.0
                    targetOffset = round(proposedOffset / self.itemSpacing + 0.35 * vector) * self.itemSpacing
                } else {
                    targetOffset = round(proposedOffset / self.itemSpacing) * self.itemSpacing
                }
            } else {
                let distance = CGFloat(max(pagerView.decelerationDistance, 1))
                switch axisVelocity {
                case 0.3 ... CGFloat.greatestFiniteMagnitude:
                    targetOffset = (floor(currentOffset / self.itemSpacing) + distance) * self.itemSpacing
                case -CGFloat.greatestFiniteMagnitude ... -0.3:
                    targetOffset = (ceil(currentOffset / self.itemSpacing) - distance) * self.itemSpacing
                default:
                    targetOffset = round(proposedOffset / self.itemSpacing) * self.itemSpacing
                }
            }
            return min(max(0, targetOffset), boundedOffset)
        }
        
        var result = proposedContentOffset
        switch self.scrollDirection {
        case .horizontal:
            let boundedOffset = max(collectionView.contentSize.width - collectionView.bounds.width, 0)
            result.x = calculateTargetOffset(by: proposedContentOffset.x, boundedOffset: boundedOffset)
        case .vertical:
            let boundedOffset = max(collectionView.contentSize.height - collectionView.bounds.height, 0)
            result.y = calculateTargetOffset(by: proposedContentOffset.y, boundedOffset: boundedOffset)
        }
        return result
    }
    
    // MARK: ——内部函数
    
    internal func forceInvalidate() {
        self.needsReprepare = true
        self.invalidateLayout()
    }
    
    internal func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let offset: CGFloat
        if self.pagerView?.transformer?.type == .grid {
            offset = CGFloat(indexPath.item / self.itemsPerPage) * self.itemSpacing
        } else {
            offset = CGFloat(self.numberOfItems * indexPath.section + indexPath.item) * self.itemSpacing
        }
        guard let collectionView = self.collectionView else { return .zero }
        switch self.scrollDirection {
        case .horizontal:
            return CGPoint(x: min(max(offset, 0), max(self.contentSize.width - collectionView.bounds.width, 0)), y: 0)
        case .vertical:
            return CGPoint(x: 0, y: min(max(offset, 0), max(self.contentSize.height - collectionView.bounds.height, 0)))
        }
    }

    internal func itemIndex(forOffset offset: CGFloat) -> Int {
        guard self.itemSpacing > 0, self.numberOfItems > 0, offset.isFinite else { return 0 }
        let totalUnits = self.pagerView?.transformer?.type == .grid
            ? self.pageCount : self.numberOfItems * self.numberOfSections
        let unit = Int(min(max(round(offset / self.itemSpacing), 0), CGFloat(max(totalUnits - 1, 0))))
        return self.pagerView?.transformer?.type == .grid
            ? unit * self.itemsPerPage : unit % self.numberOfItems
    }

    internal func frame(for indexPath: IndexPath) -> CGRect {
        guard let collectionView = self.collectionView, let pagerView = self.pagerView else { return .zero }
        let insets = pagerView.contentInsets
        if let transformer = pagerView.transformer, transformer.type == .grid {
            let page = indexPath.item / self.itemsPerPage
            let localIndex = indexPath.item % self.itemsPerPage
            let row = localIndex / transformer.gridColumns
            let column = localIndex % transformer.gridColumns
            let x = insets.left + CGFloat(column) * (self.actualItemSize.width + transformer.gridSpacing)
            let y = insets.top + CGFloat(row) * (self.actualItemSize.height + transformer.gridSpacing)
            return CGRect(x: x + (self.scrollDirection == .horizontal ? CGFloat(page) * collectionView.bounds.width : 0),
                          y: y + (self.scrollDirection == .vertical ? CGFloat(page) * collectionView.bounds.height : 0),
                          width: self.actualItemSize.width, height: self.actualItemSize.height)
        }
        let numberOfItems = self.numberOfItems * indexPath.section + indexPath.item
        let crossX = insets.left + (collectionView.bounds.width - insets.left - insets.right - self.actualItemSize.width) * 0.5
        let crossY = insets.top + (collectionView.bounds.height - insets.top - insets.bottom - self.actualItemSize.height) * 0.5
        return CGRect(x: self.scrollDirection == .horizontal ? self.leadingSpacing + CGFloat(numberOfItems) * self.itemSpacing : crossX,
                      y: self.scrollDirection == .vertical ? self.leadingSpacing + CGFloat(numberOfItems) * self.itemSpacing : crossY,
                      width: self.actualItemSize.width, height: self.actualItemSize.height)
    }

    // MARK:- 通知
    @objc
    fileprivate func didReceiveNotification(notification: Notification) {
        if self.pagerView?.itemSize == .zero {
            self.adjustCollectionViewBounds()
        }
    }
    
    // MARK:- 私有函数
    
    fileprivate func commonInit() {
        #if !os(tvOS)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        #endif
    }
    
    fileprivate func adjustCollectionViewBounds() {
        guard let collectionView = self.collectionView, let pagerView = self.pagerView else {
            return
        }
        let currentIndex = pagerView.currentIndex
        let newIndexPath = IndexPath(item: min(currentIndex, max(self.numberOfItems - 1, 0)), section: self.numberOfSections > 1 ? self.numberOfSections / 2 : 0)
        let contentOffset = self.contentOffset(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
    }
    
    fileprivate func applyTransform(to attributes: TFYSwiftPagerViewLayoutAttributes, with transformer: TFYSwiftPagerViewTransformer?) {
        guard let collectionView = self.collectionView, self.itemSpacing > 0 else {
            return
        }
        switch self.scrollDirection {
        case .horizontal:
            let ruler = collectionView.bounds.midX
            attributes.position = (attributes.center.x - ruler) / self.itemSpacing
        case .vertical:
            let ruler = collectionView.bounds.midY
            attributes.position = (attributes.center.y - ruler) / self.itemSpacing
        }
        attributes.zIndex = Int(self.numberOfItems) - Int(attributes.position)
        transformer?.applyTransform(to: attributes)
    }
    
    internal func adjustLayoutForGridMode() {
        guard let pagerView = self.pagerView,
              let transformer = pagerView.transformer,
              transformer.type == .grid else {
            return
        }
        
        let rows = transformer.gridRows
        let columns = transformer.gridColumns
        let spacing = transformer.gridSpacing
        
        // 计算每页可以显示的总item数
        // 计算item的实际大小，考虑容器大小和间距
        let containerWidth = self.collectionView?.bounds.width ?? 0
        let containerHeight = self.collectionView?.bounds.height ?? 0
        let insets = pagerView.contentInsets
        
        let itemWidth = max(containerWidth - insets.left - insets.right - CGFloat(columns - 1) * spacing, 0) / CGFloat(columns)
        let itemHeight = max(containerHeight - insets.top - insets.bottom - CGFloat(rows - 1) * spacing, 0) / CGFloat(rows)
        
        self.actualItemSize = CGSize(width: itemWidth, height: itemHeight)
        self.actualInteritemSpacing = spacing
        
        // 计算总页数
        let numberOfPages = CGFloat(self.pageCount)
        
        // 根据滚动方向设置 contentSize
        switch pagerView.scrollDirection {
        case .horizontal:
            self.contentSize = CGSize(
                width: containerWidth * numberOfPages,
                height: containerHeight
            )
        case .vertical:
            self.contentSize = CGSize(
                width: containerWidth,
                height: containerHeight * numberOfPages
            )
        }
        
        // 设置为0以避免自动居中；itemSpacing 用页宽/高，避免 scrollOffset 除零
        self.leadingSpacing = 0
        switch pagerView.scrollDirection {
        case .horizontal:
            self.itemSpacing = max(containerWidth, 1)
        case .vertical:
            self.itemSpacing = max(containerHeight, 1)
        }
        self.scrollDirection = pagerView.scrollDirection
    }
}
