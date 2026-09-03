import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationAdornmentTests
{
    @MainActor
    func textRaster(
        _ text: String,
        width: Double
    ) throws -> RasterSnapshot
    {
        try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run(text)
                    ]))
                ], width: width)
            )
        )
    }

    @MainActor
    func selection(
        _ raster: RasterSnapshot,
        anchor: PresentationTextPosition,
        focus: PresentationTextPosition,
        capacity: Int = 100
    ) throws -> PresentationSelectionAdornment
    {
        let value = try #require(PresentationTextSelection(
            anchor: anchor,
            focus: focus
        ))
        let snapshot = try PresentationFixture.snapshot(
            raster,
            intent: .selection(value),
            selectionCapacity: capacity
        )
        guard case let .selection(_, adornment) = snapshot
        else
        {
            Issue.record("expected a selection snapshot")
            throw PresentationTestError.missingSelection
        }
        return adornment
    }
}

enum PresentationTestError: Error
{
    case missingSelection
}
