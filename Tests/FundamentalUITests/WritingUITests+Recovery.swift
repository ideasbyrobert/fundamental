import XCTest

extension WritingUITests
{
    func testForcedQuitRecoversCommittedWritingAndSelection() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        let tail = "Мир e\u{301} 👨‍👩‍👧‍👦"
        let text = "Checkpoint\n" + tail
        try journey.step("Checkpoint a heading and backward Unicode selection")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            journey.editor.click()
            journey.paste(text)
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
            WritingUIFormattingRoute.toolbar.chooseHeading(in: journey)
            app.typeKey(.downArrow, modifierFlags: [.command])
            app.typeKey(.leftArrow, modifierFlags: [.command, .shift])
            journey.expectSelection(tail)
            app.typeKey("e", modifierFlags: [.option])
            journey.wait("Only committed text and selection reach recovery")
            {
                guard let checkpoint = try? fixture.checkpoints().first,
                      let record = try? checkpoint.content()
                else
                {
                    return false
                }
                let source = record.blocks.map
                {
                    $0.content.runs.map(\.text).joined()
                }.joined(separator: "\n")
                return Array(source.utf16) == Array(text.utf16) &&
                    record.blocks.first?.content.kind == "section" &&
                    checkpoint.anchor.block == checkpoint.focus.block &&
                    checkpoint.anchor.offset == 0 &&
                    checkpoint.focus.offset == tail.utf16.count
            }
            try fixture.forceQuit()
        }
        app.launch()
        let recover = app.windows["Untitled"].sheets.buttons["Recover"]
        XCTAssertTrue(recover.waitForExistence(timeout: 10))
        recover.click()
        let restored = WritingUIJourney(fixture: fixture, test: self,
            documentName: "Recovered.fun",
            initialWindowName: "Untitled — Recovered")
        try restored.step("Recover into a new unsaved document")
        {
            XCTAssertTrue(restored.editor.waitForExistence(timeout: 10))
            try restored.expectText(text)
            restored.expectSelection(tail)
            app.typeKey("z", modifierFlags: [.command])
            try restored.expectText(text)
            XCTAssertEqual(try fixture.checkpoints().count, 1)
        }
        try restored.step("Explicit Save retires the recovered checkpoint")
        {
            try restored.saveAs()
            restored.wait("The saved revision retires its recovery file")
            {
                (try? fixture.checkpoints().isEmpty) == true
            }
            try restored.reopen()
            try restored.expectText(text)
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
