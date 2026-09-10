import XCTest

extension WritingUIJourney
{
    func scopeField(language: Bool = false) -> XCUIElement
    {
        app.textFields[language ? "FundamentalLanguageScopeField" :
            "FundamentalLinkScopeField"]
    }

    func openScope(
        language: Bool = false, using route: WritingUIFormattingRoute
    )
    {
        route.chooseTextStyle(language ? "Text Language…" : "Link…", in: self)
        step("Inspect " + (language ? "Text Language" : "Link") + " sheet")
        {
            XCTAssertTrue(scopeField(language: language).waitForExistence(
                timeout: 5
            ))
        }
    }

    func enterScope(_ value: String, language: Bool = false)
    {
        let field = scopeField(language: language)
        field.click()
        field.typeKey("a", modifierFlags: [.command])
        if value.isEmpty
        {
            field.typeKey(.delete, modifierFlags: [])
        }
        else
        {
            paste(value)
        }
        step("Inspect exact scope value and available actions")
        {
            XCTAssertEqual((field.value as? String).map { Array($0.utf16) },
                           Array(value.utf16))
        }
    }

    func finishScope(_ button: String = "Apply", language: Bool = false)
    {
        let action = window.sheets.buttons[button]
        XCTAssertTrue(action.isEnabled)
        action.click()
        XCTAssertTrue(scopeField(language: language).waitForNonExistence(
            timeout: 5
        ))
    }

    func saveScopes(_ expected: [[WritingUIScopeRun]]) throws
        -> WritingUIRecord
    {
        try save
        {
            record in
            guard record.format == "fundamental-document",
                  record.version == 1, record.blocks.count == expected.count
            else
            {
                return false
            }
            return zip(record.blocks, expected).allSatisfy
            {
                block, runs in
                WritingUIScopeRun.matches(block.content.runs, runs)
            }
        }
    }
}
