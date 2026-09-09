import XCTest

@MainActor
final class WritingUITests: XCTestCase
{
    func testFormattingKeepsSelectionAndMeaning() throws
    {
        try exerciseFormatting(.toolbar)
    }

    func testFormatMenuKeepsSelectionAndMeaning() throws
    {
        try exerciseFormatting(.formatMenu)
    }

    private func exerciseFormatting(_ route: WritingUIFormattingRoute) throws
    {
        continueAfterFailure = false
        let fixture = try WritingUIFixture(test: self)
        let journey = WritingUIJourney(fixture: fixture, test: self)
        let app = fixture.app
        let texts = ["Heading", "First item 😀", "Second item e\u{301}"]
        let text = texts.joined(separator: "\n")
        try journey.step("Write and format a heading")
        {
            XCTAssertTrue(journey.editor.waitForExistence(timeout: 10))
            journey.editor.click()
            journey.paste(text)
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
            journey.expectSelection(texts[0])
            route.chooseHeading(in: app)
            try journey.expectText(text)
        }
        journey.step("Select two paragraphs and number them")
        {
            app.typeKey(.upArrow, modifierFlags: [.command])
            app.typeKey(.downArrow, modifierFlags: [])
            app.typeKey(.leftArrow, modifierFlags: [.command])
            app.typeKey(.downArrow, modifierFlags: [.command, .shift])
            journey.expectSelection(texts.dropFirst().joined(separator: "\n"))
            route.chooseList("Numbered", in: app)
        }
        try journey.step("Save the numbered document")
        {
            try journey.saveAs()
        }
        let original = try journey.save(numbered: true, texts: texts)
        journey.step("Cancel the mixed List menu without losing selection")
        {
            app.typeKey("a", modifierFlags: [.command])
            route.cancelMixedList(in: app)
            journey.expectSelection(text)
        }
        journey.step("Remove list roles while retaining the heading")
        {
            route.chooseList("No List", in: app)
            journey.expectSelection(text)
        }
        let removed = try journey.save(numbered: false, texts: texts)
        XCTAssertEqual(removed.documentID, original.documentID)
        XCTAssertEqual(removed.blocks.map(\.blockID),
                       original.blocks.map(\.blockID))
        try journey.step("Undo and redo the single formatting action")
        {
            app.typeKey("z", modifierFlags: [.command])
            _ = try journey.save(numbered: true, texts: texts)
            app.typeKey("z", modifierFlags: [.command, .shift])
            _ = try journey.save(numbered: false, texts: texts)
            journey.expectSelection(text)
        }
        try journey.step("Type at the retained selection and undo")
        {
            app.typeText("X")
            try journey.expectText("X")
            app.typeKey("z", modifierFlags: [.command])
            try journey.expectText(text)
            _ = try journey.save(numbered: false, texts: texts)
        }
        try journey.step("Close and reopen the owned document")
        {
            try journey.reopen()
            try journey.expectText(text)
        }
        app.typeKey("q", modifierFlags: [.command])
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
    }
}
