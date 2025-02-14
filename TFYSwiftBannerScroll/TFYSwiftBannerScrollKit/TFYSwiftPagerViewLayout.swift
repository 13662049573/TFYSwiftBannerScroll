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
        self.numberOfSections = pagerView.numberOfSections(in: collectionView)
        self.numberOfItems = pagerView.collectionView(collectionView, numberOfItemsInSection: 0)
        self.actualItemSize = {
            var size = pagerView.itemSize
            if size == .zero {
                size = collectionView.frame.size
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
            self.leadingSpacing = self.scrollDirection == .horizontal ? (collectionView.frame.width-self.actualItemSize.width)*0.5 : (collectionView.frame.height-self.actualItemSize.height)*0.5
            self.itemSpacing = (self.scrollDirection == .horizontal ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing
            
            // 计算并缓存contentSize，而不是每次都计算
            self.contentSize = {
                let numberOfItems = self.numberOfItems*self.numberOfSections
                switch self.scrollDirection {
                    case .horizontal:
                        var contentSizeWidth: CGFloat = self.leadingSpacing*2 // 前尾间距
                        contentSizeWidth += CGFloat(numberOfItems-1)*self.actualInteritemSpacing // Interitem间距
                        contentSizeWidth += CGFloat(numberOfItems)*self.actualItemSize.width // 项目大小
                        let contentSize = CGSize(width: contentSizeWidth, height: collectionView.frame.height)
                        return contentSize
                    case .vertical:
                        var contentSizeHeight: CGFloat = self.leadingSpacing*2 // 前尾间距
                        contentSizeHeight += CGFloat(numberOfItems-1)*self.actualInteritemSpacing // Interitem间距
                        contentSizeHeight += CGFloat(numberOfItems)*self.actualItemSize.height // 项目大小
                        let contentSize = CGSize(width: collectionView.frame.width, height: contentSizeHeight)
                        return contentSize
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
              let pagerView = self.pagerView,
              let transformer = pagerView.transformer else {
            return super.layoutAttributesForElements(in: rect)
        }
        
        if transformer.type == .grid {
            var layoutAttributes = [UICollectionViewLayoutAttributes]()
            let numberOfItems = collectionView.numberOfItems(inSection: 0)
            guard numberOfItems > 0 else { return layoutAttributes }
            
            let rows = transformer.gridRows
            let columns = transformer.gridColumns
            let spacing = transformer.gridSpacing
            let itemsPerPage = rows * columns
            
            // 计算当前可见的页面范围
            let pageWidth = collectionView.bounds.width
            let pageHeight = collectionView.bounds.height
            
            // 计算总页数
            let totalPages = Int(ceil(Double(numberOfItems) / Double(itemsPerPage)))
            
            // 计算可见页面范围
            let minPage: Int
            let maxPage: Int
            
            switch pagerView.scrollDirection {
            case .horizontal:
                minPage = max(Int(floor(rect.minX / pageWidth)), 0)
                maxPage = min(Int(ceil(rect.maxX / pageWidth)), totalPages - 1)
            case .vertical:
                minPage = max(Int(floor(rect.minY / pageHeight)), 0)
                maxPage = min(Int(ceil(rect.maxY / pageHeight)), totalPages - 1)
            }
            
            // 确保页面范围有效
            guard minPage <= maxPage else { return layoutAttributes }
            
            // 遍历可见页面范围内的所有item
            for page in minPage...maxPage {
                let startIndex = page * itemsPerPage
                let endIndex = min(startIndex + itemsPerPage, numberOfItems)
                
                // 确保索引范围有效
                guard startIndex < numberOfItems && startIndex < endIndex else { continue }
                
                for index in startIndex..<endIndex {
                    // 计算item在当前页面内的行列位置
                    let localIndex = index - startIndex
                    let row = localIndex / columns
                    let column = localIndex % columns
                    
                    // 计算item的frame
                    let frame: CGRect
                    switch pagerView.scrollDirection {
                    case .horizontal:
                        let x = CGFloat(page) * pageWidth + CGFloat(column) * (self.actualItemSize.width + spacing)
                        let y = CGFloat(row) * (self.actualItemSize.height + spacing)
                        frame = CGRect(x: x, y: y,
                                     width: self.actualItemSize.width,
                                     height: self.actualItemSize.height)
                    case .vertical:
                        let x = CGFloat(column) * (self.actualItemSize.width + spacing)
                        let y = CGFloat(page) * pageHeight + CGFloat(row) * (self.actualItemSize.height + spacing)
                        frame = CGRect(x: x, y: y,
                                     width: self.actualItemSize.width,
                                     height: self.actualItemSize.height)
                    }
                    
                    if frame.intersects(rect) {
                        let indexPath = IndexPath(item: index, section: 0)
                        let attributes = TFYSwiftPagerViewLayoutAttributes(forCellWith: indexPath)
                        attributes.frame = frame
                        
                        // 设置position用于动画
                        attributes.position = CGFloat(page)
                        
                        layoutAttributes.append(attributes)
                    }
                }
            }
            
            return layoutAttributes
        } else {
            // 原有的布局属性计算逻辑
            var layoutAttributes = [UICollectionViewLayoutAttributes]()
            guard self.itemSpacing > 0, !rect.isEmpty else {
                return layoutAttributes
            }
            let rect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))
            guard !rect.isEmpty else {
                return layoutAttributes
            }
            // 计算某些矩形的起始位置和索引
            let numberOfItemsBefore = self.scrollDirection == .horizontal ? max(Int((rect.minX-self.leadingSpacing)/self.itemSpacing),0) : max(Int((rect.minY-self.leadingSpacing)/self.itemSpacing),0)
            let startPosition = self.leadingSpacing + CGFloat(numberOfItemsBefore)*self.itemSpacing
            let startIndex = numberOfItemsBefore
            // 创建布局属性
            var itemIndex = startIndex
            
            var origin = startPosition
            let maxPosition = self.scrollDirection == .horizontal ? min(rect.maxX,self.contentSize.width-self.actualItemSize.width-self.leadingSpacing) : min(rect.maxY,self.contentSize.height-self.actualItemSize.height-self.leadingSpacing)
           
            while origin-maxPosition <= max(CGFloat(100.0) * .ulpOfOne * abs(origin+maxPosition), .leastNonzeroMagnitude) {
                let indexPath = IndexPath(item: itemIndex%self.numberOfItems, section: itemIndex/self.numberOfItems)
                let attributes = self.layoutAttributesForItem(at: indexPath) as! TFYSwiftPagerViewLayoutAttributes
                self.applyTransform(to: attributes, with: transformer)
                layoutAttributes.append(attributes)
                itemIndex += 1
                origin += self.itemSpacing
            }
            return layoutAttributes
        }
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = TFYSwiftPagerViewLayoutAttributes(forCellWith: indexPath)
        attributes.indexPath = indexPath
        let frame = self.frame(for: indexPath)
        let center = CGPoint(x: frame.midX, y: frame.midY)
        attributes.center = center
        attributes.size = self.actualItemSize
        return attributes
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView, let pagerView = self.pagerView else {
            return proposedContentOffset
        }
        var proposedContentOffset = proposedContentOffset
        
        func calculateTargetOffset(by proposedOffset: CGFloat, boundedOffset: CGFloat) -> CGFloat {
            var targetOffset: CGFloat
            if pagerView.decelerationDistance == TFYSwiftPagerView.automaticDistance {
                if abs(velocity.x) >= 0.3 {
                    let vector: CGFloat = velocity.x >= 0 ? 1.0 : -1.0
                    targetOffset = round(proposedOffset/self.itemSpacing+0.35*vector) * self.itemSpacing // 0。15，而不是0。5
                } else {
                    targetOffset = round(proposedOffset/self.itemSpacing) * self.itemSpacing
                }
            } else {
                let extraDistance = max(pagerView.decelerationDistance-1, 0)
                switch velocity.x {
                case 0.3 ... CGFloat.greatestFiniteMagnitude:
                    targetOffset = ceil(collectionView.contentOffset.x/self.itemSpacing+CGFloat(extraDistance)) * self.itemSpacing
                case -CGFloat.greatestFiniteMagnitude ... -0.3:
                    targetOffset = floor(collectionView.contentOffset.x/self.itemSpacing-CGFloat(extraDistance)) * self.itemSpacing
                default:
                    targetOffset = round(proposedOffset/self.itemSpacing) * self.itemSpacing
                }
            }
            targetOffset = max(0, targetOffset)
            targetOffset = min(boundedOffset, targetOffset)
            return targetOffset
        }
        let proposedContentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return proposedContentOffset.x
            }
            let boundedOffset = collectionView.contentSize.width-self.itemSpacing
            return calculateTargetOffset(by: proposedContentOffset.x, boundedOffset: boundedOffset)
        }()
        let proposedContentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return proposedContentOffset.y
            }
            let boundedOffset = collectionView.contentSize.height-self.itemSpacing
            return calculateTargetOffset(by: proposedContentOffset.y, boundedOffset: boundedOffset)
        }()
        proposedContentOffset = CGPoint(x: proposedContentOffsetX, y: proposedContentOffsetY)
        return proposedContentOffset
    }
    
    // MARK: ——内部函数
    
    internal func forceInvalidate() {
        self.needsReprepare = true
        self.invalidateLayout()
    }
    
    internal func contentOffset(for indexPath: IndexPath) -> CGPoint {
        let origin = self.frame(for: indexPath).origin
        guard let collectionView = self.collectionView else {
            return origin
        }
        let contentOffsetX: CGFloat = {
            if self.scrollDirection == .vertical {
                return 0
            }
            let contentOffsetX = origin.x - (collectionView.frame.width*0.5-self.actualItemSize.width*0.5)
            return contentOffsetX
        }()
        let contentOffsetY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return 0
            }
            let contentOffsetY = origin.y - (collectionView.frame.height*0.5-self.actualItemSize.height*0.5)
            return contentOffsetY
        }()
        let contentOffset = CGPoint(x: contentOffsetX, y: contentOffsetY)
        return contentOffset
    }
    
    internal func frame(for indexPath: IndexPath) -> CGRect {
        let numberOfItems = self.numberOfItems*indexPath.section + indexPath.item
        let originX: CGFloat = {
            if self.scrollDirection == .vertical {
                return (self.collectionView!.frame.width-self.actualItemSize.width)*0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems)*self.itemSpacing
        }()
        let originY: CGFloat = {
            if self.scrollDirection == .horizontal {
                return (self.collectionView!.frame.height-self.actualItemSize.height)*0.5
            }
            return self.leadingSpacing + CGFloat(numberOfItems)*self.itemSpacing
        }()
        let origin = CGPoint(x: originX, y: originY)
        let frame = CGRect(origin: origin, size: self.actualItemSize)
        return frame
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
        let newIndexPath = IndexPath(item: currentIndex, section: pagerView.isInfinite ? self.numberOfSections/2 : 0)
        let contentOffset = self.contentOffset(for: newIndexPath)
        let newBounds = CGRect(origin: contentOffset, size: collectionView.frame.size)
        collectionView.bounds = newBounds
    }
    
    fileprivate func applyTransform(to attributes: TFYSwiftPagerViewLayoutAttributes, with transformer: TFYSwiftPagerViewTransformer?) {
        guard let collectionView = self.collectionView else {
            return
        }
        guard let transformer = transformer else {
            return
        }
        switch self.scrollDirection {
        case .horizontal:
            let ruler = collectionView.bounds.midX
            attributes.position = (attributes.center.x-ruler)/self.itemSpacing
        case .vertical:
            let ruler = collectionView.bounds.midY
            attributes.position = (attributes.center.y-ruler)/self.itemSpacing
        }
        attributes.zIndex = Int(self.numberOfItems)-Int(attributes.position)
        transformer.applyTransform(to: attributes)
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
        let itemsPerPage = rows * columns
        
        // 计算item的实际大小，考虑容器大小和间距
        let containerWidth = pagerView.bounds.width
        let containerHeight = pagerView.bounds.height
        
        let itemWidth = (containerWidth - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
        let itemHeight = (containerHeight - (CGFloat(rows - 1) * spacing)) / CGFloat(rows)
        
        self.actualItemSize = CGSize(width: itemWidth, height: itemHeight)
        self.actualInteritemSpacing = spacing
        
        // 计算总页数
        let totalItems = CGFloat(self.numberOfItems)
        let numberOfPages = ceil(totalItems / CGFloat(itemsPerPage))
        
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
        
        // 设置为0以避免自动居中
        self.leadingSpacing = 0
    }
}
