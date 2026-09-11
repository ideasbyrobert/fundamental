import FundamentalParagraph
@MainActor
package struct ParagraphPlannedLine
{
    package let sourceRange: Range<Int>
    package let tail: [WordRunFragment]
    package let ending: ParagraphBreak
    package let shaped: HyphenatedShapedLine
    package let metrics: ParagraphLineMetrics
    package let spacing: ParagraphSpacing
}
