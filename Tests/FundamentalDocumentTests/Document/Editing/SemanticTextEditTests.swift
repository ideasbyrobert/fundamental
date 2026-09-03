import Testing

@testable import FundamentalDocument

@Suite("A semantic text edit")
struct SemanticTextEditTests
{
    @Test("the union preserves every distinct admitted form")
    func unionPreservesEveryDistinctForm() throws
    {
        let values = try Self.values()
        let edits: [SemanticTextEdit] = [
            .insertion(values.insertion),
            .deletion(values.deletion),
            .replacement(values.replacement)
        ]

        #expect(Set(edits.map(Self.form)) == [0, 1, 2])
        #expect(edits[0] == .insertion(values.insertion))
        #expect(edits[1] == .deletion(values.deletion))
        #expect(edits[2] == .replacement(values.replacement))
    }

    @Test("reconstruction leaves earlier values unchanged")
    func reconstructionLeavesEarlierValuesUnchanged() throws
    {
        let values = try Self.values()
        let changedRange = try Self.range(from: 4, to: 9)
        let changedInsertion = try Self.insertion("Changed")
        let changed = try #require(SemanticTextReplacement(
            range: changedRange,
            insertion: changedInsertion
        ))

        Self.acceptsSendable(SemanticTextEdit.replacement(changed))
        #expect(values.replacement.range.start.utf16Offset.value == 2)
        #expect(values.replacement.range.end.utf16Offset.value == 5)
        #expect(values.replacement.insertion.text == "Text")
        #expect(changed.range.start.utf16Offset.value == 4)
        #expect(changed.range.end.utf16Offset.value == 9)
        #expect(changed.insertion.text == "Changed")
    }
}
