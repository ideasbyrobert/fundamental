package struct LayoutMaterializationUsage: Equatable, Sendable
{
    let reconstructedBlocks: Int
    let reconstructedFragments: Int
    let materializedFragments: Int
    let glyphs: Int
    let caretStops: Int
    let sourceSlices: Int
    let decorations: Int
    let fontVariations: Int
    let residentUTF16Units: Int

    init?(
        reconstructedBlocks: Int,
        reconstructedFragments: Int,
        materializedFragments: Int,
        glyphs: Int,
        caretStops: Int,
        sourceSlices: Int,
        decorations: Int,
        fontVariations: Int,
        residentUTF16Units: Int
    )
    {
        guard reconstructedBlocks > 0,
              reconstructedFragments > 0,
              materializedFragments > 0,
              glyphs >= 0,
              caretStops >= 0,
              sourceSlices >= 0,
              decorations >= 0,
              fontVariations >= 0,
              residentUTF16Units >= 0
        else
        {
            return nil
        }
        self.reconstructedBlocks = reconstructedBlocks
        self.reconstructedFragments = reconstructedFragments
        self.materializedFragments = materializedFragments
        self.glyphs = glyphs
        self.caretStops = caretStops
        self.sourceSlices = sourceSlices
        self.decorations = decorations
        self.fontVariations = fontVariations
        self.residentUTF16Units = residentUTF16Units
    }
}
