import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("exact capacity admits and every one-under channel refuses")
    func exactCapacity() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(
            runs: try demandingRuns()
        ))
        let value = try product([block, block], width: 180)
        let selection = try #require(value.index.selection(
            expectedLineage: value.index.lineage,
            extents: value.index.extents
        ))
        let layout = NativeTextKit2Layout()
        let full = try #require(layout.materializationDiagnostics(
            indexed: value.indexed,
            selection: selection,
            capacity: try generousCapacity()
        ))
        expectPositiveCapacityChannels(full.usage)
        let exact = try capacity(matching: full.usage)
        #expect(try layout.materializationDiagnostics(
            indexed: value.indexed,
            selection: selection,
            capacity: exact
        ) == full)
        for index in 0 ..< 9
        {
            let lowered = try capacity(
                matching: full.usage,
                lowering: index
            )
            #expect(try layout.materializationDiagnostics(
                indexed: value.indexed,
                selection: selection,
                capacity: lowered
            ) == nil)
        }
    }
}
