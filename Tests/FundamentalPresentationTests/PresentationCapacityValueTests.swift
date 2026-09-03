import Testing

@testable import FundamentalPresentation

extension PresentationCapacityTests
{
    @MainActor
    @Test("presentation capacities and caret width must be positive")
    func specificationBounds() throws
    {
        let raster = try makeRaster()
        let specification = try PresentationFixture.specification(raster)
        #expect(PresentationSpecificationIdentity(
            caretWidth: 0,
            adornmentPalette: specification.adornmentPalette,
            maximumSelectionFragmentCount: 1
        ) == nil)
        #expect(PresentationSpecificationIdentity(
            caretWidth: 1,
            adornmentPalette: specification.adornmentPalette,
            maximumSelectionFragmentCount: 0
        ) == nil)
    }
}
