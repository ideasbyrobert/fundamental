import FundamentalLayout

extension SummitViewportPreparation
{
    private static let maximumCompleteBlockFragmentCount = 100_000
    private static let maximumRichFactCount = 1_000_000
    private static let maximumResidentUTF16UnitCount = 2_000_000

    static func materializationCapacity(
        maximumResidentCount: Int
    ) -> LayoutMaterializationCapacity?
    {
        LayoutMaterializationCapacity(
            reconstructedBlocks: maximumResidentCount,
            reconstructedFragments: maximumCompleteBlockFragmentCount,
            materializedFragments: maximumResidentCount,
            glyphs: maximumRichFactCount,
            caretStops: maximumRichFactCount,
            sourceSlices: maximumRichFactCount,
            decorations: maximumRichFactCount,
            fontVariations: maximumRichFactCount,
            residentUTF16Units: maximumResidentUTF16UnitCount
        )
    }
}
