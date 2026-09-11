import XCTest

extension WritingUITests
{
    func testTextLanguageAndCodeLanguageRemainIndependent() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Code Scopes.fun")
        let source = WritingUICodeFixture(tagged: true, source: "Ae\u{301}😀Z")
        try source.write(to: journey.document)
        let app = fixture.app
        let link = "https://example.invalid/code"
        let language = " ru-RU "
        let expected = [[WritingUIScopeRun("Before")],
            [WritingUIScopeRun(source.source, traits: ["strong"],
                               link: link, language: language)],
            [WritingUIScopeRun("After")]]
        let removed = [expected[0],
            [WritingUIScopeRun(source.source, traits: ["strong"], link: link)],
            expected[2]]
        try journey.step("Add text language and link inside tagged code")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            journey.editor.click()
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.downArrow, modifierFlags: [])
            app.typeKey(.leftArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
            journey.expectSelection(source.source)
            journey.openScope(language: true, using: .toolbar)
            journey.enterScope(language, language: true)
            journey.finishScope(language: true)
            app.typeKey("k", modifierFlags: [.command])
            XCTAssertTrue(journey.scopeField().waitForExistence(timeout: 5))
            journey.enterScope(link)
            journey.finishScope()
            app.typeKey("b", modifierFlags: [.command])
            journey.expectSelection(source.source)
            _ = try journey.saveScopes(expected)
        }
        try journey.step("Remove text language while keeping the code label")
        {
            journey.openScope(language: true, using: .formatMenu)
            XCTAssertEqual(journey.scopeField(language: true).value as? String,
                           language)
            journey.finishScope("Remove Language", language: true)
            _ = try journey.saveScopes(removed)
            app.typeKey("z", modifierFlags: [.command])
            _ = try journey.saveScopes(expected)
            app.typeKey("z", modifierFlags: [.command, .shift])
            _ = try journey.saveScopes(removed)
        }
        try journey.step("Reopen code with independent semantic attributes")
        {
            try journey.reopen()
            try journey.expectText("Before\n" + source.source + "\nAfter")
            let record = try journey.saveScopes(removed)
            XCTAssertEqual(record.documentID, source.documentID)
            XCTAssertEqual(record.blocks.map(\.blockID), source.blockIDs)
            XCTAssertEqual(record.blocks.map(\.content.kind),
                           ["paragraph", "languageCode", "paragraph"])
            XCTAssertEqual(record.blocks.map(\.content.language),
                           [nil, source.language, nil])
        }
    }
}
