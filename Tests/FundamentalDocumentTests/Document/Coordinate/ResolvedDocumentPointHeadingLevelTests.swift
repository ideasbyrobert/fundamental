import Testing

@testable import FundamentalDocument

extension ResolvedDocumentPointTests
{
    @Test(
        "every section heading level resolves",
        arguments: SemanticHeadingLevel.allCases
    )
    func everySectionHeadingLevelResolves(
        _ level: SemanticHeadingLevel
    ) throws
    {
        let block = SemanticBlock.heading(
            .section(SectionSemanticHeading(
                runs: [SemanticRun(text: "A")],
                level: level
            ))
        )
        let document = try Self.document(blocks: [(2, block)])
        let point = try Self.point(offset: 1)

        #expect(ResolvedDocumentPoint(point, in: document) != nil)
    }
}
