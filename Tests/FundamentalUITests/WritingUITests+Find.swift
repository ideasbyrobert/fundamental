import XCTest

extension WritingUITests
{
    func testFindAndReplacePreservesUndoAndSavedText() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        let source = "Cat cat\ncat café cafe\u{301} 👨‍👩‍👧‍👦"
        let changed = "dog dog\ndog café cafe\u{301} 👨‍👩‍👧‍👦"
        try journey.step("Find original text and replace all three matches")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            journey.editor.click()
            journey.paste(source)
            journey.find("cat", replacing: true)
            journey.expectMatches("1 of 3")
            app.typeKey("g", modifierFlags: [.command])
            journey.expectMatches("2 of 3")
            app.typeKey("g", modifierFlags: [.command, .shift])
            journey.expectMatches("1 of 3")
            journey.replaceAll(with: "dog")
            try journey.expectText(changed)
        }
        try journey.step("One Undo restores the entire replacement")
        {
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText(source)
            app.typeKey("z", modifierFlags: [.command, .shift])
            try journey.expectText(changed)
        }
        try journey.step("Save and reopen the replaced canonical document")
        {
            try journey.saveAs()
            try journey.reopen()
            try journey.expectText(changed)
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }

    func testFindSelectsUnicodeAtNarrowAndNormalWidths() throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
        journey.editor.click()
        journey.paste("cafe\u{301} café\nМир мир 👨‍👩‍👧‍👦")
        for width in [360.0, 820.0]
        {
            journey.step("Find equivalent accents at width \(width)")
            {
                journey.resize(to: width)
                app.typeKey(.upArrow, modifierFlags: [.command])
                journey.find("é")
                journey.expectMatches("1 of 2")
                app.typeKey(.escape, modifierFlags: [])
                XCTAssertTrue(journey.findQuery.waitForNonExistence(timeout: 5))
                journey.expectSelection("e\u{301}")
                journey.find("é")
                journey.expectMatches("2 of 2")
                app.typeKey(.escape, modifierFlags: [])
                journey.expectSelection("é")
            }
        }
    }
}
