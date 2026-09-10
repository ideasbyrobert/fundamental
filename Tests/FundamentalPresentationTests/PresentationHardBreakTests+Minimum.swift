import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationHardBreakTests
{
    @Test("a break at the trailing edge receives bounded minimum feedback",
          arguments: [false, true], [0.5, 1.0, 800.0])
    func minimum(rtl: Bool, caretWidth: Double) throws
    {
        let helpers = PresentationAdornmentTests()
        let original = try helpers.textRaster("\n", width: 300)
        let edge = rtl ? 0.0 : 300.0
        let extent = try #require(RasterSelectionExtent(
            leading: rtl ? 300 : 0, trailing: edge
        ))
        let raster = try PresentationFixture.raster(
            original, replacingFirstCaretXs: [edge, edge],
            selectionExtent: extent
        )
        let snapshot = try PresentationFixture.snapshot(raster)
        let document = snapshot.presentedDocument
        let endpoints = try helpers.endpointPositions(raster)
        let intent = try #require(PresentationTextSelection(
            anchor: endpoints.0, focus: endpoints.1
        ))
        let specification = try PresentationFixture.specification(
            raster, caretWidth: caretWidth
        )
        let selection = try #require(PresentationComposer.selection(
            intent, document: document, specification: specification
        ))
        let bounds = selection.firstFragment.logicalBounds
        #expect(bounds.size.width == min(300, caretWidth))
        #expect(bounds.minX >= 0 && bounds.maxX <= 300)
        #expect((rtl ? bounds.minX : bounds.maxX) == edge)
        #expect(selection.text == "\n")
        #expect(selection.firstFragment.range == 0 ..< 1)
    }
}
