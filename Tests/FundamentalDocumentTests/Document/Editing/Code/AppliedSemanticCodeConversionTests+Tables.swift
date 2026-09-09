import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("tables anywhere in the source refuse structural code conversion")
    @MainActor
    func tablesRefuse() throws
    {
        for table in try BlockRecordTestValue.tables()
        {
            let source = try SemanticWritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: [SemanticRun(text: "A")])),
                .table(table)
            ])
            let conversion = SemanticCodeConversion(
                range: try source.range((0, 0), (0, 0))
            )
            #expect(AppliedSemanticCodeConversion(
                conversion, in: source.document
            ) == nil)
            let snapshot = DocumentSnapshot(
                generation: SnapshotGeneration(0), document: source.document
            )
            let session = DocumentSession(
                state: .readable(snapshot), initiallySaved: true
            )
            let before = session.current
            #expect(session.submit(.convertCode(
                session.observation, conversion
            )) == .refused(.readOnly))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }
}
