import XCTest

extension WritingUITests
{
    func testImportWriteFormatSaveReopenAndExportText() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
            documentName: "Imported.fun", initialWindowName: "Input")
        let app = fixture.app
        let input = fixture.directory.appending(path: "Input.txt")
        let source = "# Literal heading\nOne\n\nМир e\u{301} 👨‍👩‍👧‍👦"
        let bytes = Data([0xEF, 0xBB, 0xBF]) + Data(source.utf8)
        try bytes.write(to: input)
        try journey.step("Import UTF-8 into a new unsaved writing window")
        {
            journey.importText(at: input)
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.expectText(source)
            XCTAssertTrue(app.windows["Untitled"].exists)
            XCTAssertEqual(try Data(contentsOf: input), bytes)
        }
        let expected = source + "\nAdded writing"
        try journey.step("Write and choose semantics after import")
        {
            journey.editor.click()
            app.typeKey(.downArrow, modifierFlags: [.command])
            journey.paste("\nAdded writing")
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
            WritingUIFormattingRoute.toolbar.chooseHeading(in: journey)
            try journey.expectText(expected)
            let export = journey.exportText(named: "Before Save.txt")
            XCTAssertEqual(try Data(contentsOf: export), Data(expected.utf8))
            try journey.saveAs()
            let saved = try WritingUIRecord(at: journey.document)
            XCTAssertEqual(saved.blocks.first?.content.kind, "section")
        }
        try journey.step("Reopen the semantic file and export canonical text")
        {
            try journey.reopen()
            try journey.expectText(expected)
            let export = journey.exportText(named: "After Reopen.txt")
            XCTAssertEqual(try Data(contentsOf: export), Data(expected.utf8))
            XCTAssertEqual(try Data(contentsOf: input), bytes)
            XCTAssertTrue(app.windows["Imported.fun"].exists)
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }

    func testInvalidTextImportKeepsTheCurrentDocument() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        journey.paste("Keep this writing")
        let invalid = fixture.directory.appending(path: "Invalid.txt")
        try Data([0xE2, 0x82]).write(to: invalid)
        try journey.step("Refuse malformed UTF-8 without replacing writing")
        {
            journey.importText(at: invalid)
            let sheet = app.windows["Untitled"].sheets.firstMatch
            XCTAssertTrue(sheet.waitForExistence(timeout: 5))
            XCTAssertTrue(sheet.staticTexts[
                "This file is not valid UTF-8 text. No document was imported."
            ].exists)
            sheet.buttons["OK"].click()
            try journey.expectText("Keep this writing")
            XCTAssertEqual(app.windows.count, 1)
        }
    }
}
