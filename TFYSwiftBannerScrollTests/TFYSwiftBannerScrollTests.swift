//
//  TFYSwiftBannerScrollTests.swift
//  TFYSwiftBannerScrollTests
//

import XCTest
@testable import TFYSwiftBannerScroll

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
        func pagerView(_ pagerView: TFYSwiftPagerView, didChangeIndex index: Int) {
            lastIndex = index
        }
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
}
