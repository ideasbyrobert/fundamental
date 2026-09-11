import XCTest

extension WritingUIJourney
{
    func writeHeadingDocument(
        _ texts: [String], using route: WritingUIFormattingRoute
    ) throws -> WritingUIRecord
    {
        XCTAssertTrue(editor.waitForExistence(timeout: 10))
        editor.click()
        paste(texts.joined(separator: "\n"))
        app.typeKey(.upArrow, modifierFlags: [.command])
        app.typeKey(.rightArrow, modifierFlags: [.command, .shift])
        expectSelection(texts[0])
        route.chooseHeading(in: self)
        try saveAs()
        return try save(numbered: false, texts: texts)
    }

    func selectFollowingParagraphs(_ texts: [String])
    {
        app.typeKey(.upArrow, modifierFlags: [.command])
        app.typeKey(.downArrow, modifierFlags: [])
        app.typeKey(.leftArrow, modifierFlags: [.command])
        app.typeKey(.downArrow, modifierFlags: [.command, .shift])
        expectSelection(texts.dropFirst().joined(separator: "\n"))
    }

    func expectIdentity(_ record: WritingUIRecord, from prior: WritingUIRecord)
    {
        XCTAssertEqual(record.documentID, prior.documentID)
        XCTAssertEqual(record.blocks.map(\.blockID),
                       prior.blocks.map(\.blockID))
        XCTAssertGreaterThan(record.revision, prior.revision)
    }
}
