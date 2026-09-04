import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

extension SummitResidentLayoutWindowTests
{
    @Test("long unrelated tails leave resident rich work bounded")
    func longCorpusRemainsBounded() throws
    {
        let prefix = ViewportWindowFixture.fixedBlocks(
            count: 32,
            prefix: "shared"
        )
        let short = try ViewportWindowFixture.product(
            projection: ViewportWindowFixture.projection(prefix),
            width: 360,
            originY: 0,
            height: 24,
            overscan: 40,
            limit: 8
        )
        let tail = ViewportWindowFixture.fixedBlocks(
            count: 2_048,
            prefix: "unrelated tail"
        )
        let long = try ViewportWindowFixture.product(
            projection: ViewportWindowFixture.projection(
                prefix + tail,
                generation: 10
            ),
            width: 360,
            originY: 0,
            height: 24,
            overscan: 40,
            limit: 8
        )
        #expect(short.diagnostics.materializationUsage
            == long.diagnostics.materializationUsage)
        #expect(short.expected.residents.all
            == long.expected.residents.all)
        #expect(long.diagnostics.query.totalFragmentsExamined < 128)
        #expect(long.expected.residents.all.allSatisfy
        {
            $0.fragment.anchor.blockOrdinal < 32
        })
    }

    @Test("one resident line charges its complete source block only")
    func completeSelectedBlockUsage() throws
    {
        let blocks = [
            ViewportWindowFixture.largeBlock(),
            ViewportWindowFixture.paragraph("unrelated block")
        ]
        let projection = try ViewportWindowFixture.projection(blocks)
        let layouts = try ViewportWindowFixture.layouts(
            projection: projection,
            width: 140
        )
        let first = try #require(layouts.eager.fragments.first)
        let value = try ViewportWindowFixture.product(
            projection: projection,
            width: 140,
            originY: first.frame.minY,
            height: first.frame.size.height,
            overscan: 0,
            limit: 1
        )
        let blockExtents = value.indexed.index.extents.filter
        {
            $0.anchor.blockOrdinal == 0
        }
        let selection = try #require(value.indexed.index.selection(
            expectedLineage: value.indexed.lineage,
            extents: blockExtents
        ))
        let complete = try #require(
            try value.indexed.materializationDiagnostics(
                selection: selection,
                capacity: ViewportWindowFixture.materializationCapacity()
            )
        )
        let resident = value.diagnostics.materializationUsage
        #expect(resident.reconstructedBlocks == 1)
        #expect(resident.reconstructedFragments == blockExtents.count)
        #expect(resident.materializedFragments == 1)
        #expect(Self.richUsage(resident) == Self.richUsage(complete.usage))
    }

}
