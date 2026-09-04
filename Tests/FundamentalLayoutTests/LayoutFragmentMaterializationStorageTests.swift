import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("published storage is sparse and execution has one block layout call")
    func sparseStorage() throws
    {
        let value = try product([
            longParagraph("Selected"),
            longParagraph("Unrelated")
        ], width: 130)
        let extent = try #require(value.index.extents.first)
        let result = try diagnostics(value, extents: [extent])
        let labels = Mirror(reflecting: result.materialization)
            .children.compactMap(\.label)
        #expect(labels == ["lineage", "documentSize", "fragments"])
        #expect(result.materialization.fragments.count == 1)
        let execution = try productionSource(
            "LayoutMaterializationAdmissionToken.swift"
        )
        let admission = try productionSource(
            "NativeTextKit2Layout+MaterializationAdmission.swift"
        )
        #expect(occurrences(of: "blockLayout(", in: execution) == 1)
        #expect(occurrences(
            of: "LayoutMaterializationAdmissionToken()",
            in: execution
        ) == 1)
        #expect(execution.contains(
            "reconstructedFontsAreAdmitted("
        ))
        #expect(!execution.contains("projection.blocks"))
        #expect(!execution.contains("index.extents.filter"))
        #expect(execution.contains("fileprivate init()"))
        #expect(!admission.contains("projection.blocks"))
        #expect(!admission.contains("index.extents.filter"))
        for name in [
            "LayoutMaterializedFragment.swift",
            "LayoutFragmentMaterialization.swift",
            "LayoutFragmentMaterializationDiagnostics.swift"
        ]
        {
            let source = try productionSource(name)
            #expect(source.contains(
                "LayoutMaterializationAdmissionToken"
            ))
        }
    }
}
