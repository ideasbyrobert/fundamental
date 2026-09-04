import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    func expectExactIndexedPairing() throws
    {
        let first = try product([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("AAAA")
            ]))
        ])
        let second = try product([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("BBBB")
            ]))
        ])
        #expect(first.index == second.index)
        #expect(first.eager.fragments != second.eager.fragments)
        let selection = try #require(first.index.selection(
            expectedLineage: first.index.lineage,
            extents: first.index.extents
        ))
        let result = try #require(
            NativeTextKit2Layout().materialize(
                indexed: second.indexed,
                selection: selection,
                capacity: try generousCapacity()
            )
        )
        #expect(result.fragments.map(\.fragment)
            == second.eager.fragments)
        #expect(result.fragments.map(\.fragment)
            != first.eager.fragments)
        let source = try productionSource(
            "LayoutIndexedProjection.swift"
        )
        #expect(source.contains("fileprivate init?("))
        #expect(source.contains("let measurements = try blocks.map"))
        #expect(source.contains("measurements: measurements"))
    }
}
