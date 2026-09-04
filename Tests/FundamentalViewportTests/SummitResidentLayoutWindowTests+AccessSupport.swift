import Testing

extension SummitResidentLayoutWindowTests
{
    func expectOpaqueLayoutBoundary() throws
    {
        let pair = try ViewportWindowFixture.source(
            target: "FundamentalLayout",
            file: "LayoutIndexedProjection.swift"
        )
        #expect(pair.contains("package struct LayoutIndexedProjection"))
        #expect(!pair.contains("package let projection"))
        #expect(!pair.contains("package let index"))
        let index = try ViewportWindowFixture.source(
            target: "FundamentalLayout",
            file: "LayoutDocumentExtentIndex.swift"
        )
        #expect(!index.contains(
            "package struct LayoutDocumentExtentIndex"
        ))
        let extent = try ViewportWindowFixture.source(
            target: "FundamentalLayout",
            file: "LayoutFragmentExtent.swift"
        )
        #expect(!extent.contains("package struct LayoutFragmentExtent"))
        let engine = try ViewportWindowFixture.source(
            target: "FundamentalLayout",
            file: "NativeTextKit2Layout.swift"
        )
        #expect(!engine.contains("package final class"))
        #expect(!engine.contains("package struct NativeTextKit2Layout"))
        try expectExactLayoutFacade()
    }

    private func expectExactLayoutFacade() throws
    {
        let facade = try ViewportWindowFixture.source(
            target: "FundamentalLayout",
            file: "LayoutIndexedProjection+Viewport.swift"
        )
        let packageDeclarations = facade.split(separator: "\n").map
        {
            $0.trimmingCharacters(in: .whitespaces)
        }.filter
        {
            $0.hasPrefix("package ")
        }
        #expect(packageDeclarations == [
            "package var lineage: LayoutLineage",
            "package var documentSize: LayoutSize",
            "package func queryDiagnostics(",
            "package func selection(",
            "package func materializationDiagnostics("
        ])
        #expect(!facade.contains("package var projection"))
        #expect(!facade.contains("package var index"))
        #expect(!facade.contains("package var extents"))
    }

    func expectVisibleAdmissionPrecedesRichWork() throws
    {
        let window = try ViewportWindowFixture.source(
            target: "FundamentalViewport",
            file: "ViewportResidentExtentWindow+Admission.swift"
        )
        let complete = try #require(window.range(
            of: "guard !visibleDiagnostics.query.hasMore"
        ))
        let overscan = try #require(window.range(of: "let preceding"))
        #expect(complete.lowerBound < overscan.lowerBound)
        let route = try ViewportWindowFixture.source(
            target: "FundamentalViewport",
            file: "ViewportWindowAdmissionDiagnostics.swift"
        )
        let extentAdmission = try #require(route.range(
            of: "ViewportResidentExtentWindow.admit("
        ))
        let richAdmission = try #require(route.range(
            of: "indexed.materializationDiagnostics("
        ))
        #expect(extentAdmission.lowerBound < richAdmission.lowerBound)
    }
}
