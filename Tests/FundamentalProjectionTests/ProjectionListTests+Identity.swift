import Testing

@testable import FundamentalDocument
@testable import FundamentalProjection

extension ProjectionListTests
{
    @Test("neighbor membership changes context even with unchanged item source")
    func contextualIdentity() throws
    {
        let first = ProjectionListFixture.item(.numbered, "First")
        let last = ProjectionListFixture.item(.numbered, "Last")
        let body = ProjectionListFixture.body()
        let before = try ProjectionFixture.projection([body, first, last, body])
        let prepended = try ProjectionFixture.projection([
            ProjectionListFixture.item(.numbered, "Earlier"), first, last, body
        ])
        let appended = try ProjectionFixture.projection([
            body, first, last, ProjectionListFixture.item(.numbered, "Later")
        ])
        let unrelated = try ProjectionFixture.projection([
            ProjectionListFixture.body("Changed body"), first, last, body
        ])
        let original = before.blocks[1]
        let position = try #require(ProjectionListFixture.position(original))
        #expect(position.index == 0 && position.count == 2)
        for candidate in [prepended, appended]
        {
            let item = candidate.blocks[1]
            #expect(candidate.lineage == before.lineage)
            #expect(item.source == original.source)
            #expect(try ProjectionListFixture.prose(item).runs ==
                ProjectionListFixture.prose(original).runs)
            #expect(item != original)
            #expect(ProjectionListFixture.position(item)?.count == 3)
        }
        #expect(ProjectionListFixture.position(prepended.blocks[1])?.index == 1)
        #expect(ProjectionListFixture.position(appended.blocks[1])?.index == 0)
        #expect(unrelated.blocks[1] == original)
    }
}
