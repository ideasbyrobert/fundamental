import XCTest

extension WritingUITests
{
    func testToolbarPreservesEveryHeadingLevel() throws
    {
        try exerciseHeadings(.toolbar)
    }

    func testFormatKeysPreserveEveryHeadingLevel() throws
    {
        try exerciseHeadings(.formatMenu)
    }

    func testOverflowPreservesEveryHeadingLevel() throws
    {
        try exerciseHeadings(.toolbarOverflow)
    }

    private func exerciseHeadings(_ route: WritingUIFormattingRoute) throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Heading Levels.fun")
        let app = journey.app
        let texts = ["Distinct title", "Section e\u{301} 😀", "Раздел"]
        let text = texts.joined(separator: "\n")
        let following = texts.dropFirst().joined(separator: "\n")
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        journey.paste(text)
        if route == .toolbarOverflow
        {
            journey.resize(to: 360)
        }
        app.typeKey(.upArrow, modifierFlags: [.command])
        app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
        route.chooseBlock("Title", in: journey)
        try journey.saveAs()
        var prior = try journey.saveHeadings(level: 0, texts: texts)
        journey.selectFollowingParagraphs(texts)
        for level in 1 ... 6
        {
            try journey.step("Assign exact heading level \(level)")
            {
                route.chooseBlock("Heading \(level)", in: journey)
                journey.expectSelection(following)
                let record = try journey.saveHeadings(level: level,
                                                       texts: texts)
                journey.expectIdentity(record, from: prior)
                prior = record
            }
        }
        try journey.step("Cancel mixed headings without changing meaning")
        {
            app.typeKey("a", modifierFlags: [.command])
            journey.inspectMixedHeadings(using: route)
            journey.expectSelection(text)
            let record = try journey.saveHeadings(level: 6, texts: texts)
            XCTAssertEqual(record.revision, prior.revision)
        }
        try journey.step("Undo redo and replace at the retained selection")
        {
            app.typeKey("z", modifierFlags: [.command])
            _ = try journey.saveHeadings(level: 5, texts: texts)
            app.typeKey("z", modifierFlags: [.command, .shift])
            _ = try journey.saveHeadings(level: 6, texts: texts)
            journey.expectSelection(following)
            app.typeText("X")
            try journey.expectText(texts[0] + "\nX")
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText(text)
            let record = try journey.saveHeadings(level: 6, texts: texts)
            journey.expectIdentity(record, from: prior)
        }
        try journey.step("Reopen the exact heading document")
        {
            try journey.reopen()
            try journey.expectText(text)
            let record = try journey.saveHeadings(level: 6, texts: texts)
            XCTAssertEqual(record.documentID, prior.documentID)
            XCTAssertEqual(record.blocks.map(\.blockID),
                           prior.blocks.map(\.blockID))
        }
    }
}
