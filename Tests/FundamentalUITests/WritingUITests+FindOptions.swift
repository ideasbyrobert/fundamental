import XCTest

extension WritingUITests
{
    func testFindOptionsStayWithTheirDocument() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        try journey.step("Choose matching and replacement when needed")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            journey.editor.click()
            journey.paste("Cat cat cat")
            try journey.saveAs()
            journey.find("cat")
            journey.expectMatches("1 of 3")
            chooseFindOption("Match Case", in: journey)
            journey.expectMatches("2 matches")
            journey.window.buttons["FundamentalFindNext"].click()
            journey.expectMatches("1 of 2")
            chooseFindOption("Show Replace", in: journey)
            let replacement = journey.window.textFields[
                "FundamentalFindReplacement"
            ]
            XCTAssertTrue(replacement.waitForExistence(timeout: 5))
            chooseFindOption("Show Replace", in: journey)
            XCTAssertTrue(replacement.waitForNonExistence(timeout: 5))
        }
        let other = WritingUIJourney(fixture: fixture, test: self,
                                     documentName: "Second.fun")
        app.typeKey("n", modifierFlags: [.command])
        other.step("A second document starts with its own Find choices")
        {
            XCTAssertTrue(other.editor.waitForExistence(timeout: 10))
            other.editor.click()
            other.paste("Cat cat")
            other.find("cat")
            other.expectMatches("1 of 2")
            XCTAssertFalse(other.window.textFields[
                "FundamentalFindReplacement"
            ].exists)
        }
        journey.step("Return to the first document's case-sensitive search")
        {
            journey.window.click()
            XCTAssertEqual(journey.findQuery.value as? String, "cat")
            journey.expectMatches("1 of 2")
        }
    }

    private func chooseFindOption(
        _ title: String, in journey: WritingUIJourney
    )
    {
        let options = journey.findQuery.buttons[
            "Magnifying glass with a downward chevron"
        ]
        XCTAssertTrue(options.isHittable)
        options.click()
        let item = journey.app.menuItems[title]
        XCTAssertTrue(item.wait(for: \.isHittable, toEqual: true, timeout: 5))
        item.click()
    }
}
