import XCTest

extension WritingUITests
{
    func testDeadKeyCompositionSurvivesFormattingAndReopening() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Composition.fun")
        let app = fixture.app
        let prefix = "Compose 😀 e\u{301}: "
        let completed = prefix + "ã"
        try WritingUIKeyboard.requireUS(in: self)
        try journey.step("Observe the provisional dead key")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            journey.editor.click()
            journey.paste(prefix)
            app.typeKey("n", modifierFlags: [.option])
            try journey.expectText(prefix + "\u{2dc}")
        }
        try journey.step("Complete and save the composed letter")
        {
            app.typeKey("a", modifierFlags: [])
            try journey.expectText(completed)
            try journey.saveAs()
        }
        let original = try journey.saveComposition(completed, numbered: false)
        try journey.step("Observe a second provisional dead key")
        {
            app.typeKey("n", modifierFlags: [.option])
            try journey.expectText(completed + "\u{2dc}")
        }
        try journey.step("Escape cancels only the provisional mark")
        {
            app.typeKey(.escape, modifierFlags: [])
            try journey.expectText(completed)
            let record = try journey.saveComposition(completed, numbered: false)
            XCTAssertEqual(record.revision, original.revision)
        }
        try journey.step("Observe a dead key before opening List choices")
        {
            app.typeKey("n", modifierFlags: [.option])
            try journey.expectText(completed + "\u{2dc}")
        }
        try journey.step("Apply numbering without accepting the pending mark")
        {
            WritingUIFormattingRoute.toolbar.chooseList("Numbered", in: journey)
            try journey.expectText(completed)
            let record = try journey.saveComposition(completed, numbered: true)
            journey.expectIdentity(record, from: original)
        }
        try journey.step("Undo numbering and then the completed composition")
        {
            app.typeKey("z", modifierFlags: [.command])
            _ = try journey.saveComposition(completed, numbered: false)
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText(prefix)
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.expectText(completed)
            _ = try journey.saveComposition(completed, numbered: false)
        }
        try journey.step("Reopen the exact composed spelling")
        {
            try journey.reopen()
            try journey.expectText(completed)
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
