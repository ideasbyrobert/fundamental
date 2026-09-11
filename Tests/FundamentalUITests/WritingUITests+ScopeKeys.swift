import XCTest

extension WritingUITests
{
    func testLinkShortcutCommitsCompositionAndScopesFutureTyping() throws
    {
        continueAfterFailure = false
        try WritingUIKeyboard.requireUS(in: self)
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self,
                                       documentName: "Scope Typing.fun")
        let app = fixture.app
        let link = "https://example.invalid/typing"
        let language = " ru-RU "
        let expected = [
            [WritingUIScopeRun("˜"),
             WritingUIScopeRun("Xe\u{301}😀", traits: ["strong"],
                               link: link, language: language)],
            [WritingUIScopeRun("Y", traits: ["strong"],
                               link: link, language: language)]
        ]
        try journey.step("Commit composition before choosing future scopes")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            journey.editor.click()
            app.typeKey("n", modifierFlags: [.option])
            app.typeKey("k", modifierFlags: [.command])
            XCTAssertTrue(journey.scopeField().waitForExistence(timeout: 5))
            journey.enterScope(link)
            journey.finishScope()
            journey.openScope(language: true, using: .formatMenu)
            journey.enterScope(language, language: true)
            journey.finishScope(language: true)
            app.typeKey("b", modifierFlags: [.command])
            app.typeText("X")
            journey.paste("e\u{301}😀")
            app.typeKey(.return, modifierFlags: [])
            app.typeText("Y")
            try journey.expectText("˜Xe\u{301}😀\nY")
            try journey.saveAs()
            _ = try journey.saveScopes(expected)
        }
        try journey.step("Undo content without finding extra scope history")
        {
            for _ in 0 ..< 4
            {
                app.typeKey("z", modifierFlags: [.command])
            }
            _ = try journey.saveScopes([[WritingUIScopeRun("˜")]])
            for _ in 0 ..< 4
            {
                app.typeKey("z", modifierFlags: [.command, .shift])
            }
            _ = try journey.saveScopes(expected)
        }
        try journey.step("Reopen composed and scoped typing")
        {
            try journey.reopen()
            try journey.expectText("˜Xe\u{301}😀\nY")
            _ = try journey.saveScopes(expected)
        }
    }
}
