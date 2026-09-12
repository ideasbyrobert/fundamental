import XCTest

extension WritingUITests
{
    func testCompleteDailyWritingAndNamedRecovery() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
            documentName: "Daily.fun", initialWindowName: "Daily Input")
        let app = fixture.app
        let source = "Daily writing\nA draft\nAnother draft\n" +
            (1 ... 40).map { "Paragraph \($0) for a day's writing." }
            .joined(separator: "\n") + "\nМир e\u{301} 👨‍👩‍👧‍👦"
        let input = fixture.directory.appending(path: "Daily Input.txt")
        try Data(source.utf8).write(to: input)
        let written = source + "\nWritten today"
        try journey.step("Import, write and choose a semantic heading")
        {
            journey.importText(at: input)
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            journey.editor.click()
            app.typeKey(.downArrow, modifierFlags: [.command])
            journey.paste("\nWritten today")
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
            WritingUIFormattingRoute.toolbar.chooseHeading(in: journey)
            try journey.expectText(written)
        }
        let expected = written.replacingOccurrences(of: "draft", with: "final")
        try journey.step("Replace two matches and undo the complete action")
        {
            journey.find("draft", replacing: true)
            journey.expectMatches("1 of 2")
            journey.replaceAll(with: "final")
            try journey.expectText(expected)
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText(written)
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.expectText(expected)
            app.typeKey(.escape, modifierFlags: [])
        }
        try journey.step("Zoom, scroll and cancel Save without losing writing")
        {
            journey.resize(to: 540)
            for _ in 0 ..< 3 { app.typeKey("=", modifierFlags: [.command]) }
            app.typeKey(.downArrow, modifierFlags: [.command])
            app.typeKey("s", modifierFlags: [.command])
            let field = app.textFields["saveAsNameTextField"]
            XCTAssertTrue(field.waitForExistence(timeout: 5))
            app.typeKey(.escape, modifierFlags: [])
            XCTAssertTrue(field.waitForNonExistence(timeout: 5))
            try journey.expectText(expected)
            XCTAssertFalse(FileManager.default.fileExists(
                atPath: journey.document.path
            ))
            try journey.saveAs()
        }
        let saved = try Data(contentsOf: journey.document)
        let record = try WritingUIRecord(at: journey.document)
        XCTAssertEqual(record.blocks.first?.content.kind, "section")
        XCTAssertEqual(record.blocks.first?.content.level, 2)
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
        app.launch()
        try journey.step("Reopen the saved document and export its text")
        {
            app.typeKey("o", modifierFlags: [.command])
            journey.go(to: journey.document)
            app.buttons["OKButton"].click()
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.expectText(expected)
            let exported = journey.exportText(named: "Daily Export.txt")
            XCTAssertEqual(try Data(contentsOf: exported), Data(expected.utf8))
            XCTAssertEqual(try Data(contentsOf: journey.document), saved)
            XCTAssertEqual(try Data(contentsOf: input), Data(source.utf8))
        }
        try journey.recoverNamedWriting(expected: expected, saved: saved)
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
