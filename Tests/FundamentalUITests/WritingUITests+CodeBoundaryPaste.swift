import XCTest

extension WritingUITests
{
    func testCodeBoundaryPasteKeepsSourceAndLanguageThroughReopen() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "MixedPaste.fun")
        let code = WritingUICodeFixture(tagged: true, source: "AB")
        try code.write(to: journey.document)
        let app = journey.app
        let pasted = "\r\n\tlet word = \"e\u{301} 😀\"\r\n\r"
        let replaced = "A" + pasted
        try journey.step("Select backward across prose into tagged code")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            try journey.expectText("Before\nAB\nAfter")
            journey.editor.click()
            app.typeKey(.downArrow, modifierFlags: [.command])
            for _ in 0 ..< 7
            {
                app.typeKey(.leftArrow, modifierFlags: [.shift])
            }
            journey.expectSelection("B\nAfter")
        }
        try journey.step("Paste exact lines across selected code and prose")
        {
            journey.paste(pasted)
            try journey.expectText("Before\n" + replaced)
            let record = try journey.save { $0.blocks.count == 2 }
            journey.expectReplacement(record, fixture: code,
                                      codeLeading: true, text: replaced)
        }
        try journey.step("Restore the backward selection with Undo and redo")
        {
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText("Before\nAB\nAfter")
            journey.expectSelection("B\nAfter")
            let record = try journey.save { $0.blocks.count == 3 }
            code.expect(record, code: code.source, after: "After")
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.expectText("Before\n" + replaced)
            let redone = try journey.save { $0.blocks.count == 2 }
            journey.expectReplacement(redone, fixture: code,
                                      codeLeading: true, text: replaced)
        }
        try journey.step("Reopen and type after the final retained source line")
        {
            try journey.reopen()
            journey.resize(to: 360)
            journey.editor.click()
            app.typeKey(.downArrow, modifierFlags: [.command])
            app.typeText("X")
            try journey.expectText("Before\n" + replaced + "X")
            let record = try journey.save
            {
                $0.blocks.last?.content.runs.map(\.text).joined()
                    .utf16.elementsEqual((replaced + "X").utf16) == true
            }
            journey.expectReplacement(record, fixture: code,
                                      codeLeading: true, text: replaced + "X")
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
