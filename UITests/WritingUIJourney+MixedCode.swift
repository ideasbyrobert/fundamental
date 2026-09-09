import XCTest

extension WritingUIJourney
{
    func replaceWholeDocumentThenUndo(_ source: String, leadingID: UUID)
        throws
    {
        app.typeKey("a", modifierFlags: [.command])
        expectSelection(source)
        app.typeText("X")
        try expectText("X")
        let replacement = try save { $0.blocks.count == 1 }
        XCTAssertEqual(replacement.blocks[0].blockID, leadingID)
        XCTAssertEqual(replacement.blocks[0].content.kind, "paragraph")
        XCTAssertEqual(replacement.blocks[0].content.runs.map(\.text).joined(),
                       "X")
        app.typeKey("z", modifierFlags: [.command])
        try expectText(source)
        expectSelection(source)
    }

    func expectReplacement(
        _ record: WritingUIRecord, fixture: WritingUICodeFixture,
        codeLeading: Bool, text: String
    )
    {
        XCTAssertEqual(record.documentID, fixture.documentID)
        XCTAssertEqual(record.blocks.map(\.blockID), codeLeading
            ? Array(fixture.blockIDs.prefix(2))
            : [fixture.blockIDs[0], fixture.blockIDs[2]])
        XCTAssertEqual(record.blocks.map(\.content.kind), codeLeading
            ? ["paragraph", "languageCode"] : ["paragraph", "paragraph"])
        let index = codeLeading ? 1 : 0
        XCTAssertEqual(record.blocks[index].content.language,
                       codeLeading ? fixture.language : nil)
        XCTAssertEqual(record.blocks[index].content.runs.flatMap
            { Array($0.text.utf16) }, Array(text.utf16))
        XCTAssertEqual(record.blocks[codeLeading ? 0 : 1].content.runs
            .map(\.text).joined(), codeLeading ? "Before" : "After")
    }
}
