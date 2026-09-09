import XCTest

extension WritingUITests
{
    func testCodeConversionKeepsSourceSelectionAndHistory() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "CodeConversion.fun")
        let app = journey.app
        let lines = ["let letter = \"e\u{301} 😀\"", "", "\treturn letter"]
        let source = lines.joined(separator: "\n")
        try journey.step("Convert the selected prose to one code block")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            journey.editor.click()
            journey.paste(source)
            app.typeKey("a", modifierFlags: [.command])
            journey.expectSelection(source)
            WritingUIFormattingRoute.toolbar.chooseBlock("Code", in: journey)
            journey.expectSelection(source)
            try journey.expectText(source)
            try journey.saveAs()
        }
        let joined = try journey.save { $0.blocks.count == 1 }
        XCTAssertEqual(joined.blocks.first?.content.kind, "code")
        XCTAssertNil(joined.blocks.first?.content.language)
        XCTAssertEqual(joined.blocks.first?.content.runs.flatMap
            { Array($0.text.utf16) }, Array(source.utf16))
        try journey.step("Undo and redo the code conversion")
        {
            app.typeKey("z", modifierFlags: [.command])
            let restored = try journey.save { $0.blocks.count == 3 }
            XCTAssertEqual(restored.blocks.map(\.content.kind),
                           Array(repeating: "paragraph", count: 3))
            XCTAssertEqual(restored.blocks.map
                { $0.content.runs.flatMap { Array($0.text.utf16) } },
                lines.map { Array($0.utf16) })
            app.typeKey("z", modifierFlags: [.command, .shift])
            let redone = try journey.save { $0.blocks.count == 1 }
            journey.expectIdentity(redone, from: joined)
            journey.expectSelection(source)
        }
        try journey.step("Use Format to return code lines to body paragraphs")
        {
            WritingUIFormattingRoute.formatMenu.chooseBlock("Body", in: journey)
            journey.expectSelection(source)
            try journey.expectText(source)
            let body = try journey.save { $0.blocks.count == 3 }
            XCTAssertEqual(body.documentID, joined.documentID)
            XCTAssertEqual(body.blocks.first?.blockID,
                           joined.blocks.first?.blockID)
            XCTAssertEqual(Set(body.blocks.map(\.blockID)).count, 3)
            XCTAssertEqual(body.blocks.map(\.content.kind),
                           Array(repeating: "paragraph", count: 3))
            XCTAssertEqual(body.blocks.map
                { $0.content.runs.flatMap { Array($0.text.utf16) } },
                lines.map { Array($0.utf16) })
        }
        try journey.step("Reopen the converted document without source loss")
        {
            try journey.reopen()
            try journey.expectText(source)
            journey.editor.click()
            app.typeKey("a", modifierFlags: [.command])
            journey.expectSelection(source)
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
