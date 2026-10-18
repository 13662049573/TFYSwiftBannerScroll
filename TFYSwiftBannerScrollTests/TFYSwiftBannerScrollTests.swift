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
            await MainActor.run { window.isHidden = true; pager.removeFromSuperview() }
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

    func testAutoplayAdvancesGridByPage() {
        let f = makePager(count: 12, grid: true)
        f.pager.automaticSlidingInterval = 0.4
        let deadline = Date(timeIntervalSinceNow: 2)
        while f.pager.currentIndex != 6 && Date() < deadline {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
        }
        f.pager.automaticSlidingInterval = 0
        XCTAssertEqual(f.pager.currentIndex, 6)
    }

    func testBackgroundPreventsAutoplayUntilActivation() {
        let f = makePager()
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        f.pager.automaticSlidingInterval = 0.05
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
        XCTAssertEqual(f.pager.currentIndex, 0)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.4))
        f.pager.automaticSlidingInterval = 0
        XCTAssertNotEqual(f.pager.currentIndex, 0)
    }

}
