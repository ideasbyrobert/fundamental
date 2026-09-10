import XCTest

extension WritingUITests
{
    func testTextShortcutsRetainTypingAcrossPasteAndReturn() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Typing Styles.fun")
        let app = fixture.app
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        try journey.step("Type and paste overlapping text styles")
        {
            app.typeKey("b", modifierFlags: [.command])
            app.typeText("A")
            app.typeKey("i", modifierFlags: [.command])
            journey.paste("e\u{301}😀")
            app.typeKey(.return, modifierFlags: [])
            app.typeText("Next")
            app.typeKey("b", modifierFlags: [.command])
            app.typeText("I")
            app.typeKey("i", modifierFlags: [.command])
            app.typeKey("u", modifierFlags: [.command])
            journey.paste(" under")
            app.typeKey("u", modifierFlags: [.command])
            app.typeText(" plain")
            try journey.saveAs()
        }
        let expected = [
            [("A", ["strong"]), ("e\u{301}😀", ["strong", "emphasis"])],
            [("Next", ["strong", "emphasis"]), ("I", ["emphasis"]),
             (" under", ["underline"]), (" plain", [])]
        ]
        _ = try journey.saveInline(expected)
        try journey.step("Reopen and continue with an explicit text choice")
        {
            try journey.reopen()
            app.typeKey(.downArrow, modifierFlags: [.command])
            app.typeKey("b", modifierFlags: [.command])
            app.typeText("B")
            _ = try journey.saveInline([
                expected[0], expected[1] + [("B", ["strong"])]
            ])
            app.typeKey("z", modifierFlags: [.command])
            _ = try journey.saveInline(expected)
            app.typeKey("z", modifierFlags: [.command, .shift])
            _ = try journey.saveInline([
                expected[0], expected[1] + [("B", ["strong"])]
            ])
        }
    }
}
