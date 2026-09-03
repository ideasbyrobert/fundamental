import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationAdornmentTests
{
    func rasterText(
        _ raster: RasterSnapshot
    ) throws -> RasterInteractionText
    {
        guard case let .text(text) = raster.interactionMap
            .firstRegion.content
        else
        {
            throw PresentationTestError.missingSelection
        }
        return text
    }

    @MainActor
    func endpointPositions(
        _ raster: RasterSnapshot
    ) throws -> (PresentationTextPosition, PresentationTextPosition)
    {
        let snapshot = try PresentationFixture.snapshot(raster)
        let pair = try #require(
            PresentationFixture.textResidents(snapshot).first
        )
        let first = try PresentationFixture.position(
            pair.0,
            line: pair.1,
            caret: 0
        )
        let last = try PresentationFixture.position(
            pair.0,
            line: pair.1,
            caret: pair.1.caretSites.count - 1
        )
        return (first, last)
    }

    @MainActor
    func expectSelectionRefusal(
        _ raster: RasterSnapshot
    ) throws
    {
        let endpoints = try endpointPositions(raster)
        let selection = try #require(PresentationTextSelection(
            anchor: endpoints.0,
            focus: endpoints.1
        ))
        #expect(PresentationComposer().present(
            raster,
            request: try PresentationFixture.request(
                raster,
                intent: .selection(selection)
            )
        ) == nil)
    }
}
