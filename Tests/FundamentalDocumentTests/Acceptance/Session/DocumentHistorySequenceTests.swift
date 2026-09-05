import Testing

@testable import FundamentalDocument

@Suite("Canonical history event sequences", .serialized)
@MainActor
struct DocumentHistorySequenceTests
{
    @Test
    func equalLookingReplacementUndoAndRedoKeepExactSpelling() throws
    {
        let fixture = try SessionTestDocument(texts: ["\u{E9}"])
        let driver = SessionHistoryTestDriver(fixture)
        let insertion = try #require(SemanticInsertion(
            text: "e\u{301}",
            attributes: .direct(traits: [])
        ))
        let replacement = try #require(SemanticTextReplacement(
            range: driver.range(0, 1),
            insertion: insertion
        ))
        let after = try driver.edit(.text(.replacement(replacement)))
        try driver.expect("e\u{301}", revision: 9, generation: 4)
        #expect(driver.session.history.undo.count == 1)
        #expect(after.snapshot.document.content ==
            fixture.editable.snapshot.document.content)
        let observation = driver.session.observation
        try driver.move(.undo)
        try driver.expect("\u{E9}", revision: 10, generation: 5)
        #expect(driver.session.canRedo)
        try driver.move(.redo)
        try driver.expect("e\u{301}", revision: 11, generation: 6)
        #expect(driver.session.submit(DocumentHistoryCommand(
            observation: observation,
            direction: .undo
        )) == .refused(.staleObservation))
        let retained = try #require(EditableSemanticBlock(
            after.snapshot.document.content.firstBlock.block
        )).runs
        #expect(retained.map { Array($0.text.utf16) } == [[0x65, 0x301]])
        #expect(after.snapshot.document.revision.value == 9)
        #expect(fixture.editable.snapshot.document.revision.value == 8)
    }
}
