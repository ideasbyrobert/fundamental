import XCTest

extension WritingUITests
{
    func testPlainCodePreservesSourceThroughDailyEditing() throws
    {
        try exerciseCode(tagged: false)
    }

    func testTaggedCodePreservesSourceThroughDailyEditing() throws
    {
        try exerciseCode(tagged: true)
    }

    func exerciseCode(tagged: Bool, scoped: Bool = false) throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Code.fun")
        let code = WritingUICodeFixture(tagged: tagged, scoped: scoped)
        try code.write(to: journey.document)
        let app = fixture.app
        try journey.step("Open existing code with exact source lines")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            try journey.expectText("Before\n" + code.source + "\nAfter")
            code.expect(try WritingUIRecord(at: journey.document),
                        code: code.source, after: "After")
        }
        try journey.step("Paste and press Return inside the code block")
        {
            journey.editor.click()
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.downArrow, modifierFlags: [])
            app.typeKey(.leftArrow, modifierFlags: [.command])
            let block = journey.window.popUpButtons["FundamentalBlockStyle"]
            XCTAssertTrue(block.isEnabled)
            XCTAssertEqual(block.value as? String, "Code")
            XCTAssertTrue(journey.window.menuButtons["FundamentalListStyle"]
                .isEnabled)
            journey.paste(code.prefix)
            app.typeKey(.return, modifierFlags: [])
            try journey.expectText("Before\n" + code.prefix + "\r\n" +
                code.source + "\nAfter")
        }
        let edited = code.prefix + "\r\n" + code.source
        try journey.step("Undo and redo the two source edits")
        {
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText("Before\n" + code.prefix + code.source +
                "\nAfter")
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText("Before\n" + code.source + "\nAfter")
            app.typeKey("z", modifierFlags: [.command, .shift])
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.expectText("Before\n" + edited + "\nAfter")
        }
        try journey.step("Replace across code blocks, undo and edit prose")
        {
            try journey.replaceWholeDocumentThenUndo(
                "Before\n" + edited + "\nAfter", leadingID: code.blockIDs[0]
            )
            app.typeKey(.downArrow, modifierFlags: [.command])
            XCTAssertTrue(journey.window.popUpButtons["FundamentalBlockStyle"]
                .isEnabled)
            app.typeText(" edited")
            try journey.expectText("Before\n" + edited + "\nAfter edited")
        }
        try journey.step("Save and independently inspect the code meaning")
        {
            let record = try journey.save
            {
                code.matches($0, code: edited, after: "After edited")
            }
            code.expect(record, code: edited, after: "After edited")
            XCTAssertGreaterThan(record.revision, 8)
        }
        try journey.step("Reopen exact code and surrounding prose")
        {
            try journey.reopen()
            try journey.expectText("Before\n" + edited + "\nAfter edited")
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
