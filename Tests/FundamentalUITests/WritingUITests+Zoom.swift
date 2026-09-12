import XCTest

extension WritingUITests
{
    func testZoomKeysPreserveSavedWritingAndRestoreAfterRelaunch() async throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self, restoresZoom: true)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        app.typeKey("0", modifierFlags: [.command])
        journey.paste("Zoom Check\nМир e\u{301} 👨‍👩‍👧‍👦")
        try journey.saveAs()
        let saved = try Data(contentsOf: journey.document)
        let normal = try await WritingUIVisibleText.height(of: "Zoom Check",
            in: journey.window.screenshot(), test: self)
        for _ in 0 ..< 4
        {
            app.typeKey("=", modifierFlags: [.command])
        }
        app.typeKey("+", modifierFlags: [.command])
        let enlarged = try await WritingUIVisibleText.height(of: "Zoom Check",
            in: journey.window.screenshot(), test: self)
        XCTAssertGreaterThan(enlarged, normal * 1.3)
        XCTAssertLessThan(enlarged, normal * 1.8)
        XCTAssertEqual(try Data(contentsOf: journey.document), saved)
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
        app.launch()
        app.typeKey("o", modifierFlags: [.command])
        journey.go(to: journey.document)
        app.buttons["OKButton"].click()
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        app.typeKey(.downArrow, modifierFlags: [.command])
        let restored = try await WritingUIVisibleText.height(of: "Zoom Check",
            in: journey.window.screenshot(), test: self)
        XCTAssertEqual(restored, enlarged, accuracy: 2)
        for _ in 0 ..< 5
        {
            app.typeKey("-", modifierFlags: [.command])
        }
        let reduced = try await WritingUIVisibleText.height(of: "Zoom Check",
            in: journey.window.screenshot(), test: self)
        XCTAssertEqual(reduced, normal, accuracy: 2)
        app.typeKey("=", modifierFlags: [.command])
        app.typeKey("0", modifierFlags: [.command])
        let actual = try await WritingUIVisibleText.height(of: "Zoom Check",
            in: journey.window.screenshot(), test: self)
        XCTAssertEqual(actual, normal, accuracy: 2)
        XCTAssertEqual(try Data(contentsOf: journey.document), saved)
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }

    func testZoomAtNarrowWidthInLightAppearance() async throws
    {
        try await exerciseNarrowZoom(.light)
    }

    func testZoomAtNarrowWidthInDarkAppearance() async throws
    {
        try await exerciseNarrowZoom(.dark)
    }

    private func exerciseNarrowZoom(_ appearance: XCUIDevice.Appearance)
        async throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self, appearance: appearance)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        journey.paste(Array(repeating: "A line of daily writing.", count: 80)
            .joined(separator: "\n") + "\nVisible Ending ")
        journey.resize(to: 360)
        app.typeKey("0", modifierFlags: [.command])
        for _ in 0 ..< 10 { app.typeKey("=", modifierFlags: [.command]) }
        let image = try journey.expectAppearance(appearance)
        try await WritingUIVisibleText.expect("Visible Ending",
                                               in: image, test: self)
        journey.step("Narrow writing at maximum zoom")
        {
            journey.inspectAndCancel("Body", group: "Paragraph Style",
                                     using: .toolbarOverflow)
        }
        app.typeKey("0", modifierFlags: [.command])
    }
}
