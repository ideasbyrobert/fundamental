import XCTest

extension WritingUIJourney
{
    func recoverNamedWriting(expected: String, saved: Data) throws
    {
        let addition = "Unsaved Мир e\u{301} 👨‍👩‍👧‍👦"
        let changed = expected + "\n" + addition
        try step("Checkpoint new writing without saving over the named file")
        {
            editor.click()
            app.typeKey(.downArrow, modifierFlags: [.command])
            paste("\n" + addition)
            app.typeKey(.leftArrow, modifierFlags: [.command, .shift])
            expectSelection(addition)
            wait("The named document's committed edit reaches recovery")
            {
                guard let checkpoint = try? fixture.checkpoints().first,
                      let record = try? checkpoint.content()
                else
                {
                    return false
                }
                let text = record.blocks.map
                {
                    $0.content.runs.map(\.text).joined()
                }.joined(separator: "\n")
                return checkpoint.name == documentName &&
                    text.utf16.elementsEqual(changed.utf16) &&
                    checkpoint.anchor.offset == 0 &&
                    checkpoint.focus.offset == addition.utf16.count
            }
            XCTAssertEqual(try Data(contentsOf: document), saved)
            try fixture.forceQuit()
        }
        app.launch()
        let recover = app.windows["Untitled"].sheets.buttons["Recover"]
        XCTAssertTrue(recover.waitForExistence(timeout: 10))
        recover.click()
        let restored = WritingUIJourney(fixture: fixture, test: test,
            documentName: "Recovered Daily.fun",
            initialWindowName: documentName + " — Recovered")
        try restored.step("Recover separately and preserve the original file")
        {
            XCTAssertTrue(restored.editor.waitForExistence(timeout: 10))
            try restored.expectText(changed)
            restored.expectSelection(addition)
            app.typeKey("z", modifierFlags: [.command])
            try restored.expectText(changed)
            let export = restored.exportText(named: "Recovered Export.txt")
            XCTAssertEqual(try Data(contentsOf: export), Data(changed.utf8))
            XCTAssertEqual(try Data(contentsOf: document), saved)
            XCTAssertEqual(try fixture.checkpoints().count, 1)
            try restored.saveAs()
            restored.wait("Explicit Save retires the recovered checkpoint")
            {
                (try? fixture.checkpoints().isEmpty) == true
            }
            try restored.reopen()
            try restored.expectText(changed)
            XCTAssertEqual(try Data(contentsOf: document), saved)
        }
    }
}
