import Testing

@testable import FundamentalLayout
@testable import FundamentalProjection
@testable import FundamentalViewport

extension SummitResidentLayoutWindowTests
{
    @Test("far same-measure scrolls reuse one exact index")
    func sameMeasureScrollReuse() throws
    {
        let layout = try #require(SummitLayoutPreparation())
        let preparation = SummitViewportPreparation(
            layoutPreparation: layout
        )
        let indexed = try #require(layout.indexedProjection(
            readableMeasure: 720
        ))
        let near = try #require(preparation.viewport(
            generation: 1,
            readableMeasure: 720,
            visibleOriginY: 0,
            visibleHeight: 180,
            overscanExtent: 120,
            maximumResidentCount: 192
        ))
        let far = try #require(preparation.viewport(
            generation: 2,
            readableMeasure: 720,
            visibleOriginY: .greatestFiniteMagnitude,
            visibleHeight: 180,
            overscanExtent: 120,
            maximumResidentCount: 192
        ))
        #expect(near.sourceAnchor != far.sourceAnchor)
        #expect(layout.executionCount == 1)
        #expect(layout.indexedProjection(readableMeasure: 720) == indexed)
    }

    @Test("changed measure replaces once after atomic refusal")
    func changedMeasureReplacement() throws
    {
        let projection = try ViewportWindowFixture.projection([
            ViewportWindowFixture.largeBlock()
        ])
        let initial = try ViewportWindowFixture.layouts(
            projection: projection,
            width: 320
        ).indexed
        let narrow = try ViewportWindowFixture.layouts(
            projection: projection,
            width: 120
        ).indexed
        #expect(narrow.index.extents.count > initial.index.extents.count)
        let capacity = try #require(LayoutExtentIndexCapacity(
            maximumBlockCount: 4,
            maximumExtentCount: initial.index.extents.count,
            maximumResolvedFontCount: 100,
            maximumTableRowCount: 1,
            maximumTableCellCount: 1
        ))
        let preparation = try #require(SummitLayoutPreparation(
            projection: projection,
            initialMeasure: 320,
            capacity: capacity
        ))
        let admitted = try #require(preparation.indexedProjection(
            readableMeasure: 320
        ))
        let viewport = SummitViewportPreparation(
            layoutPreparation: preparation
        )
        #expect(viewport.viewport(
            generation: 1,
            readableMeasure: 500,
            visibleOriginY: 0,
            visibleHeight: 0,
            overscanExtent: 0,
            maximumResidentCount: 8
        ) == nil)
        #expect(preparation.executionCount == 1)
        #expect(preparation.indexedProjection(
            readableMeasure: 120
        ) == nil)
        #expect(preparation.executionCount == 1)
        #expect(preparation.indexedProjection(
            readableMeasure: 320
        ) == admitted)
        let replacement = try #require(preparation.indexedProjection(
            readableMeasure: 720
        ))
        #expect(replacement != admitted)
        #expect(preparation.executionCount == 2)
        #expect(preparation.indexedProjection(
            readableMeasure: 720
        ) == replacement)
        #expect(preparation.executionCount == 2)
    }
}
