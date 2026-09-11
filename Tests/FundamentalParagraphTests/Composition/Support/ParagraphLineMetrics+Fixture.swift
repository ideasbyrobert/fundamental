@testable import FundamentalNativeParagraph
extension ParagraphLineMetrics
{
    init(advance: Double, gapWidths: [Double])
    {
        self.init(
            advance: advance, trailingWhitespace: 0,
            gaps: gapWidths.enumerated().map
            {
                ParagraphGap(index: $0.offset, advance: $0.element)
            }
        )
    }
}
