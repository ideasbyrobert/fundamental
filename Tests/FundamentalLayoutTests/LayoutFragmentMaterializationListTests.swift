import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("list glyphs and exact source survive bounded materialization")
    func listMaterialization() throws
    {
        let blocks = try [.numbered, SemanticListKind.bulleted].flatMap
        {
            kind in
            [[], try demandingRuns()].map
            {
                SemanticBlock.listItem(SemanticListItem(kind: kind, runs: $0))
            }
        }
        let value = try product(blocks, width: 320)
        let layout = NativeTextKit2Layout()
        let selection = try #require(value.index.selection(
            expectedLineage: value.index.lineage,
            extents: value.index.extents
        ))
        let full = try diagnostics(value, extents: value.index.extents)
        try expectExact(full, product: value, extents: value.index.extents)
        expectPositiveCapacityChannels(full.usage)
        #expect(try layout.materializationDiagnostics(
            indexed: value.indexed, selection: selection,
            capacity: capacity(matching: full.usage)
        ) == full)
        for index in 0 ..< 9
        {
            #expect(try layout.materializationDiagnostics(
                indexed: value.indexed, selection: selection,
                capacity: capacity(matching: full.usage, lowering: index)
            ) == nil)
        }
        for extent in value.index.extents.reversed()
        {
            let single = try diagnostics(value, extents: [extent])
            try expectExact(single, product: value, extents: [extent])
        }
    }
}
