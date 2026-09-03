import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

@Suite("Canonical document projection")
struct ProjectionProseTests
{
    @Test("lineage and block order remain exact")
    func lineageAndBlockOrderRemainExact() throws
    {
        let blocks = [
            SemanticBlock.paragraph(SemanticParagraph(runs: [])),
            .heading(.title(TitleSemanticHeading(runs: [])))
        ]
        let projection = try ProjectionFixture.projection(blocks)

        #expect(projection.lineage.documentID == ProjectionFixture.documentID)
        #expect(projection.lineage.revision == 7)
        #expect(projection.lineage.generation == 9)
        #expect(projection.blocks.map(\.source.ordinal) == [0, 1])
        #expect(projection.blocks[0].source.blockID
            == ProjectionFixture.blockID(0))
        #expect(projection.blocks[1].source.blockID
            == ProjectionFixture.blockID(1))
    }

    @Test("paragraph title and every section level retain their roles")
    func proseRolesRemainExact() throws
    {
        let headings = SemanticHeadingLevel.allCases.map
        {
            SemanticBlock.heading(.section(SectionSemanticHeading(
                runs: [],
                level: $0
            )))
        }
        let blocks = [
            SemanticBlock.paragraph(SemanticParagraph(runs: [])),
            .heading(.title(TitleSemanticHeading(runs: [])))
        ] + headings
        let projection = try ProjectionFixture.projection(blocks)
        let roles: [ProjectedProseRole] = projection.blocks.compactMap
        {
            guard case let .prose(_, prose) = $0
            else
            {
                return nil
            }
            return prose.role
        }

        #expect(roles == [
            .body,
            .title,
            .section(.one),
            .section(.two),
            .section(.three),
            .section(.four),
            .section(.five),
            .section(.six)
        ])
    }
}
