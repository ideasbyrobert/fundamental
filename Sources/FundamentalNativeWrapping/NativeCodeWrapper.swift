import CoreText
import FundamentalWrapping

@MainActor
struct NativeCodeWrapper
{
    let text: NativeWrappingText
    let width: Double
    let unit: Double
    let typesetter: CTTypesetter
    let opportunities: CodeWrappingOpportunities
    var measuredFragments = 0

    init(text: NativeWrappingText, width: Double, unit: Double)
    {
        self.text = text
        self.width = width
        self.unit = unit
        typesetter = CTTypesetterCreateWithAttributedString(text.attributed)
        opportunities = CodeWrappingOpportunities(text.source)
    }

    mutating func wrap() -> NativeCodeWrapping?
    {
        var choices: [WrappingLineChoice] = []
        var lines: [NativeWrappingLine] = []
        for sourceLine in text.source.lines
        {
            guard let continuation = indentation(for: sourceLine)
            else
            {
                return nil
            }
            var start = sourceLine.range.lowerBound
            repeat
            {
                let inset = start == sourceLine.range.lowerBound
                    ? 0 : continuation
                guard let measured = fit(start, in: sourceLine, inset: inset)
                    ?? (inset > 0 ? fit(start, in: sourceLine, inset: 0) : nil)
                else
                {
                    return nil
                }
                let end = measured.range.upperBound
                let kind: WrappingLineBreak
                if end == sourceLine.range.upperBound
                {
                    kind = sourceLine.ending.map { .hard($0) } ?? .end
                }
                else
                {
                    kind = opportunities.priorities[end] == nil
                        ? .emergency : .soft
                }
                choices.append(WrappingLineChoice(
                    range: measured.range,
                    indentation: measured.inlineOffset,
                    advance: measured.advance, breakKind: kind
                ))
                lines.append(measured)
                start = end
            }
            while start < sourceLine.range.upperBound
        }
        guard let plan = WrappingPlan(
            source: text.source, width: width, lines: choices
        )
        else
        {
            return nil
        }
        return NativeCodeWrapping(
            plan: plan, lines: lines, measuredFragments: measuredFragments
        )
    }
}
