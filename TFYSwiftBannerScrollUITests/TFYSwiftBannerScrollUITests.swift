import XCTest

@MainActor
final class TFYSwiftBannerScrollUITests: XCTestCase {
    private let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app.launch()
    }
    private func open(_ id: String) {
        let cell = app.cells["demo.\(id)"]
        for _ in 0..<10 {
            let top = app.navigationBars.firstMatch.frame.maxY
            let bottom = app.frame.maxY - 110 // Keep the tap above the floating search field.
            if cell.exists && cell.isHittable && cell.frame.minY >= top && cell.frame.maxY <= bottom { break }
            app.tables["demo.menu"].swipeUp()
        }
        XCTAssertTrue(cell.waitForExistence(timeout: 3))
        cell.tap()
        let preview = app.descendants(matching: .any)["banner.preview"]
        XCTAssertTrue(preview.waitForExistence(timeout: 3))
    }
    private func reveal(_ element: XCUIElement) {
        let panel = app.scrollViews["demo.parameters"]
        for _ in 0..<12 {
            if element.exists && element.isHittable { return }
            panel.swipeUp()
        }
        XCTFail("Control did not become hittable: \(element)")
    }
    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    func testAllTenScenesKeepPreviewVisibleWhileControlsScroll() {
        snapshot("menu")
        for id in ["basic", "autoplay", "physics", "control", "transformers", "vertical", "grid", "indicator", "cell", "events"] {
            open(id)
            let preview = app.descendants(matching: .any)["banner.preview"]
            let originalY = preview.frame.minY
            app.scrollViews["demo.parameters"].swipeUp()
            XCTAssertEqual(preview.frame.minY, originalY, accuracy: 1)
            XCTAssertGreaterThan(preview.frame.height, 80)
            XCTAssertGreaterThanOrEqual(preview.frame.minX, app.frame.minX)
            XCTAssertLessThanOrEqual(preview.frame.maxX, app.frame.maxX)
            snapshot("scene-\(id)")
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
    func testNibRegistrationAndCustomCellCTA() {
        open("cell")
        app.buttons["Cell 类型"].tap()
        app.buttons["Nib 注册"].tap()
        XCTAssertTrue(app.staticTexts["Nib · 第 1 项"].waitForExistence(timeout: 3))
        app.buttons["Cell 类型"].tap()
        app.buttons["自定义 Class + CTA"].tap()
        let cta = app.buttons["立即查看"].firstMatch
        XCTAssertTrue(cta.waitForExistence(timeout: 3))
        cta.tap()
        XCTAssertTrue(app.staticTexts["demo.status"].label.contains("CTA 已点击"))
        snapshot("custom-cell")
    }
    func testGridDirectionAndDelegateInterception() {
        open("grid")
        let direction = app.buttons["分页方向"]
        reveal(direction)
        direction.tap()
        app.buttons["垂直"].tap()
        let preview = app.descendants(matching: .any)["banner.preview"]
        preview.swipeUp()
        snapshot("vertical-grid")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        open("events")
        let allow = app.switches["允许选择 shouldSelect"]
        reveal(allow)
        allow.tap()
        app.descendants(matching: .any)["banner.preview"].tap()
        let log = app.textViews["delegate.log"]
        reveal(log)
        XCTAssertTrue((log.value as? String ?? "").contains("shouldSelect"))
        snapshot("delegate-events")
    }
    func testLandscapeAndDarkAppearance() {
        app.terminate()
        app.launchEnvironment["DEMO_APPEARANCE"] = "dark"
        app.launch()
        open("transformers")
        XCUIDevice.shared.orientation = .landscapeLeft
        let preview = app.descendants(matching: .any)["banner.preview"]
        XCTAssertTrue(preview.waitForExistence(timeout: 3))
        preview.tap() // Wait for UIKit's rotation animation and the app's idle state before capturing.
        XCTAssertGreaterThan(app.frame.width, app.frame.height)
        XCTAssertGreaterThan(preview.frame.width, preview.frame.height)
        XCTAssertGreaterThan(preview.frame.height, 80)
        snapshot("landscape-dark")
        XCUIDevice.shared.orientation = .portrait
    }
    func testGalleryShowsEveryCardTypeAndOpensMatchingDetail() {
        let entry = app.cells["demo.gallery"]
        XCTAssertTrue(entry.waitForExistence(timeout: 3))
        entry.tap()
        let table = app.tables["card.gallery"]
        XCTAssertTrue(table.waitForExistence(timeout: 3))
        app.navigationBars.buttons["暂停预览"].tap()
        snapshot("gallery-initial")
        let names = ["crossFading", "zoomOut", "depth", "overlap", "linear", "coverFlow", "ferrisWheel", "invertedFerrisWheel", "cubic", "rotate3D", "parallax", "springy", "flip", "cards", "cylinder", "wave", "windmill", "accordion", "carousel", "stack", "grid", "posterStack", "plain", "custom"]
        for name in names {
            let preview = app.cells["gallery.\(name)"]
            for _ in 0..<12 {
                if preview.exists && preview.frame.intersection(app.frame).height > 230 { break }
                let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
                let end = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))
                start.press(forDuration: 0.02, thenDragTo: end)
            }
            XCTAssertTrue(preview.exists, name)
            XCTAssertGreaterThan(preview.frame.intersection(app.frame).height, 230, name)
            if name == "stack" {
                let start = preview.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5))
                let end = preview.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.5))
                start.press(forDuration: 0.1, thenDragTo: end)
                snapshot("stack-after-forward-drag")
                end.press(forDuration: 0.1, thenDragTo: start)
                snapshot("stack-after-reverse-drag")
                XCTAssertTrue(table.exists)
            }
            if name == "posterStack" || name == "crossFading" { snapshot("gallery-\(name)") }
        }
        let custom = app.buttons["details.custom"]
        for _ in 0..<4 {
            if custom.isHittable { break }; table.swipeUp()
        }
        custom.tap()
        XCTAssertTrue(app.staticTexts["style.current"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["style.current"].label.contains("自定义倾斜"))
        app.buttons["上一种卡片"].tap()
        XCTAssertTrue(app.staticTexts["style.current"].label.contains("海报层叠"))
        app.buttons["下一种卡片"].tap()
        XCTAssertTrue(app.staticTexts["style.current"].label.contains("自定义倾斜"))
    }

    func testScreenshotStylePosterDeckAndPlayButton() {
        open("poster")
        let play = app.buttons["播放海报 1"].firstMatch
        XCTAssertTrue(play.waitForExistence(timeout: 3))
        play.tap()
        XCTAssertTrue(app.staticTexts["demo.status"].label.contains("已点击海报 1"))
        snapshot("poster-stack")
        app.descendants(matching: .any)["banner.preview"].swipeLeft()
        XCTAssertTrue(app.buttons.matching(identifier: "poster.play").count > 0)
    }

}
