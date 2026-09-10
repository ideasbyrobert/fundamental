import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

extension ProjectionProseTests
{
    @Test("both list kinds preserve role source coordinates and spelling")
    func listsPreserveRoles() throws
    {
        let blocks = SemanticListKind.allCases.map
        {
            SemanticBlock.listItem(SemanticListItem(
                kind: $0, runs: [SemanticRun(text: "e\u{301}😀")]
            ))
        }
        let projection = try ProjectionFixture.projection(blocks)
        let position = try #require(ProjectedListPosition(index: 0, count: 1))
        let expected: [ProjectedProseRole] = [
            .bulleted(position), .numbered(position)
        ]
        for (index, block) in projection.blocks.enumerated()
        {
            guard case let .prose(source, prose) = block
            else
            {
                Issue.record("Expected a list item projection")
                return
            }
            #expect(prose.role == expected[index])
            #expect(source.ordinal == index)
            #expect(source.blockID == ProjectionFixture.blockID(index))
            #expect(prose.runs.map(\.text) == ["e\u{301}😀"])
        }
    }
}
