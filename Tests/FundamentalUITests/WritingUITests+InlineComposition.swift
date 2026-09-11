import XCTest

extension WritingUITests
{
    func testTextShortcutCommitsDeadKeyBeforeChangingTyping() throws
    {
        continueAfterFailure = false
        try WritingUIKeyboard.requireUS(in: self)
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Composed Styles.fun")
        let app = fixture.app
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        try journey.step("Accept a dead key before selecting bold typing")
        {
            app.typeKey("n", modifierFlags: [.option])
            app.typeKey("b", modifierFlags: [.command])
            app.typeText("X")
            try journey.saveAs()
            _ = try journey.saveInline([[("˜", []), ("X", ["strong"])]])
        }
        try journey.step("Undo the character and then its prior composition")
        {
            app.typeKey("z", modifierFlags: [.command])
            _ = try journey.saveInline([[("˜", [])]])
            app.typeKey("z", modifierFlags: [.command])
            _ = try journey.saveInline([[]])
        }
    }
}
