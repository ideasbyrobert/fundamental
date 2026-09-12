import XCTest

extension WritingUIJourney
{
    var findQuery: XCUIElement
    {
        window.searchFields["FundamentalFindQuery"]
    }

    func find(_ text: String, replacing: Bool = false)
    {
        app.typeKey("f", modifierFlags: replacing ? [.command, .option] :
            [.command])
        XCTAssertTrue(findQuery.waitForExistence(timeout: 5))
        findQuery.typeKey("a", modifierFlags: [.command])
        paste(text)
        findQuery.typeKey(.return, modifierFlags: [])
    }

    func expectMatches(_ text: String)
    {
        let count = window.staticTexts["FundamentalFindCount"]
        wait("The Find bar must report " + text)
        {
            count.value as? String == text
        }
    }

    func replaceAll(with text: String)
    {
        let replacement = window.textFields["FundamentalFindReplacement"]
        XCTAssertTrue(replacement.waitForExistence(timeout: 5))
        replacement.click()
        replacement.typeKey("a", modifierFlags: [.command])
        paste(text)
        let button = window.buttons["FundamentalFindReplaceAll"]
        XCTAssertTrue(button.isHittable)
        XCTAssertTrue(button.isEnabled)
        button.click()
    }
}
