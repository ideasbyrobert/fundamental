import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test
    func checkpointRetainsExactSnapshotAndUTF16Count() throws
    {
        let fixture = try SessionTestDocument(texts: ["e\u{301}", "😀", ""])
        let checkpoint = try #require(DocumentHistoryCheckpoint(
            fixture.editable
        ))
        #expect(checkpoint.snapshot == fixture.editable)
        #expect(checkpoint.retainedUTF16Units == 4)
        let runs = try #require(EditableSemanticBlock(
            checkpoint.snapshot.snapshot.document.content.firstBlock.block
        )).runs
        #expect(runs.map { Array($0.text.utf16) } == [[0x65, 0x301]])
        #expect(sent(checkpoint) == checkpoint)
    }

    func sent<Value: Sendable>(_ value: Value) -> Value
    {
        value
    }
}
