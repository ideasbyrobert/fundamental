import Testing

@testable import FundamentalLayout
@testable import FundamentalProjection
@testable import FundamentalViewport

extension SummitResidentLayoutWindowTests
{
    @Test("resident values and summit storage are finite exact truths")
    func vocabularyAndStorage() throws
    {
        let projection = try #require(SummitProjectionCorpus()).snapshot
        let value = try ViewportWindowFixture.product(
            projection: projection,
            width: 720,
            originY: 260,
            height: 120,
            overscan: 180,
            limit: 192
        )
        let first = try #require(ViewportResidentExtentWindow.admit(
            indexed: value.indexed,
            request: value.request
        ))
        let second = try #require(ViewportResidentExtentWindow.admit(
            indexed: value.indexed,
            request: value.request
        ))
        #expect(first == second)
        #expect(!first.all.isEmpty)
        ViewportWindowFixture.requireSendable(first)
        ViewportWindowFixture.requireSendable(value.diagnostics)
        let labels = Mirror(reflecting: first).children.compactMap(\.label)
        #expect(labels == [
            "request",
            "documentSize",
            "sourceAnchor",
            "first",
            "remaining",
            "selection",
            "query"
        ])
        try expectExactSummitStorage()
        try expectNarrowSummitStorage()
        try expectOpaqueLayoutBoundary()
        try expectVisibleAdmissionPrecedesRichWork()
    }

    private func expectExactSummitStorage() throws
    {
        let layout = try #require(SummitLayoutPreparation())
        let layoutLabels = Mirror(reflecting: layout)
            .children.compactMap(\.label)
        #expect(layoutLabels == [
            "capacity",
            "cachedMeasure",
            "cachedProjection",
            "generation",
            "executionCount"
        ])
        let viewport = SummitViewportPreparation(
            layoutPreparation: layout
        )
        let viewportLabels = Mirror(reflecting: viewport)
            .children.compactMap(\.label)
        #expect(viewportLabels == ["layoutPreparation"])
    }

    private func expectNarrowSummitStorage() throws
    {
        let layout = try ViewportWindowFixture.source(
            target: "FundamentalLayout",
            file: "SummitLayoutPreparation.swift"
        )
        #expect(!layout.contains("LayoutSnapshot"))
        #expect(!layout.contains(".layout("))
        #expect(!layout.contains("private let projection"))
        #expect(!layout.contains("cachedSnapshot"))
        let viewport = try ViewportWindowFixture.source(
            target: "FundamentalViewport",
            file: "SummitViewportPreparation.swift"
        )
        #expect(!viewport.contains("LayoutSnapshot"))
        #expect(!viewport.contains("LayoutFragmentMaterialization"))
        #expect(!viewport.contains("Int.max"))
        let windowSource = try ViewportWindowFixture.source(
            target: "FundamentalViewport",
            file: "ViewportResidentExtentWindow+Admission.swift"
        )
        #expect(!windowSource.contains(".projection"))
        #expect(!windowSource.contains(".index"))
        #expect(!windowSource.contains("index.extents"))
    }
}
