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
            if cell.exists && cell.isHittable { break }
            app.tables["demo.menu"].swipeUp()
        }
        XCTAssertTrue(cell.waitForExistence(timeout: 3))
        cell.tap()
        XCTAssertTrue(app.otherElements["banner.preview"].waitForExistence(timeout: 3))
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
            let preview = app.otherElements["banner.preview"]
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
        let preview = app.otherElements["banner.preview"]
        preview.swipeUp()
        snapshot("vertical-grid")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        open("events")
        let allow = app.switches["允许选择 shouldSelect"]
        reveal(allow)
        allow.tap()
        app.otherElements["banner.preview"].tap()
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
        let preview = app.otherElements["banner.preview"]
        XCTAssertTrue(preview.waitForExistence(timeout: 3))
        preview.tap() // Wait for UIKit's rotation animation and the app's idle state before capturing.
        XCTAssertGreaterThan(app.frame.width, app.frame.height)
        XCTAssertGreaterThan(preview.frame.width, preview.frame.height)
        XCTAssertGreaterThan(preview.frame.height, 80)
        snapshot("landscape-dark")
        XCUIDevice.shared.orientation = .portrait
    }
}
