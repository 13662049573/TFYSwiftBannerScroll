//
//  TFYSwiftPagerView.swift
//  TFYSwiftBannerScroll
//
//  Created by 田风有 on 2021/5/19.
//

import UIKit

@objc
public protocol TFYSwiftPagerViewDataSource: NSObjectProtocol {
    
    /// 询问数据源对象页导航视图中的项数。
    @objc(numberOfItemsInPagerView:)
    func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int
    
    /// 询问数据源对象是否与页导航视图中的指定项相对应的单元格。
    @objc(pagerView:cellForItemAtIndex:)
    func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell
    
}

@objc
public protocol TFYSwiftPagerViewDelegate: NSObjectProtocol {
    
    /// 询问委托在跟踪期间是否应高亮显示该项。
    @objc(pagerView:shouldHighlightItemAtIndex:)
    optional func pagerView(_ pagerView: TFYSwiftPagerView, shouldHighlightItemAt index: Int) -> Bool
    
    /// 告诉委托指定索引处的项已高亮显示。
    @objc(pagerView:didHighlightItemAtIndex:)
    optional func pagerView(_ pagerView: TFYSwiftPagerView, didHighlightItemAt index: Int)
    
    /// 询问委托是否应选择指定的项。
    @objc(pagerView:shouldSelectItemAtIndex:)
    optional func pagerView(_ pagerView: TFYSwiftPagerView, shouldSelectItemAt index: Int) -> Bool
    
    /// 告诉委托指定索引处的项已选定。
    @objc(pagerView:didSelectItemAtIndex:)
    optional func pagerView(_ pagerView: TFYSwiftPagerView, didSelectItemAt index: Int)
    
    /// 告诉委托指定的单元格将显示在页导航视图中。
    @objc(pagerView:willDisplayCell:forItemAtIndex:)
    optional func pagerView(_ pagerView: TFYSwiftPagerView, willDisplay cell: TFYSwiftPagerViewCell, forItemAt index: Int)
    
    /// 告诉委托指定的单元格已从页导航视图中删除。
    @objc(pagerView:didEndDisplayingCell:forItemAtIndex:)
    optional func pagerView(_ pagerView: TFYSwiftPagerView, didEndDisplaying cell: TFYSwiftPagerViewCell, forItemAt index: Int)
    
    /// 告诉委托页导航视图何时开始滚动内容。
    @objc(pagerViewWillBeginDragging:)
    optional func pagerViewWillBeginDragging(_ pagerView: TFYSwiftPagerView)
    
    /// 告诉委托当用户完成滚动内容。
    @objc(pagerViewWillEndDragging:targetIndex:)
    optional func pagerViewWillEndDragging(_ pagerView: TFYSwiftPagerView, targetIndex: Int)
    
    /// 当用户在接收器内滚动内容视图时，告诉委托。
    @objc(pagerViewDidScroll:)
    optional func pagerViewDidScroll(_ pagerView: TFYSwiftPagerView)
    
    /// 告诉委托当页导航视图中的滚动动画结束时。
    @objc(pagerViewDidEndScrollAnimation:)
    optional func pagerViewDidEndScrollAnimation(_ pagerView: TFYSwiftPagerView)
    
    /// 告诉委托，页导航视图已经结束，滚动速度减慢。
    @objc(pagerViewDidEndDecelerating:)
    optional func pagerViewDidEndDecelerating(_ pagerView: TFYSwiftPagerView)
    
}


open class TFYSwiftPagerView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {

    // MARK: - 公共属性

    /// 作为页导航视图的数据源的对象。
    open weak var dataSource: TFYSwiftPagerViewDataSource?
    
    /// 作为页导航视图的委托的对象。
    open weak var delegate: TFYSwiftPagerViewDelegate?
    
    /// 页导航视图的滚动方向。默认的是水平的。
    @objc
    open var scrollDirection: TFYSwiftPagerView.ScrollDirection = .horizontal {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// 自动滑动的时间间隔。0表示禁用自动滑动。默认值为0。
    open var automaticSlidingInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.automaticSlidingInterval > 0 {
                self.startTimer()
            }
        }
    }
    
    /// 页导航视图中项之间使用的间距。默认值为0。
    open var interitemSpacing: CGFloat = 0 {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// 寻呼机视图的项大小。当此属性的值为TFYSwiftPagerView时。automaticSize，条目填充页导航视图的整个可见区域。默认是TFYSwiftPagerView.automaticSize。
    open var itemSize: CGSize = automaticSize {
        didSet {
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    /// 布尔值指示页导航视图是否有无限项。默认是 false。
    open var isInfinite: Bool = false {
        didSet {
            self.collectionViewLayout.needsReprepare = true
            self.collectionView.reloadData()
        }
    }

    /// 一个无符号整数值，确定寻呼机视图的减速距离，它指示减速期间传递的项目数。当此属性的值为TFYSwiftPagerView时。automaticDistance，实际的"距离"是根据页导航视图的滚动速度自动计算的。默认值为1。
    open var decelerationDistance: UInt = 1
    
    /// 一个布尔值，决定是否启用滚动。
    open var isScrollEnabled: Bool {
        set { self.collectionView.isScrollEnabled = newValue }
        get { return self.collectionView.isScrollEnabled }
    }
    
    /// 一个布尔值，控制页导航视图是否跳过内容的边缘再跳回来。
    open var bounces: Bool {
        set { self.collectionView.bounces = newValue }
        get { return self.collectionView.bounces }
    }
    
    /// 一个布尔值，用于确定当水平滚动到达内容视图的末尾时是否总是发生弹跳。
    open var alwaysBounceHorizontal: Bool {
        set { self.collectionView.alwaysBounceHorizontal = newValue }
        get { return self.collectionView.alwaysBounceHorizontal }
    }
    
    /// 一个布尔值，用于确定垂直滚动到达内容视图的末尾时是否总是发生跳跃。
    open var alwaysBounceVertical: Bool {
        set { self.collectionView.alwaysBounceVertical = newValue }
        get { return self.collectionView.alwaysBounceVertical }
    }
    
    /// 一个布尔值，控制在只有一个项时是否删除无限循环。默认是假的。
    open var removesInfiniteLoopForSingleItem: Bool = false {
        didSet {
            self.reloadData()
        }
    }
    
    /// 寻呼机视图的背景视图。
    open var backgroundView: UIView? {
        didSet {
            if let backgroundView = self.backgroundView {
                if backgroundView.superview != nil {
                    backgroundView.removeFromSuperview()
                }
                self.insertSubview(backgroundView, at: 0)
                self.setNeedsLayout()
            }
        }
    }
    
    /// 页导航视图的转换器。
    @objc
    open var transformer: TFYSwiftPagerViewTransformer? {
        didSet {
            self.transformer?.pagerView = self
            self.collectionViewLayout.forceInvalidate()
        }
    }
    
    @objc open var parallaxFactor: CGFloat = 0.5 {
        didSet {
            self.transformer?.parallaxFactor = parallaxFactor
            self.reloadData()
        }
    }

    @objc open var rotationAngle: CGFloat = .pi/2 {
        didSet {
            self.transformer?.rotationAngle = rotationAngle
            self.reloadData()
        }
    }
    
    // MARK: - 公共readonly-properties
    
    /// 返回用户是否已触摸内容以启动滚动。
    @objc
    open var isTracking: Bool {
        return self.collectionView.isTracking
    }
    
    /// 内容视图的原点从pagerView视图的原点偏移的x位置的百分比。
    @objc
    open var scrollOffset: CGFloat {
        let contentOffset = max(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y)
        let scrollOffset = Double(contentOffset/self.collectionViewLayout.itemSpacing)
        return fmod(CGFloat(scrollOffset), CGFloat(self.numberOfItems))
    }
    
    /// 平移手势的底层手势识别器。
    @objc
    open var panGestureRecognizer: UIPanGestureRecognizer {
        return self.collectionView.panGestureRecognizer
    }
    
    @objc open fileprivate(set) dynamic var currentIndex: Int = 0
    
    // MARK: - 私有财产
    
    internal weak var collectionViewLayout: TFYSwiftPagerViewLayout!
    internal weak var collectionView: TFYSwiftPagerCollectionView!
    internal weak var contentView: UIView!
    internal var timer: Timer?
    internal var numberOfItems: Int = 0
    internal var numberOfSections: Int = 0
    
    fileprivate var dequeingSection = 0
    fileprivate var centermostIndexPath: IndexPath {
        guard self.numberOfItems > 0, self.collectionView.contentSize != .zero else {
            return IndexPath(item: 0, section: 0)
        }
        let sortedIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted { (l, r) -> Bool in
            let leftFrame = self.collectionViewLayout.frame(for: l)
            let rightFrame = self.collectionViewLayout.frame(for: r)
            var leftCenter: CGFloat,rightCenter: CGFloat,ruler: CGFloat
            switch self.scrollDirection {
            case .horizontal:
                leftCenter = leftFrame.midX
                rightCenter = rightFrame.midX
                ruler = self.collectionView.bounds.midX
            case .vertical:
                leftCenter = leftFrame.midY
                rightCenter = rightFrame.midY
                ruler = self.collectionView.bounds.midY
            }
            return abs(ruler-leftCenter) < abs(ruler-rightCenter)
        }
        let indexPath = sortedIndexPaths.first
        if let indexPath = indexPath {
            return indexPath
        }
        return IndexPath(item: 0, section: 0)
    }
    fileprivate var isPossiblyRotating: Bool {
        guard let animationKeys = self.contentView.layer.animationKeys() else {
            return false
        }
        let rotationAnimationKeys = ["position", "bounds.origin", "bounds.size"]
        return animationKeys.contains(where: { rotationAnimationKeys.contains($0) })
    }
    fileprivate var possibleTargetingIndexPath: IndexPath?
    
    // MARK: - 重载函数
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundView?.frame = self.bounds
        self.contentView.frame = self.bounds
        self.collectionView.frame = self.contentView.bounds
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.startTimer()
        } else {
            self.cancelTimer()
        }
    }
    
    #if TARGET_INTERFACE_BUILDER
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.masksToBounds = true
        self.contentView.frame = self.bounds
        let label = UILabel(frame: self.contentView.bounds)
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.text = "TFYSwiftPagerView"
        self.contentView.addSubview(label)
    }
    
    #endif

    deinit {
        self.collectionView.dataSource = nil
        self.collectionView.delegate = nil
    }

    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else {
            return 1
        }
        self.numberOfItems = dataSource.numberOfItems(in: self)
        guard self.numberOfItems > 0 else {
            return 0;
        }
        self.numberOfSections = self.isInfinite && (self.numberOfItems > 1 || !self.removesInfiniteLoopForSingleItem) ? Int(Int16.max)/self.numberOfItems : 1
        return self.numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        self.dequeingSection = indexPath.section
        let cell = self.dataSource!.pagerView(self, cellForItemAt: index)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let function = self.delegate?.pagerView(_:shouldHighlightItemAt:) else {
            return true
        }
        let index = indexPath.item % self.numberOfItems
        return function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.pagerView(_:didHighlightItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let function = self.delegate?.pagerView(_:shouldSelectItemAt:) else {
            return true
        }
        let index = indexPath.item % self.numberOfItems
        return function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.pagerView(_:didSelectItemAt:) else {
            return
        }
        self.possibleTargetingIndexPath = indexPath
        defer {
            self.possibleTargetingIndexPath = nil
        }
        let index = indexPath.item % self.numberOfItems
        function(self,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.pagerView(_:willDisplay:forItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self,cell as! TFYSwiftPagerViewCell,index)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let function = self.delegate?.pagerView(_:didEndDisplaying:forItemAt:) else {
            return
        }
        let index = indexPath.item % self.numberOfItems
        function(self,cell as! TFYSwiftPagerViewCell,index)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isPossiblyRotating && self.numberOfItems > 0 {
            // 以防有人用KVO
            let currentIndex = lround(Double(self.scrollOffset)) % self.numberOfItems
            if (currentIndex != self.currentIndex) {
                self.currentIndex = currentIndex
            }
        }
        guard let function = self.delegate?.pagerViewDidScroll else {
            return
        }
        function(self)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let function = self.delegate?.pagerViewWillBeginDragging(_:) {
            function(self)
        }
        if self.automaticSlidingInterval > 0 {
            self.cancelTimer()
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let function = self.delegate?.pagerViewWillEndDragging(_:targetIndex:) {
            let contentOffset = self.scrollDirection == .horizontal ? targetContentOffset.pointee.x : targetContentOffset.pointee.y
            let targetItem = lround(Double(contentOffset/self.collectionViewLayout.itemSpacing))
            function(self, targetItem % self.numberOfItems)
        }
        if self.automaticSlidingInterval > 0 {
            self.startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let function = self.delegate?.pagerViewDidEndDecelerating {
            function(self)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let function = self.delegate?.pagerViewDidEndScrollAnimation {
            function(self)
        }
    }
    
    // MARK: - 公共函数
    
    /// 注册一个用于创建新的页导航视图单元格的类。
    ///
    /// - Parameters:
    ///   - cellClass: 要在页导航视图中使用的单元格的类。
    ///   - identifier: 与指定类关联的重用标识符。此参数不能为空，也不能为空字符串。
    @objc(registerClass:forCellWithReuseIdentifier:)
    open func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    /// 注册一个nib文件，用于创建新的页导航视图单元格。
    ///
    /// - Parameters:
    ///   - nib: 包含单元格对象的nib对象。nib文件必须只包含一个顶级对象，并且该对象的类型必须是FSPagerViewCell。
    ///   - identifier: 与指定nib文件关联的重用标识符。此参数不能为空，也不能为空字符串。
    @objc(registerNib:forCellWithReuseIdentifier:)
    open func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    /// 返回根据其标识符定位的可重用单元格对象
    ///
    /// - Parameters:
    ///   - identifier: 指定单元格的重用标识符。此参数不能为空。
    ///   - index: 指定单元格位置的索引。
    /// - Returns: 有效的FSPagerViewCell对象。
    @objc(dequeueReusableCellWithReuseIdentifier:atIndex:)
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> TFYSwiftPagerViewCell {
        let indexPath = IndexPath(item: index, section: self.dequeingSection)
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard cell.isKind(of: TFYSwiftPagerViewCell.self) else {
            fatalError("Cell class must be subclass of TFYSwiftPagerViewCell")
        }
        return cell as! TFYSwiftPagerViewCell
    }
    
    /// 重新加载集合视图的所有数据。
    @objc(reloadData)
    open func reloadData() {
        self.collectionViewLayout.needsReprepare = true;
        self.collectionView.reloadData()
    }
    
    /// 选择指定索引处的项目，并可选择将其滚动到视图中。
    ///
    /// - Parameters:
    ///   - index: 要选择的项的索引路径。
    ///   - animated: 指定true以使选择中的更改具有动画效果，指定false以使更改不具有动画效果。
    @objc(selectItemAtIndex:animated:)
    open func selectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        let scrollPosition: UICollectionView.ScrollPosition = self.scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }
    
    /// 取消选择指定索引处的项。
    ///
    /// - Parameters:
    ///   - index: 要取消选择的项的索引。
    ///   - animated: 指定true以使选择中的更改具有动画效果，指定false以使更改不具有动画效果。
    @objc(deselectItemAtIndex:animated:)
    open func deselectItem(at index: Int, animated: Bool) {
        let indexPath = self.nearbyIndexPath(for: index)
        self.collectionView.deselectItem(at: indexPath, animated: animated)
    }
    
    /// 滚动页导航视图内容，直到指定项可见为止。
    ///
    /// - Parameters:
    ///   - index: 要滚动到视图中的项的索引。
    ///   - animated: 指定true为动画滚动行为，指定false为立即调整页导航视图的可见内容。
    @objc(scrollToItemAtIndex:animated:)
    open func scrollToItem(at index: Int, animated: Bool) {
        guard index < self.numberOfItems else {
            fatalError("index \(index) is out of range [0...\(self.numberOfItems-1)]")
        }
        let indexPath = { () -> IndexPath in
            if let indexPath = self.possibleTargetingIndexPath, indexPath.item == index {
                defer {
                    self.possibleTargetingIndexPath = nil
                }
                return indexPath
            }
            return self.numberOfSections > 1 ? self.nearbyIndexPath(for: index) : IndexPath(item: index, section: 0)
        }()
        let contentOffset = self.collectionViewLayout.contentOffset(for: indexPath)
        self.collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    /// 返回指定单元格的索引。
    ///
    /// - Parameter cell: 需要其索引的单元格对象。
    /// - Returns: 如果指定的单元格不在页导航视图中，则为单元格或NSNotFound的索引。
    @objc(indexForCell:)
    open func index(for cell: TFYSwiftPagerViewCell) -> Int {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return NSNotFound
        }
        return indexPath.item
    }
    
    /// 返回指定索引处的可见单元格。
    ///
    /// - Parameter index: 指定单元格位置的索引。
    /// - Returns: 对应位置的单元格对象，如果单元格不可见或索引超出范围，则为nil。
    @objc(cellForItemAtIndex:)
    open func cellForItem(at index: Int) -> TFYSwiftPagerViewCell? {
        let indexPath = self.nearbyIndexPath(for: index)
        return self.collectionView.cellForItem(at: indexPath) as? TFYSwiftPagerViewCell
    }
    
    // MARK: - 私有函数
    
    fileprivate func commonInit() {
        
        // 内容视图
        let contentView = UIView(frame:CGRect.zero)
        contentView.backgroundColor = UIColor.clear
        self.addSubview(contentView)
        self.contentView = contentView
        
        // UICollectionView
        let collectionViewLayout = TFYSwiftPagerViewLayout()
        let collectionView = TFYSwiftPagerCollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clear
        self.contentView.addSubview(collectionView)
        self.collectionView = collectionView
        self.collectionViewLayout = collectionViewLayout
        
    }
    
    fileprivate func startTimer() {
        guard self.automaticSlidingInterval > 0 && self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.automaticSlidingInterval), target: self, selector: #selector(self.flipNext(sender:)), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    @objc
    fileprivate func flipNext(sender: Timer?) {
        guard let _ = self.superview, let _ = self.window, self.numberOfItems > 0, !self.isTracking else {
            return
        }
        let contentOffset: CGPoint = {
            let indexPath = self.centermostIndexPath
            let section = self.numberOfSections > 1 ? (indexPath.section+(indexPath.item+1)/self.numberOfItems) : 0
            let item = (indexPath.item+1) % self.numberOfItems
            return self.collectionViewLayout.contentOffset(for: IndexPath(item: item, section: section))
        }()
        self.collectionView.setContentOffset(contentOffset, animated: true)
    }
    
    fileprivate func cancelTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer!.invalidate()
        self.timer = nil
    }
    
    fileprivate func nearbyIndexPath(for index: Int) -> IndexPath {
        // 有更好的算法吗?
        let currentIndex = self.currentIndex
        let currentSection = self.centermostIndexPath.section
        if abs(currentIndex-index) <= self.numberOfItems/2 {
            return IndexPath(item: index, section: currentSection)
        } else if (index-currentIndex >= 0) {
            return IndexPath(item: index, section: currentSection-1)
        } else {
            return IndexPath(item: index, section: currentSection+1)
        }
    }

    @objc
    open func configureGridLayout(rows: Int, columns: Int, spacing: CGFloat) {
        guard let transformer = self.transformer, transformer.type == .grid else {
            return
        }
        
        // 更新网格参数
        transformer.gridRows = rows
        transformer.gridColumns = columns
        transformer.gridSpacing = spacing
        
        // 调整collection view的布局
        self.collectionViewLayout.needsReprepare = true
        
        // 禁用无限滚动
        self.isInfinite = false
        
        // 更新布局
        self.collectionViewLayout.invalidateLayout()
        self.reloadData()
        
        // 确保第一个item可见
        self.scrollToItem(at: 0, animated: false)
    }

}

extension TFYSwiftPagerView {
    
    /// 指示页导航视图滚动方向的常量。
    @objc
    public enum ScrollDirection: Int {
        /// 页导航视图水平滚动内容
        case horizontal
        /// 页导航视图垂直滚动内容
        case vertical
    }
    
    /// 请求TFYSwiftPagerView对给定的距离使用默认值。
    public static let automaticDistance: UInt = 0
    
    /// 请求TFYSwiftPagerView对给定的大小使用默认值。
    public static let automaticSize: CGSize = .zero
    
}
