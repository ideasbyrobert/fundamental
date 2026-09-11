import CoreText
import FundamentalNativeWrapping
import FundamentalParagraph

extension ParagraphLineMetrics
{
    @MainActor
    init(_ measured: NativeWrappingLine, units: [UInt16]) throws
    {
        advance = measured.advance
        trailingWhitespace = measured.trailingWhitespace
        var first = 0
        while first < units.count && ParagraphWhitespace.contains(units[first])
        {
            first += 1
        }
        var last = units.count
        while last > first && ParagraphWhitespace.contains(units[last - 1])
        {
            last -= 1
        }
        var widths: [Int: Double] = [:]
        if let line = measured.native
        {
            for run in CTLineGetGlyphRuns(line) as! [CTRun]
            {
                let count = CTRunGetGlyphCount(run)
                let raw = CTRunGetStringRange(run)
                guard raw.location >= 0, raw.length >= 0,
                      raw.location <= units.count,
                      raw.length <= units.count - raw.location
                else
                {
                    throw ExplicitShapingFailure.nativeRange
                }
                var indices = [CFIndex](repeating: -1, count: count)
                var advances = [CGSize](repeating: .zero, count: count)
                let all = CFRange(location: 0, length: count)
                CTRunGetStringIndices(run, all, &indices)
                CTRunGetAdvances(run, all, &advances)
                let mapping = try NativeIndexRanges(
                    range: raw.location..<(raw.location + raw.length),
                    indices: indices, displayLength: units.count
                )
                for index in indices.indices
                {
                    let source = indices[index]
                    if source >= first, source < last, units[source] == 32,
                       mapping.ranges[index].count == 1
                    {
                        widths[source, default: 0] += advances[index].width
                    }
                }
            }
        }
        let gaps = widths.map { ParagraphGap(index: $0.key, advance: $0.value) }
            .sorted { $0.index < $1.index }
        guard gaps.allSatisfy({ $0.advance.isFinite && $0.advance > 0 })
        else
        {
            throw ParagraphFailure.invalidGap
        }
        self.gaps = gaps
    }
}
