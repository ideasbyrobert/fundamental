package struct LayoutMaterializationCapacity: Equatable, Sendable
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

    package init?(
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
        let required = [
            reconstructedBlocks,
            reconstructedFragments,
            materializedFragments
        ]
        let rich = [
            glyphs,
            caretStops,
            sourceSlices,
            decorations,
            fontVariations,
            residentUTF16Units
        ]
        guard required.allSatisfy({ $0 > 0 }),
              rich.allSatisfy({ $0 >= 0 })
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
