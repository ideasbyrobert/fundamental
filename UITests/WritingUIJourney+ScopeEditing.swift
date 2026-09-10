import XCTest

extension WritingUIJourney
{
    func editSelectedScopes(
        _ source: WritingUIScopeControlFixture,
        using route: WritingUIFormattingRoute
    ) throws
    {
        let link = WritingUIScopeControlFixture.changedLink
        let language = WritingUIScopeControlFixture.changedLanguage
        try step("Apply a link to a partial backward Unicode selection")
        {
            app.typeKey(.downArrow, modifierFlags: [.command])
            app.typeKey(.leftArrow, modifierFlags: [])
            app.typeKey(.leftArrow, modifierFlags: [.shift])
            app.typeKey(.leftArrow, modifierFlags: [.shift])
            expectSelection(source.texts[1])
            openScope(using: route)
            XCTAssertEqual((scopeField().value as? String).map
                { Array($0.utf16) },
                Array(WritingUIScopeControlFixture.innerLink.utf16))
            enterScope("   ")
            XCTAssertFalse(window.sheets.buttons["Apply"].isEnabled)
            enterScope(link)
            finishScope()
            expectSelection(source.texts[1])
            _ = try saveScopes(source.expected(link: link))
        }
        try step("Set text language while preserving its link and bold")
        {
            openScope(language: true, using: route)
            XCTAssertEqual(scopeField(language: true).value as? String,
                           WritingUIScopeControlFixture.language)
            enterScope(language, language: true)
            finishScope(language: true)
            expectSelection(source.texts[1])
            _ = try saveScopes(source.expected(link: link, language: language))
            app.typeKey("z", modifierFlags: [.command])
            _ = try saveScopes(source.expected(link: link))
            app.typeKey("z", modifierFlags: [.command, .shift])
            _ = try saveScopes(source.expected(link: link, language: language))
        }
        try step("Remove only the selected link and preserve language")
        {
            openScope(using: route)
            enterScope("")
            XCTAssertFalse(window.sheets.buttons["Apply"].isEnabled)
            finishScope("Remove Link")
            expectSelection(source.texts[1])
            _ = try saveScopes(source.expected(link: nil, language: language))
            app.typeKey("z", modifierFlags: [.command])
            _ = try saveScopes(source.expected(link: link, language: language))
            app.typeKey("z", modifierFlags: [.command, .shift])
            _ = try saveScopes(source.expected(link: nil, language: language))
        }
    }
}
