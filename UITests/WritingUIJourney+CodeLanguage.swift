import XCTest

extension WritingUIJourney
{
    var codeLanguageField: XCUIElement
    {
        app.textFields["FundamentalCodeLanguageField"]
    }

    func enterCodeLanguage(_ value: String)
    {
        codeLanguageField.click()
        codeLanguageField.typeKey("a", modifierFlags: [.command])
        if value.isEmpty
        {
            codeLanguageField.typeKey(.delete, modifierFlags: [])
        }
        else
        {
            paste(value)
        }
        let actual = codeLanguageField.value as? String
        XCTAssertEqual(actual.map { Array($0.utf16) }, Array(value.utf16))
    }

    func applyCodeLanguage()
    {
        let apply = window.sheets.buttons["Apply"]
        XCTAssertTrue(apply.isEnabled)
        apply.click()
        XCTAssertTrue(codeLanguageField.waitForNonExistence(timeout: 5))
    }

    func saveCodeLanguage(_ language: String?, from code: WritingUICodeFixture)
        throws
    {
        let record = try save
        {
            $0.blocks.count == 3 &&
                $0.blocks[1].content.language.map { Array($0.utf16) } ==
                language.map { Array($0.utf16) }
        }
        XCTAssertEqual(record.documentID, code.documentID)
        XCTAssertEqual(record.blocks.map(\.blockID), code.blockIDs)
        XCTAssertEqual(record.blocks.map(\.content.kind),
                       ["paragraph", language == nil ? "code" : "languageCode",
                        "paragraph"])
        XCTAssertTrue(code.matches(record, code: code.source, after: "After"))
        XCTAssertTrue(record.blocks.flatMap(\.content.runs).allSatisfy
        {
            $0.traits.isEmpty && $0.link == nil && $0.language == nil
        })
    }
}
