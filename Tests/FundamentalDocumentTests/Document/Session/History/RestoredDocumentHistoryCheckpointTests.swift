import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test
    func restorationRebindsExactContentAndDirectionalSelection() throws
    {
        let fixture = try HistoryRestorationTestDocument()
        let restored = try #require(RestoredDocumentHistoryCheckpoint(
            fixture.checkpoint,
            in: fixture.current
        )).snapshot
        let document = restored.snapshot.document
        let stored = fixture.checkpoint.snapshot
        #expect(document.documentID == fixture.current.document.documentID)
        #expect(document.revision.value == 91)
        #expect(restored.snapshot.generation.value == 101)
        #expect(document.content == stored.snapshot.document.content)
        let runs = try #require(EditableSemanticBlock(
            document.content.firstBlock.block
        )).runs
        #expect(runs.map { Array($0.text.utf16) } == [
            [0x41], [0xD83D, 0xDE00], [0x65, 0x301, 0x42]
        ])
        guard case let .scoped(scoped) = runs[1]
        else
        {
            Issue.record("Expected retained scoped run")
            return
        }
        #expect(scoped.traits == [.strong])
        let language = try #require(SemanticLanguageIdentifier("fr"))
        #expect(scoped.scopes == .language(language))
        let range = restored.selection.range
        #expect(range.start.utf16Offset.value == 6)
        #expect(range.end.utf16Offset.value == 1)
        #expect(range.revision == document.revision)
        #expect(range.start.blockID == stored.selection.range.start.blockID)
        #expect(stored.snapshot.document.revision.value == 9)
        #expect(stored.snapshot.generation.value == 4)
        #expect(sent(restored) == restored)
    }
}
