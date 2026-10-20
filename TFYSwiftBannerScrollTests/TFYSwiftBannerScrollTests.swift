//
//  TFYSwiftBannerScrollTests.swift
//  TFYSwiftBannerScrollTests
//

import XCTest
#if SWIFT_PACKAGE
@testable import TFYSwiftBannerScrollKit
#else
@testable import TFYSwiftBannerScroll
#endif

@MainActor
final class TFYSwiftBannerScrollTests: XCTestCase {
    
    private final class StubDataSource: NSObject, TFYSwiftPagerViewDataSource {
        var count = 5
        func numberOfItems(in pagerView: TFYSwiftPagerView) -> Int { count }
        func pagerView(_ pagerView: TFYSwiftPagerView, cellForItemAt index: Int) -> TFYSwiftPagerViewCell {
            pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        }
    }
    
    private final class IndexSpy: NSObject, TFYSwiftPagerViewDelegate {
        var lastIndex: Int?
        var indices: [Int] = []
        var displayedIndices: [Int] = []
        func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int) {
            lastIndex = index
            indices.append(index)
        }
    }
    
    @MainActor
    private struct Fixture {
        let window: UIWindow
        let pager: TFYSwiftPagerView
        let dataSource: StubDataSource
        let collection: UICollectionView
        var layout: TFYSwiftPagerViewLayout { collection.collectionViewLayout as! TFYSwiftPagerViewLayout }
    }

    private func makePager(count: Int = 5, direction: TFYSwiftPagerView.ScrollDirection = .horizontal,
                           infinite: Bool = false, grid: Bool = false) -> Fixture {
        let pager = TFYSwiftPagerView(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        let ds = StubDataSource()
        ds.count = count
        pager.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pager.dataSource = ds
        pager.scrollDirection = direction
        pager.isInfinite = infinite
        if grid { pager.transformer = TFYSwiftPagerViewTransformer(type: .grid) }
        let window = UIWindow(frame: pager.bounds)
        window.addSubview(pager)
        window.makeKeyAndVisible()
        pager.reloadData()
        pager.layoutIfNeeded()
        let collection = pager.subviews.flatMap(\.subviews).compactMap { $0 as? UICollectionView }.first!
        collection.layoutIfNeeded()
        addTeardownBlock {
            await MainActor.run {
                _ = ds
                window.isHidden = true
                pager.removeFromSuperview()
            }
        }
        return Fixture(window: window, pager: pager, dataSource: ds, collection: collection)
    }

    func testNilTransformerStillProducesLayoutAttributes() {
        let pager = TFYSwiftPagerView(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        let ds = StubDataSource()
        pager.dataSource = ds
        pager.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pager.transformer = nil
        pager.layoutIfNeeded()
        pager.reloadData()
        pager.layoutIfNeeded()
        
        // Force layout pass
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        window.addSubview(pager)
        window.layoutIfNeeded()
        
        XCTAssertGreaterThan(pager.numberOfItems, 0)
        XCTAssertNil(pager.transformer)
        // scrollOffset should be safe (no crash / nan) without transformer
        XCTAssertFalse(pager.scrollOffset.isNaN)
    }
    
    func testDidChangeIndexCallback() {
        let pager = TFYSwiftPagerView(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        let ds = StubDataSource()
        let spy = IndexSpy()
        pager.dataSource = ds
        pager.delegate = spy
        pager.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pager.isInfinite = false
        pager.itemSize = CGSize(width: 280, height: 160)
        
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        window.addSubview(pager)
        window.makeKeyAndVisible()
        pager.reloadData()
        pager.layoutIfNeeded()
        
        pager.scrollToItem(at: 2, animated: false)
        pager.layoutIfNeeded()
        
        // Allow scrollViewDidScroll to run
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        
        XCTAssertEqual(pager.currentIndex, 2)
        XCTAssertEqual(spy.lastIndex, 2)
    }
    
    func testHorizontalOnlyTransformersFlag() {
        XCTAssertFalse(PagerViewTransformerType.overlap.supportsVertical)
        XCTAssertFalse(PagerViewTransformerType.coverFlow.supportsVertical)
        XCTAssertTrue(PagerViewTransformerType.crossFading.supportsVertical)
        XCTAssertTrue(PagerViewTransformerType.cubic.supportsVertical)
    }
    
    func testConfigureGridLayoutCachesUntilTransformerReady() {
        let pager = TFYSwiftPagerView(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        let ds = StubDataSource()
        ds.count = 12
        pager.dataSource = ds
        pager.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // Call before transformer assignment — should cache, not crash
        pager.configureGridLayout(rows: 2, columns: 3, spacing: 8)
        pager.transformer = TFYSwiftPagerViewTransformer(type: .grid)
        
        XCTAssertEqual(pager.transformer?.type, .grid)
        XCTAssertEqual(pager.transformer?.gridRows, 2)
        XCTAssertEqual(pager.transformer?.gridColumns, 3)
        XCTAssertEqual(pager.transformer?.proposedInteritemSpacing(), 8)
        pager.scrollDirection = .vertical
        XCTAssertEqual(pager.transformer?.proposedInteritemSpacing(), 8)
        XCTAssertTrue(pager.isPagingEnabled)
    }
    func testDefaultLayoutContainsVisibleCells() {
        let f = makePager()
        let attributes = f.layout.layoutAttributesForElements(in: f.collection.bounds) ?? []
        XCTAssertFalse(attributes.isEmpty)
        XCTAssertEqual(attributes.first?.frame, CGRect(x: 0, y: 0, width: 320, height: 180))
    }

    func testFiniteProgrammaticScrollDoesNotUseNegativeSection() {
        let f = makePager()
        f.pager.scrollToItem(at: 4, animated: false)
        XCTAssertEqual(f.pager.currentIndex, 4)
        XCTAssertNotNil(f.pager.cellForItem(at: 4))
        f.pager.selectItem(at: 0, animated: false)
        f.collection.layoutIfNeeded()
        XCTAssertEqual(f.collection.indexPathsForSelectedItems, [IndexPath(item: 0, section: 0)])
        XCTAssertEqual(f.pager.currentIndex, 0)
    }

    func testInvalidIndicesAreSafe() {
        let f = makePager()
        for index in [-1, 5, Int.max] {
            f.pager.scrollToItem(at: index, animated: false)
            f.pager.selectItem(at: index, animated: false)
            f.pager.deselectItem(at: index, animated: false)
            XCTAssertNil(f.pager.cellForItem(at: index))
        }
        XCTAssertEqual(f.pager.currentIndex, 0)
    }

    func testReloadShrinksAndClearsCurrentIndex() {
        let f = makePager()
        let spy = IndexSpy()
        f.pager.delegate = spy
        f.pager.scrollToItem(at: 4, animated: false)
        f.dataSource.count = 2
        f.pager.reloadData()
        f.collection.layoutIfNeeded()
        XCTAssertEqual(f.pager.currentIndex, 1)
        f.dataSource.count = 0
        f.pager.reloadData()
        f.collection.layoutIfNeeded()
        XCTAssertEqual(f.pager.currentIndex, 0)
        XCTAssertEqual(f.pager.numberOfSections, 0)
        XCTAssertEqual(f.pager.scrollOffset, 0)
        XCTAssertEqual(spy.lastIndex, 0)
        XCTAssertTrue(f.collection.visibleCells.isEmpty)
    }

    func testRemovingDataSourceClearsSnapshot() {
        let f = makePager()
        f.pager.dataSource = nil
        f.collection.layoutIfNeeded()
        XCTAssertEqual(f.pager.numberOfItems, 0)
        XCTAssertEqual(f.pager.numberOfSections, 0)
    }

    func testLargeInfiniteDataSourceHasAtLeastOneSection() {
        let f = makePager(count: 40_000, infinite: true)
        XCTAssertEqual(f.pager.numberOfSections, 1)
        XCTAssertFalse(f.collection.visibleCells.isEmpty)
    }

    func testNegativeDataSourceCountIsEmpty() {
        let f = makePager(count: -1)
        XCTAssertEqual(f.pager.numberOfItems, 0)
        XCTAssertEqual(f.pager.numberOfSections, 0)
    }

    func testBounceDoesNotPublishNegativeIndex() {
        let f = makePager()
        f.collection.contentOffset.x = -220
        f.pager.scrollViewDidScroll(f.collection)
        XCTAssertEqual(f.pager.currentIndex, 0)
        XCTAssertGreaterThanOrEqual(f.pager.scrollOffset, 0)
    }

    func testSnapIsBoundedToVisibleScrollRange() {
        for direction in [TFYSwiftPagerView.ScrollDirection.horizontal, .vertical] {
            let f = makePager(direction: direction)
            f.pager.itemSize = CGSize(width: 200, height: 100)
            f.pager.interitemSpacing = 10
            f.pager.decelerationDistance = TFYSwiftPagerView.automaticDistance
            f.collection.layoutIfNeeded()
            let target = f.layout.targetContentOffset(forProposedContentOffset: CGPoint(x: 10_000, y: 10_000),
                                                      withScrollingVelocity: CGPoint(x: 2, y: 2))
            if direction == .horizontal {
                XCTAssertEqual(target.x, f.collection.contentSize.width - f.collection.bounds.width)
            } else {
                XCTAssertEqual(target.y, f.collection.contentSize.height - f.collection.bounds.height)
            }
        }
    }

    func testSingleItemSnapNeverProducesNegativeOffset() {
        let f = makePager(count: 1)
        f.pager.itemSize = CGSize(width: 100, height: 100)
        f.collection.layoutIfNeeded()
        let target = f.layout.targetContentOffset(forProposedContentOffset: CGPoint(x: 300, y: 0), withScrollingVelocity: .zero)
        XCTAssertEqual(target.x, 0)
    }

    func testGridIndividualAttributesMatchVisibleAttributes() {
        for direction in [TFYSwiftPagerView.ScrollDirection.horizontal, .vertical] {
            let f = makePager(count: 14, direction: direction, grid: true)
            let rect = CGRect(origin: .zero, size: f.collection.contentSize)
            let visible = f.layout.layoutAttributesForElements(in: rect) ?? []
            XCTAssertEqual(visible.count, 14)
            for attribute in visible {
                XCTAssertEqual(attribute.frame, f.layout.layoutAttributesForItem(at: attribute.indexPath)?.frame)
            }
            f.pager.scrollToItem(at: 7, animated: false)
            XCTAssertEqual(f.pager.currentIndex, 6)
            XCTAssertEqual(direction == .horizontal ? f.collection.contentOffset.x : f.collection.contentOffset.y,
                           direction == .horizontal ? 320 : 180)
            XCTAssertNotNil(f.pager.cellForItem(at: 7))
            f.pager.scrollToItem(at: 13, animated: false)
            XCTAssertEqual(f.pager.currentIndex, 12)
        }
    }

    func testGridCanBeAssignedWithoutConfigureCall() {
        let f = makePager(count: 12, infinite: true, grid: true)
        XCTAssertFalse(f.pager.isInfinite)
        XCTAssertTrue(f.pager.isPagingEnabled)
        XCTAssertEqual(f.pager.numberOfSections, 1)
        XCTAssertEqual(f.layout.pageCount, 2)
    }

    func testGridDirectConfigurationInvalidatesAndClampsDimensions() {
        let f = makePager(count: 12, grid: true)
        f.pager.transformer?.gridRows = 0
        f.pager.transformer?.gridColumns = -3
        f.pager.transformer?.gridSpacing = -1
        f.collection.layoutIfNeeded()
        XCTAssertEqual(f.layout.itemsPerPage, 1)
        XCTAssertEqual(f.layout.pageCount, 12)
        XCTAssertEqual(f.layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))?.size,
                       CGSize(width: 320, height: 180))
    }

    func testGridExcessiveSpacingProducesNonnegativeSizes() {
        let f = makePager(count: 12, grid: true)
        f.pager.configureGridLayout(rows: 2, columns: 3, spacing: 1_000)
        f.collection.layoutIfNeeded()
        let size = f.layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))!.size
        XCTAssertGreaterThanOrEqual(size.width, 0)
        XCTAssertGreaterThanOrEqual(size.height, 0)
    }

    func testAutomaticSizeRespectsAllContentInsets() {
        let f = makePager()
        f.pager.contentInsets = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        f.collection.layoutIfNeeded()
        XCTAssertEqual(f.layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))?.frame,
                       CGRect(x: 20, y: 10, width: 260, height: 140))
        f.pager.scrollToItem(at: 4, animated: false)
        XCTAssertEqual(f.pager.currentIndex, 4)
    }

    func testResizePreservesCurrentItem() {
        let f = makePager(infinite: true)
        f.pager.scrollToItem(at: 3, animated: false)
        f.pager.frame.size = CGSize(width: 600, height: 300)
        f.pager.layoutIfNeeded()
        f.collection.layoutIfNeeded()
        XCTAssertEqual(f.pager.currentIndex, 3)
        XCTAssertEqual(f.pager.scrollOffset, 3, accuracy: 0.001)
    }

    func testInfiniteBoundaryRecentersWithoutChangingIndex() {
        let f = makePager(infinite: true)
        let offset = f.layout.contentOffset(for: IndexPath(item: 4, section: f.pager.numberOfSections - 1))
        f.collection.contentOffset = offset
        f.pager.scrollViewDidEndDecelerating(f.collection)
        XCTAssertEqual(f.pager.currentIndex, 4)
        XCTAssertLessThan(f.collection.contentOffset.x, offset.x)
        XCTAssertEqual(f.pager.scrollOffset, 4, accuracy: 0.001)
    }

    func testPageControlCentersOddAndEvenCountsSynchronously() {
        for count in [1, 3, 4] {
            let control = TFYSwiftPageControl(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            control.numberOfPages = count
            control.layoutIfNeeded()
            let layers = control.subviews[0].layer.sublayers ?? []
            XCTAssertEqual(layers.count, count)
            XCTAssertEqual((layers.first!.frame.minX + layers.last!.frame.maxX) / 2, 100, accuracy: 0.01)
        }
    }

    func testPageControlClampsCountsAndSelection() {
        let control = TFYSwiftPageControl(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        control.numberOfPages = -2
        control.layoutIfNeeded()
        XCTAssertEqual(control.numberOfPages, 0)
        control.numberOfPages = 3
        control.currentPage = 99
        control.layoutIfNeeded()
        XCTAssertEqual(control.currentPage, 2)
        control.currentPage = -5
        XCTAssertEqual(control.currentPage, 0)
        control.numberOfPages = 0
        control.layoutIfNeeded()
        XCTAssertTrue((control.subviews[0].layer.sublayers ?? []).isEmpty)
    }

    func testPageControlReusesExistingLayersWhenCountChanges() {
        let control = TFYSwiftPageControl(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        control.numberOfPages = 3
        control.layoutIfNeeded()
        let first = control.subviews[0].layer.sublayers!.first!
        control.numberOfPages = 4
        control.layoutIfNeeded()
        XCTAssertTrue(first === control.subviews[0].layer.sublayers!.first!)
    }

    func testCellImageCreationDoesNotCoverPreviouslyCreatedLabel() {
        let cell = TFYSwiftPagerViewCell(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        let label = cell.textLabel!
        let imageView = cell.imageView!
        XCTAssertTrue(cell.contentView.subviews.first === imageView)
        XCTAssertTrue(cell.contentView.subviews.last === label.superview)
        XCTAssertTrue(label.adjustsFontForContentSizeCategory)
    }

    func testZoomOutAtUnitScaleHasFiniteAlpha() {
        let f = makePager()
        let transformer = TFYSwiftPagerViewTransformer(type: .zoomOut)
        f.pager.transformer = transformer
        transformer.minimumScale = 1
        let attributes = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
        attributes.size = f.pager.bounds.size
        attributes.position = 0.5
        transformer.applyTransform(to: attributes)
        XCTAssertEqual(attributes.alpha, 1)
        XCTAssertTrue(attributes.alpha.isFinite)
    }

    func testReplacingTransformerDetachesPreviousOwner() {
        let f = makePager()
        let old = TFYSwiftPagerViewTransformer(type: .coverFlow)
        f.pager.transformer = old
        f.pager.transformer = nil
        XCTAssertNil(old.pagerView)
    }

    func testAutoplayDoesNotCreateTimerOutsideWindow() {
        let pager = TFYSwiftPagerView()
        pager.automaticSlidingInterval = 0.05
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        XCTAssertEqual(pager.currentIndex, 0)
    }

    func testAutoplayAdvancesGridByPage() throws {
        #if SWIFT_PACKAGE
        throw XCTSkip("Headless Package tests cannot drive UIScrollView animations; covered by the Demo application host.")
        #else
        let f = makePager(count: 12, grid: true)
        f.pager.automaticSlidingInterval = 0.4
        let deadline = Date(timeIntervalSinceNow: 2)
        while f.pager.currentIndex != 6 && Date() < deadline {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        f.pager.automaticSlidingInterval = 0
        XCTAssertEqual(f.pager.currentIndex, 6)
        #endif
    }

    func testBackgroundPreventsAutoplayUntilActivation() throws {
        #if SWIFT_PACKAGE
        throw XCTSkip("Foreground/background transitions require an application host; covered by the Demo tests.")
        #else
        let f = makePager()
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        f.pager.automaticSlidingInterval = 0.05
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
        XCTAssertEqual(f.pager.currentIndex, 0)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.4))
        f.pager.automaticSlidingInterval = 0
        XCTAssertNotEqual(f.pager.currentIndex, 0)
        #endif
    }

    func testPendingCellRequestAfterWeakDataSourceDeallocatesIsSafe() {
        let pager = TFYSwiftPagerView(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        var dataSource: StubDataSource? = StubDataSource()
        pager.register(TFYSwiftPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pager.dataSource = dataSource
        let window = UIWindow(frame: pager.bounds)
        window.addSubview(pager)
        pager.layoutIfNeeded()
        dataSource = nil
        XCTAssertNil(pager.dataSource)
        pager.scrollToItem(at: 4, animated: false)
        pager.layoutIfNeeded()
        pager.reloadData()
        XCTAssertEqual(pager.numberOfItems, 0)
        pager.removeFromSuperview()
    }

    func testStackDragKeepsForegroundOpaqueAndHidesDistantRepeatedCards() {
        for direction in [TFYSwiftPagerView.ScrollDirection.horizontal, .vertical] {
            for infinite in [false, true] {
                let f = makePager(count: 7, direction: direction, infinite: infinite)
                f.pager.itemSize = CGSize(width: 230, height: 150)
                f.pager.transformer = TFYSwiftPagerViewTransformer(type: .stack)
                f.collection.layoutIfNeeded()
                f.pager.scrollToItem(at: 3, animated: false)
                let origin = f.collection.contentOffset
                for step in -10...10 {
                    let fraction = CGFloat(step) / 10
                    var offset = origin
                    if direction == .horizontal { offset.x += fraction * f.layout.itemSpacing }
                    else { offset.y += fraction * f.layout.itemSpacing }
                    f.collection.contentOffset = offset
                    f.collection.layoutIfNeeded()
                    let attributes = (f.layout.layoutAttributesForElements(in: f.collection.bounds) ?? [])
                        .compactMap { $0 as? TFYSwiftPagerViewLayoutAttributes }
                    let visible = attributes.filter { $0.alpha > 0 }
                    XCTAssertFalse(visible.isEmpty)
                    XCTAssertLessThanOrEqual(visible.count, 4, "Repeated cards must disappear during dragging")
                    for item in attributes {
                        if abs(item.position) <= 1 { XCTAssertEqual(item.alpha, 1) }
                        if abs(item.position) >= 2 { XCTAssertEqual(item.alpha, 0) }
                        XCTAssertGreaterThanOrEqual(item.transform.a, 0.8)
                        for farther in visible where abs(farther.position) > abs(item.position) + 0.01 {
                            XCTAssertGreaterThan(item.zIndex, farther.zIndex)
                        }
                    }
                    let front = visible.max { $0.zIndex < $1.zIndex }!
                    XCTAssertEqual(front.alpha, 1)
                    XCTAssertLessThanOrEqual(abs(front.position), 0.501)
                }
            }
        }
    }

    func testStackFractionalLayersAndTransformsRemainContinuous() {
        let f = makePager()
        let transformer = TFYSwiftPagerViewTransformer(type: .stack)
        f.pager.transformer = transformer
        func value(_ position: CGFloat) -> TFYSwiftPagerViewLayoutAttributes {
            let item = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            item.size = CGSize(width: 230, height: 150)
            item.position = position
            transformer.applyTransform(to: item)
            return item
        }
        XCTAssertGreaterThan(value(0.2).zIndex, value(-0.8).zIndex)
        XCTAssertGreaterThan(value(-0.2).zIndex, value(0.8).zIndex)
        XCTAssertNotEqual(value(-0.5).zIndex, value(0.5).zIndex)
        for boundary: CGFloat in [-2, -1, 0, 1, 2] {
            let before = value(boundary - 0.0001), after = value(boundary + 0.0001)
            XCTAssertEqual(before.alpha, after.alpha, accuracy: 0.001)
            XCTAssertEqual(before.transform.a, after.transform.a, accuracy: 0.001)
            XCTAssertEqual(before.transform.tx, after.transform.tx, accuracy: 0.01)
            XCTAssertEqual(before.transform.ty, after.transform.ty, accuracy: 0.01)
        }
    }

    func testPagerConveniencePropertiesReadActualTransformerValues() {
        let f = makePager()
        let transformer = TFYSwiftPagerViewTransformer(type: .posterStack)
        f.pager.transformer = transformer
        XCTAssertEqual(f.pager.rotationAngle, .pi / 24, accuracy: 0.0001)
        transformer.rotationAngle = .pi / 10
        transformer.parallaxFactor = 1.2
        XCTAssertEqual(f.pager.rotationAngle, .pi / 10, accuracy: 0.0001)
        XCTAssertEqual(f.pager.parallaxFactor, 1.2)
        f.pager.rotationAngle = .nan
        f.pager.parallaxFactor = .infinity
        XCTAssertEqual(f.pager.rotationAngle, transformer.rotationAngle)
        XCTAssertTrue(f.pager.rotationAngle.isFinite)
        XCTAssertEqual(f.pager.parallaxFactor, 0.5)
        f.pager.transformer = nil
        XCTAssertTrue(f.pager.rotationAngle.isFinite)
    }

    func testAllTransformerParametersInvalidateLayoutAndRejectNonfiniteValues() {
        let f = makePager()
        let transformer = TFYSwiftPagerViewTransformer(type: .cards)
        f.pager.transformer = transformer
        f.pager.scrollToItem(at: 3, animated: false)
        let parameters: [ReferenceWritableKeyPath<TFYSwiftPagerViewTransformer, CGFloat>] = [
            \.minimumScale, \.minimumAlpha, \.perspective, \.springDamping, \.parallaxFactor,
            \.rotationAngle, \.waveHeight, \.cylinderRadius, \.flipAngle, \.cardSpacing,
            \.windmillSpeed, \.accordionFactor, \.carouselRadius, \.stackOffset, \.gridSpacing
        ]
        for key in parameters {
            for value in [CGFloat.nan, .infinity, -.infinity, 0.5] {
                f.collection.layoutIfNeeded()
                XCTAssertFalse(f.layout.needsReprepare)
                transformer[keyPath: key] = value
                XCTAssertTrue(transformer[keyPath: key].isFinite)
                XCTAssertTrue(f.layout.needsReprepare, "Parameter changes must refresh without reloadData")
                f.collection.layoutIfNeeded()
                XCTAssertEqual(f.pager.currentIndex, 3)
            }
        }
        transformer.springDamping = 3
        transformer.accordionFactor = -1
        transformer.cardSpacing = -100
        transformer.cylinderRadius = -100
        transformer.carouselRadius = -100
        transformer.stackOffset = -100
        XCTAssertEqual(transformer.springDamping, 1)
        XCTAssertEqual(transformer.accordionFactor, 0)
        XCTAssertEqual(transformer.cardSpacing, 0)
        XCTAssertEqual(transformer.cylinderRadius, 0)
        XCTAssertEqual(transformer.carouselRadius, 0)
        XCTAssertEqual(transformer.stackOffset, 0)
    }

    func testAllTransformersStayBoundedAndRepeatableDuringFractionalDrags() {
        let f = makePager()
        let positions: [CGFloat] = [-12, -5, -4.5, -3, -2.5, -2, -1.5, -1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1, 1.5, 2, 2.5, 3, 4.5, 5, 12]
        for type in PagerViewTransformerType.allCases {
            let transformer = TFYSwiftPagerViewTransformer(type: type)
            f.pager.transformer = transformer
            for direction in [TFYSwiftPagerView.ScrollDirection.horizontal, .vertical] where direction == .horizontal || type.supportsVertical {
                f.pager.scrollDirection = direction
                for position in positions {
                    let item = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
                    item.size = CGSize(width: 230, height: 150)
                    item.center = CGPoint(x: 160, y: 90)
                    item.position = position
                    transformer.applyTransform(to: item)
                    let t = item.transform3D
                    let values = [t.m11, t.m12, t.m13, t.m14, t.m21, t.m22, t.m23, t.m24, t.m31, t.m32, t.m33, t.m34, t.m41, t.m42, t.m43, t.m44]
                    XCTAssertTrue(values.allSatisfy(\.isFinite), "\(type) at \(position)")
                    XCTAssertTrue((0...1).contains(item.alpha), "\(type) at \(position)")
                    XCTAssertEqual(item.center, CGPoint(x: 160, y: 90), "Transforming must not shift the layout's source center")
                    let first = item.copy() as! TFYSwiftPagerViewLayoutAttributes
                    transformer.applyTransform(to: item)
                    XCTAssertTrue(first.isEqual(item), "Repeated transform drift: \(type) at \(position)")
                    if CATransform3DIsAffine(t) && item.alpha > 0 {
                        let affine = CATransform3DGetAffineTransform(t)
                        XCTAssertGreaterThanOrEqual(affine.a * affine.d - affine.b * affine.c, -0.0001)
                    }
                }
                for position in [CGFloat.nan, .infinity, -.infinity] {
                    let item = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
                    item.size = CGSize(width: 230, height: 150)
                    item.position = position
                    transformer.applyTransform(to: item)
                    XCTAssertEqual(item.alpha, 0)
                    XCTAssertTrue(CATransform3DIsIdentity(item.transform3D))
                }
            }
        }
    }

    func testMotionUsesSingleAxisDisplacementAndHidesFlipBackfaces() {
        let f = makePager()
        for direction in [TFYSwiftPagerView.ScrollDirection.horizontal, .vertical] {
            f.pager.scrollDirection = direction
            for type in [PagerViewTransformerType.springy, .windmill, .accordion, .wave] {
                let transformer = TFYSwiftPagerViewTransformer(type: type)
                f.pager.transformer = transformer
                let item = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
                item.size = CGSize(width: 230, height: 150)
                item.position = 0.5
                transformer.applyTransform(to: item)
                if direction == .horizontal { XCTAssertEqual(item.transform.tx, 0, accuracy: 0.0001) }
                else { XCTAssertEqual(item.transform.ty, 0, accuracy: 0.0001) }
                if type == .wave {
                    let cross = direction == .horizontal ? item.transform.ty : item.transform.tx
                    XCTAssertGreaterThan(abs(cross), 0)
                }
                if type == .springy { XCTAssertLessThanOrEqual(item.transform.a, 1.12) }
            }
            let flip = TFYSwiftPagerViewTransformer(type: .flip)
            f.pager.transformer = flip
            for position: CGFloat in [-1, -0.75, 0.75, 1] {
                let item = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
                item.size = CGSize(width: 230, height: 150)
                item.position = position
                flip.applyTransform(to: item)
                XCTAssertEqual(item.alpha, 0)
            }
            let carousel = TFYSwiftPagerViewTransformer(type: .carousel)
            f.pager.transformer = carousel
            let center = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            center.size = CGSize(width: 230, height: 150)
            carousel.applyTransform(to: center)
            XCTAssertEqual(center.transform3D.m43, 0)
            XCTAssertEqual(center.transform3D.m44, 1)
        }
    }

    func testLayoutIncludesEveryVisibleTransformedNeighbourAndAsymmetricLastItem() {
        for direction in [TFYSwiftPagerView.ScrollDirection.horizontal, .vertical] {
            let f = makePager(count: 20, direction: direction)
            f.pager.itemSize = CGSize(width: 230, height: 140)
            f.pager.contentInsets = UIEdgeInsets(top: 4, left: 5, bottom: 60, right: 75)
            for type in [PagerViewTransformerType?.none] + PagerViewTransformerType.allCases.filter { $0 != .grid && (direction == .horizontal || $0.supportsVertical) }.map(Optional.some) {
                f.pager.transformer = type.map(TFYSwiftPagerViewTransformer.init(type:))
                f.collection.layoutIfNeeded()
                for item in [0, 8, 19] {
                    f.pager.scrollToItem(at: item, animated: false)
                    var offset = f.collection.contentOffset
                    if item == 8 {
                        if direction == .horizontal { offset.x += f.layout.itemSpacing * 0.35 }
                        else { offset.y += f.layout.itemSpacing * 0.35 }
                        f.collection.contentOffset = offset
                    }
                    f.collection.layoutIfNeeded()
                    let rect = f.collection.bounds
                    let returned = Set((f.layout.layoutAttributesForElements(in: rect) ?? []).map(\.indexPath))
                    for index in 0..<20 {
                        let path = IndexPath(item: index, section: 0)
                        let expected = f.layout.layoutAttributesForItem(at: path)!
                        if expected.alpha > 0 && expected.frame.intersects(rect) {
                            XCTAssertTrue(returned.contains(path), "Missing visible \(index) for \(String(describing: type))")
                        }
                    }
                    XCTAssertLessThan(returned.count, 20)
                }
            }
        }
    }

    func testNewStylesPreserveRawValuesAndUseDistinctCardGeometry() {
        XCTAssertEqual(PagerViewTransformerType.posterStack.rawValue, 21)
        XCTAssertEqual(PagerViewTransformerType.fan.rawValue, 22)
        XCTAssertEqual(PagerViewTransformerType.throwCard.rawValue, 23)
        XCTAssertEqual(PagerViewTransformerType.bookFlip.rawValue, 24)
        let f = makePager()
        f.pager.itemSize = CGSize(width: 230, height: 150)
        for direction in [TFYSwiftPagerView.ScrollDirection.horizontal, .vertical] {
            f.pager.scrollDirection = direction
            func value(_ type: PagerViewTransformerType, _ position: CGFloat) -> TFYSwiftPagerViewLayoutAttributes {
                f.pager.transformer = TFYSwiftPagerViewTransformer(type: type)
                let item = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
                item.size = f.pager.itemSize
                let stride = (direction == .horizontal ? item.size.width : item.size.height) + f.pager.transformer!.proposedInteritemSpacing()
                item.center = CGPoint(x: 160 + (direction == .horizontal ? position * stride : 0),
                                      y: 90 + (direction == .vertical ? position * stride : 0))
                item.position = position
                f.pager.transformer!.applyTransform(to: item)
                return item
            }
            let fanCenter = value(.fan, 0), fanLeft = value(.fan, -1), fanRight = value(.fan, 1)
            XCTAssertTrue(CATransform3DIsIdentity(fanCenter.transform3D))
            XCTAssertEqual(fanLeft.transform.b, -fanRight.transform.b, accuracy: 0.0001)
            XCTAssertGreaterThan(fanCenter.zIndex, fanRight.zIndex)
            let incoming = value(.throwCard, 0.75), outgoing = value(.throwCard, -0.25)
            let axis = direction == .horizontal ? incoming.center.x + incoming.transform.tx : incoming.center.y + incoming.transform.ty
            XCTAssertEqual(axis, direction == .horizontal ? 160 : 90, accuracy: 0.0001)
            XCTAssertGreaterThan(outgoing.zIndex, incoming.zIndex)
            XCTAssertEqual(outgoing.alpha, 1)
            XCTAssertNotEqual(outgoing.transform.b, 0)
            XCTAssertEqual(value(.throwCard, -1).alpha, 0)
            XCTAssertEqual(value(.bookFlip, -1).alpha, 0)
        }
    }

    func testBookFlipKeepsItsHingeFixedThroughoutTheDrag() {
        let f = makePager()
        f.pager.itemSize = CGSize(width: 230, height: 150)
        for direction in [TFYSwiftPagerView.ScrollDirection.horizontal, .vertical] {
            f.pager.scrollDirection = direction
            let transformer = TFYSwiftPagerViewTransformer(type: .bookFlip)
            f.pager.transformer = transformer
            for position: CGFloat in [-0.9, -0.5, -0.1, 0, 0.5, 1] {
                let item = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
                item.size = f.pager.itemSize
                let stride = direction == .horizontal ? item.size.width : item.size.height
                item.center = CGPoint(x: 160 + (direction == .horizontal ? position * stride : 0),
                                      y: 90 + (direction == .vertical ? position * stride : 0))
                item.position = position
                transformer.applyTransform(to: item)
                let hinge = CGPoint(x: direction == .horizontal ? -115 : 0, y: direction == .vertical ? -75 : 0)
                let t = item.transform3D
                let w = hinge.x * t.m14 + hinge.y * t.m24 + t.m44
                let x = item.center.x + (hinge.x * t.m11 + hinge.y * t.m21 + t.m41) / w
                let y = item.center.y + (hinge.x * t.m12 + hinge.y * t.m22 + t.m42) / w
                XCTAssertEqual(x, 160 + hinge.x, accuracy: 0.001)
                XCTAssertEqual(y, 90 + hinge.y, accuracy: 0.001)
            }
        }
    }

    func testEveryBuiltInTransformerProducesFiniteLayoutAttributes() {
        let f = makePager()
        XCTAssertEqual(PagerViewTransformerType.allCases.count, 25)
        for type in PagerViewTransformerType.allCases {
            f.pager.transformer = TFYSwiftPagerViewTransformer(type: type)
            f.collection.layoutIfNeeded()
            let attributes = f.layout.layoutAttributesForElements(in: f.collection.bounds) ?? []
            XCTAssertFalse(attributes.isEmpty, type.displayName)
            for item in attributes {
                XCTAssertTrue(item.alpha.isFinite, type.displayName)
                XCTAssertTrue(item.center.x.isFinite && item.center.y.isFinite, type.displayName)
                XCTAssertTrue(item.transform3D.m11.isFinite && item.transform3D.m44.isFinite, type.displayName)
            }
        }
    }

    func testPosterStackKeepsCenterProminentAndTiltsOnlyNeighbours() {
        let f = makePager()
        let transformer = TFYSwiftPagerViewTransformer(type: .posterStack)
        f.pager.transformer = transformer
        func attributes(_ position: CGFloat) -> TFYSwiftPagerViewLayoutAttributes {
            let value = TFYSwiftPagerViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
            value.size = CGSize(width: 280, height: 370)
            value.position = position
            transformer.applyTransform(to: value)
            return value
        }
        let center = attributes(0)
        let left = attributes(-1)
        let right = attributes(1)
        XCTAssertEqual(center.transform, .identity)
        XCTAssertEqual(center.alpha, 1)
        XCTAssertLessThan(left.transform.b, 0)
        XCTAssertGreaterThan(right.transform.b, 0)
        XCTAssertEqual(left.alpha, 0.55, accuracy: 0.0001)
        XCTAssertEqual(right.alpha, left.alpha)
        XCTAssertGreaterThan(center.zIndex, right.zIndex)
        XCTAssertEqual(attributes(2).alpha, 0)
        XCTAssertFalse(PagerViewTransformerType.posterStack.supportsVertical)
        XCTAssertEqual(PagerViewTransformerType.grid.rawValue, 20)
        XCTAssertEqual(PagerViewTransformerType.posterStack.rawValue, 21)
        f.pager.itemSize = CGSize(width: 280, height: 370)
        XCTAssertEqual(transformer.proposedInteritemSpacing(), -191.6, accuracy: 0.001)
    }

    #if !SWIFT_PACKAGE
    func testMenuHeaderSurvivesZeroHeightMeasurementAndRefitsAcrossWidths() {
        let scene = DemoMenuViewController()
        scene.loadViewIfNeeded()
        scene.view.frame = .zero
        scene.view.setNeedsLayout()
        scene.view.layoutIfNeeded()
        XCTAssertNil(scene.tableView.tableHeaderView, "Do not measure or attach a header with zero-width bounds")
        let parent = UIViewController()
        parent.addChild(scene)
        parent.view.addSubview(scene.view)
        scene.didMove(toParent: parent)
        parent.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        defer {
            scene.willMove(toParent: nil)
            scene.view.removeFromSuperview()
            scene.removeFromParent()
        }
        scene.view.frame = parent.view.bounds
        scene.view.setNeedsLayout()
        scene.view.layoutIfNeeded()
        let header = scene.tableView.tableHeaderView!
        XCTAssertGreaterThan(header.frame.height, 32, "The header must be sized before attachment")
        let zeroHeight = header.heightAnchor.constraint(equalToConstant: 0)
        zeroHeight.identifier = "Test.TableHeader.TransientZeroHeight"
        zeroHeight.isActive = true
        header.layoutIfNeeded()
        XCTAssertFalse(header.hasAmbiguousLayout)
        zeroHeight.isActive = false

        for category in [UIContentSizeCategory.large, .accessibilityExtraExtraExtraLarge] {
            parent.setOverrideTraitCollection(UITraitCollection(preferredContentSizeCategory: category), forChild: scene)
            for width: CGFloat in [320, 844, 1024, 390] {
                scene.view.frame = CGRect(x: 0, y: 0, width: width, height: 844)
                scene.view.setNeedsLayout()
                scene.view.layoutIfNeeded()
                header.layoutIfNeeded()
                XCTAssertEqual(header.frame.width, width, accuracy: 1)
                let stack = header.subviews.compactMap { $0 as? UIStackView }.first!
                XCTAssertGreaterThanOrEqual(stack.frame.minY, 16)
                XCTAssertLessThanOrEqual(stack.frame.maxY, header.bounds.height - 15)
                for case let label as UILabel in stack.arrangedSubviews {
                    XCTAssertFalse(label.hasAmbiguousLayout)
                    let required = label.sizeThatFits(CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude))
                    XCTAssertGreaterThanOrEqual(label.bounds.height + 1, required.height, "Header text must remain visible")
                }
            }
        }
    }

    func testDemoExposesEveryTransformerParameterAndCustomExtension() {
        let scene = TransformersDemoViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = scene
        window.makeKeyAndVisible()
        scene.loadViewIfNeeded()
        var exposed = Set<String>()
        func visit(_ view: UIView) {
            if view is UISlider, let identifier = view.accessibilityIdentifier { exposed.insert(identifier) }
            view.subviews.forEach(visit)
        }
        for index in 0...PagerViewTransformerType.allCases.count + 1 {
            scene.selectStyle(at: index)
            scene.view.layoutIfNeeded()
            visit(scene.controlsContainer)
        }
        let required: Set<String> = ["minimumScale", "minimumAlpha", "perspective", "springDamping", "parallaxFactor", "rotationAngle", "waveHeight", "cylinderRadius", "flipAngle", "cardSpacing", "windmillSpeed", "accordionFactor", "carouselRadius", "stackOffset", "gridRows", "gridColumns", "gridSpacing"]
        XCTAssertTrue(required.isSubset(of: exposed), "Missing controls: \(required.subtracting(exposed))")
        XCTAssertTrue(scene.pagerView.transformer is DemoTiltTransformer)
        window.isHidden = true
        window.rootViewController = nil
    }

    func testGalleryCreatesAnIndependentLivePreviewForEveryCardType() {
        let styles = DemoCardGalleryViewController.styles
        XCTAssertEqual(styles.compactMap(\.type), PagerViewTransformerType.allCases)
        XCTAssertEqual(styles.count, PagerViewTransformerType.allCases.count + 2)
        XCTAssertEqual(Set(styles.map(\.identifier)).count, styles.count)
        let scene = DemoCardGalleryViewController()
        scene.loadViewIfNeeded()
        XCTAssertEqual(scene.tableView(scene.tableView, numberOfRowsInSection: 0), styles.count)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        defer { window.isHidden = true }
        for style in styles {
            let cell = DemoCardGalleryCell(style: .default, reuseIdentifier: "test")
            cell.configure(style: style)
            cell.frame = CGRect(x: 0, y: 0, width: 360, height: 460)
            window.addSubview(cell)
            cell.layoutIfNeeded()
            cell.pager.layoutIfNeeded()
            XCTAssertEqual(cell.pager.transformer?.type, style.isCustom ? .zoomOut : style.type, style.name)
            if let type = style.type {
                let detail = TransformersDemoViewController(styleIndex: style.selectionIndex)
                detail.loadViewIfNeeded()
                XCTAssertEqual(detail.pagerView.transformer?.type, type, style.name)
            }
            XCTAssertEqual(cell.pager.accessibilityIdentifier, "preview.\(style.name)")
            XCTAssertNotNil(cell.pager.cellForItem(at: 0), style.name)
            cell.setAutoplay(true)
            cell.prepareForReuse()
            XCTAssertEqual(cell.pager.automaticSlidingInterval, 0)
            cell.removeFromSuperview()
        }
    }

    func testPosterDemoHasRoundedCellAndIndependentPlayCallback() {
        let scene = PosterStackDemoViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = scene
        window.makeKeyAndVisible()
        scene.loadViewIfNeeded()
        scene.view.layoutIfNeeded()
        scene.pagerView.layoutIfNeeded()
        let cell = scene.pagerView.cellForItem(at: 0) as! DemoPosterCell
        XCTAssertEqual(cell.contentView.layer.cornerRadius, 24)
        let play = cell.contentView.subviews.compactMap { $0 as? UIButton }.first!
        XCTAssertEqual(play.accessibilityIdentifier, "poster.play")
        var clicked = false
        cell.onPlay = { clicked = true }
        play.sendActions(for: .touchUpInside)
        XCTAssertTrue(clicked)
        cell.prepareForReuse()
        XCTAssertNil(cell.onPlay)
        window.isHidden = true
        window.rootViewController = nil
    }
    #endif

}
