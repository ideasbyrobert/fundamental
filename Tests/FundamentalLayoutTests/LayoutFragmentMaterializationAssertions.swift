import Testing

@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    func diagnostics(
        _ product: LayoutMaterializationTestProduct,
        extents: [LayoutPlacedFragmentExtent],
        capacity: LayoutMaterializationCapacity? = nil
    ) throws -> LayoutFragmentMaterializationDiagnostics
    {
        let selection = try #require(product.index.selection(
            expectedLineage: product.index.lineage,
            extents: extents
        ))
        return try #require(
            NativeTextKit2Layout().materializationDiagnostics(
                indexed: product.indexed,
                selection: selection,
                capacity: try capacity ?? generousCapacity()
            )
        )
    }

    func expectExact(
        _ result: LayoutFragmentMaterializationDiagnostics,
        product: LayoutMaterializationTestProduct,
        extents: [LayoutPlacedFragmentExtent]
    ) throws
    {
        let ordered = product.index.extents.filter(extents.contains)
        let anchors = Set(ordered.map(\.anchor))
        let eager = product.eager.fragments.filter
        {
            anchors.contains($0.anchor)
        }
        #expect(result.materialization.lineage == product.index.lineage)
        #expect(result.materialization.documentSize == product.index.size)
        #expect(result.materialization.fragments.map(\.extent) == ordered)
        #expect(result.materialization.fragments.map(\.fragment) == eager)
        let expected = ExpectedLayoutMaterializationUsage(
            snapshot: product.eager,
            selectedExtents: ordered
        )
        let expectedUsage = try expected.admitted()
        #expect(result.usage == expectedUsage)
    }
}
