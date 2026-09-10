import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

@Suite("Canonical contiguous list projection")
struct ProjectionListTests
{
    @Test("kind changes and non-list blocks end a list; empty items count")
    func transitions() throws
    {
        let blocks: [SemanticBlock] = [
            ProjectionListFixture.body(),
            ProjectionListFixture.item(.bulleted, "Bullet"),
            .listItem(SemanticListItem(kind: .bulleted, runs: [])),
            ProjectionListFixture.item(.numbered, "One\ncontinuation"),
            ProjectionListFixture.item(.numbered, "Two"),
            ProjectionListFixture.item(.numbered, ""),
            ProjectionListFixture.body(),
            ProjectionListFixture.item(.numbered, "Restart"),
            .heading(.title(TitleSemanticHeading(runs: []))),
            ProjectionListFixture.item(.bulleted, "Final")
        ]
        let projection = try ProjectionFixture.projection(blocks)
        let positions = projection.blocks.map(ProjectionListFixture.position)
        #expect(positions.map { $0?.index } ==
            [nil, 0, 1, 0, 1, 2, nil, 0, nil, 0])
        #expect(positions.map { $0?.count } ==
            [nil, 2, 2, 3, 3, 3, nil, 1, nil, 1])
        let prose = try projection.blocks.map(ProjectionListFixture.prose)
        #expect(prose[2].runs.isEmpty)
        #expect(prose.map { $0.runs.map(\.text).joined() } == [
            "Body", "Bullet", "", "One\ncontinuation", "Two", "", "Body",
            "Restart", "", "Final"
        ])
        #expect(projection.blocks.map(\.source.ordinal) == Array(0 ..< 10))
        #expect(projection.blocks.map(\.source.blockID) ==
            (0 ..< 10).map(ProjectionFixture.blockID))
    }

    @Test("lists keep their full context when accessed backwards",
          arguments: SemanticListKind.allCases, [1, 9, 10, 99, 100, 10_000])
    func independentTraversal(_ kind: SemanticListKind, count: Int) throws
    {
        let items = (0 ..< count).map
        {
            ProjectionListFixture.item(kind, "\($0)e\u{301}😀")
        }
        let projection = try ProjectionFixture.projection(
            [ProjectionListFixture.body()] + items
        )
        #expect(projection.blocks.count == count + 1)
        for block in projection.blocks.dropFirst().reversed()
        {
            let position = try #require(ProjectionListFixture.position(block))
            #expect(position.index == block.source.ordinal - 1)
            #expect(position.count == count)
            #expect(position.number == block.source.ordinal)
            let prose = try ProjectionListFixture.prose(block)
            let expected: ProjectedProseRole = kind == .bulleted
                ? .bulleted(position) : .numbered(position)
            #expect(prose.role == expected)
            #expect(prose.runs.map(\.text) == ["\(position.index)e\u{301}😀"])
            #expect(block.source.blockID ==
                ProjectionFixture.blockID(block.source.ordinal))
        }
    }
}
