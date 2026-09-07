import Testing

@testable import FundamentalDocument

extension DocumentHistoryTests
{
    @Test("a checkpoint retains its earlier content origin")
    func retainedContentOrigin() throws
    {
        let fixture = try SessionTestDocument(revision: 8)
        let original = try #require(DocumentHistoryCheckpoint(fixture.editable))
        let restored = try #require(DocumentHistoryCheckpoint(
            fixture.editable, contentRevision: DocumentRevision(3)
        ))
        #expect(original.contentRevision == DocumentRevision(8))
        #expect(restored.contentRevision == DocumentRevision(3))
        #expect(restored.snapshot == original.snapshot)
        #expect(restored.retainedUTF16Units == original.retainedUTF16Units)
    }

    @Test("a content origin cannot name a future document revision")
    func futureContentOrigin() throws
    {
        let fixture = try SessionTestDocument(revision: 8)
        for value in [UInt64(9), UInt64.max]
        {
            #expect(DocumentHistoryCheckpoint(
                fixture.editable, contentRevision: DocumentRevision(value)
            ) == nil)
        }
    }
}
