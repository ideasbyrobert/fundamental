import Testing

@testable import FundamentalDocument

extension ResolvedDocumentPointTests
{
    @Test("present empty runs keep their earliest run position")
    func presentEmptyRunsKeepTheirEarliestPosition() throws
    {
        for texts in [[""], ["", "A"]]
        {
            let document = try Self.document(blocks: [
                (2, Self.paragraph(texts))
            ])
            let resolved = try #require(
                ResolvedDocumentPoint(try Self.point(), in: document)
            )

            #expect(resolved.runPosition == .run(
                index: 0,
                utf16Offset: try Self.offset(0)
            ))
        }
    }
}
