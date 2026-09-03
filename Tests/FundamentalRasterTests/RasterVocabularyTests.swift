import Testing

@testable import FundamentalRaster

@Suite("Raster vocabulary")
struct RasterVocabularyTests
{
    @Test("appearance names only produced native facts")
    func appearance() async
    {
        let values = [
            RasterAppearance(luminosity: .light, contrast: .standard),
            RasterAppearance(luminosity: .light, contrast: .increased),
            RasterAppearance(luminosity: .dark, contrast: .standard),
            RasterAppearance(luminosity: .dark, contrast: .increased)
        ]
        #expect(values.count == 4)
        #expect(values[0] != values[1])
        await acceptsSendable(values)
    }

    @Test("resolved colors require exact concrete profile facts")
    func color() throws
    {
        let space = try RasterFixture.colorSpace()
        #expect(RasterColorSpaceIdentity(
            name: " ",
            profile: [1],
            componentCount: 3
        ) == nil)
        #expect(RasterColor(
            colorSpace: space,
            components: [0, 0],
            alpha: 1
        ) == nil)
        #expect(RasterColor(
            colorSpace: space,
            components: [0, 0, 2],
            alpha: 1
        ) == nil)
    }

    @Test("every registered capacity is positive")
    func positiveCapacities()
    {
        #expect(RasterCapacities(
            marks: 0,
            glyphs: 1,
            fills: 1,
            sourceSlices: 1,
            caretSites: 1,
            interactionRegions: 1,
            fontVariations: 1,
            residentUTF16Units: 1,
            pixelArea: 1
        ) == nil)
        #expect(RasterCapacities(
            marks: 1,
            glyphs: 1,
            fills: 1,
            sourceSlices: 1,
            caretSites: 1,
            interactionRegions: 1,
            fontVariations: 1,
            residentUTF16Units: 1,
            pixelArea: 0
        ) == nil)
    }

    private func acceptsSendable<T: Sendable>(_ value: T) async
    {
        _ = await Task { value }.value
    }
}
