@testable import FundamentalLayout

extension SummitResidentLayoutWindowTests
{
    static func richUsage(
        _ value: LayoutMaterializationUsage
    ) -> [Int]
    {
        [
            value.glyphs,
            value.caretStops,
            value.sourceSlices,
            value.decorations,
            value.fontVariations,
            value.residentUTF16Units
        ]
    }
}
