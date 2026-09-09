import XCTest

extension WritingUITests
{
    func testCodeBoundaryDeletionPreservesHardLinesThroughReopen() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "MixedDeletion.fun")
        let code = WritingUICodeFixture(tagged: true,
            source: "\tlet value = \"e\u{301} 😀\"\r\nreturn value\r")
        try code.write(to: journey.document)
        let app = journey.app
        let original = "Before\n" + code.source + "\r\nAfter"
        let merged = "Before" + code.source
        try journey.step("Open mixed prose and exact tagged source")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            try journey.expectText(original)
            journey.editor.click()
        }
        try journey.step("Backspace across the prose and code boundary")
        {
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.downArrow, modifierFlags: [])
            app.typeKey(.leftArrow, modifierFlags: [.command])
            app.typeKey(.delete, modifierFlags: [])
            try journey.expectText(merged + "\r\nAfter")
            let record = try journey.save { $0.blocks.count == 2 }
            journey.expectReplacement(record, fixture: code,
                                      codeLeading: false, text: merged)
        }
        try journey.step("Undo the merge and recover the exact code language")
        {
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText(original)
            let record = try journey.save { $0.blocks.count == 3 }
            code.expect(record, code: code.source, after: "After")
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.expectText(merged + "\r\nAfter")
            let redone = try journey.save { $0.blocks.count == 2 }
            journey.expectReplacement(redone, fixture: code,
                                      codeLeading: false, text: merged)
        }
        try journey.step("Reopen hard prose lines at a narrow writing width")
        {
            try journey.reopen()
            journey.resize(to: 360)
            try journey.expectText(merged + "\r\nAfter")
            journey.editor.click()
            app.typeKey("a", modifierFlags: [.command])
            journey.expectSelection(merged + "\r\nAfter")
            app.typeKey(.downArrow, modifierFlags: [.command])
            app.typeText(" edited")
            let record = try journey.save
            {
                $0.blocks.last?.content.runs.map(\.text).joined() ==
                    "After edited"
            }
            XCTAssertEqual(record.blocks[0].content.runs.flatMap
                { Array($0.text.utf16) }, Array(merged.utf16))
            try journey.expectText(merged + "\r\nAfter edited")
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
