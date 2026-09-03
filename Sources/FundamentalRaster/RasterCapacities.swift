package struct RasterCapacities: Equatable, Sendable
{
    package let marks: Int
    package let glyphs: Int
    package let fills: Int
    package let sourceSlices: Int
    package let caretSites: Int
    package let interactionRegions: Int
    package let fontVariations: Int
    package let residentUTF16Units: Int
    package let pixelArea: Int

    package init?(
        marks: Int,
        glyphs: Int,
        fills: Int,
        sourceSlices: Int,
        caretSites: Int,
        interactionRegions: Int,
        fontVariations: Int,
        residentUTF16Units: Int,
        pixelArea: Int
    )
    {
        let values = [
            marks,
            glyphs,
            fills,
            sourceSlices,
            caretSites,
            interactionRegions,
            fontVariations,
            residentUTF16Units,
            pixelArea
        ]
        guard values.allSatisfy({ $0 > 0 })
        else
        {
            return nil
        }
        self.marks = marks
        self.glyphs = glyphs
        self.fills = fills
        self.sourceSlices = sourceSlices
        self.caretSites = caretSites
        self.interactionRegions = interactionRegions
        self.fontVariations = fontVariations
        self.residentUTF16Units = residentUTF16Units
        self.pixelArea = pixelArea
    }
}
