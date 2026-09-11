import XCTest

extension WritingUITests
{
    func testToolbarCodeLanguagePreservesExactLabelAndHistory() throws
    {
        try exerciseCodeLanguage(.toolbar)
    }

    func testFormatMenuCodeLanguagePreservesExactLabelAndHistory() throws
    {
        try exerciseCodeLanguage(.formatMenu)
    }

    func testOverflowCodeLanguagePreservesExactLabelAndHistory() throws
    {
        try exerciseCodeLanguage(.toolbarOverflow)
    }

    private func exerciseCodeLanguage(_ route: WritingUIFormattingRoute)
        throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "CodeLanguage.fun")
        let code = WritingUICodeFixture(tagged: true, source: "A")
        try code.write(to: journey.document)
        let app = journey.app
        let language = " Ru\u{301}st 😀 "
        try journey.step("Select code and cancel a contextual language change")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            try journey.reopen()
            if route == .toolbarOverflow
            {
                journey.resize(to: 360)
            }
            journey.editor.click()
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.downArrow, modifierFlags: [])
            app.typeKey(.leftArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
            journey.expectSelection("A")
            route.openCodeLanguage(in: journey)
            XCTAssertEqual(journey.codeLanguageField.value as? String,
                           code.language)
            journey.enterCodeLanguage("Cancelled")
            app.typeKey(.escape, modifierFlags: [])
            XCTAssertTrue(journey.codeLanguageField.waitForNonExistence(
                timeout: 5
            ))
            journey.expectSelection("A")
            try journey.saveCodeLanguage(code.language, from: code)
        }
        try journey.step("Refuse whitespace and apply an exact language label")
        {
            route.openCodeLanguage(in: journey)
            journey.enterCodeLanguage("   ")
            XCTAssertFalse(journey.window.sheets.buttons["Apply"].isEnabled)
            journey.enterCodeLanguage(language)
            journey.applyCodeLanguage()
            journey.expectSelection("A")
            try journey.saveCodeLanguage(language, from: code)
        }
        try journey.step("Undo and redo the language change independently")
        {
            app.typeKey("z", modifierFlags: [.command])
            try journey.saveCodeLanguage(code.language, from: code)
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.saveCodeLanguage(language, from: code)
            journey.expectSelection("A")
        }
        try journey.step("Clear the language without changing the source")
        {
            route.openCodeLanguage(in: journey)
            XCTAssertEqual((journey.codeLanguageField.value as? String).map
                { Array($0.utf16) }, Array(language.utf16))
            journey.enterCodeLanguage("")
            journey.applyCodeLanguage()
            journey.expectSelection("A")
            try journey.saveCodeLanguage(nil, from: code)
        }
        try journey.step("Reopen the plain code block")
        {
            try journey.reopen()
            try journey.expectText("Before\nA\nAfter")
            try journey.saveCodeLanguage(nil, from: code)
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
