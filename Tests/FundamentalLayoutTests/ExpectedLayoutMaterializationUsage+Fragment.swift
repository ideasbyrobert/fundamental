@testable import FundamentalLayout

extension ExpectedLayoutMaterializationUsage
{
    mutating func consume(_ fragment: LayoutFragment)
    {
        switch fragment
        {
        case let .lines(value):
            consume(value.line)
        case let .grid(value):
            switch value.content
            {
            case let .captionLine(line):
                consume(line)
            case let .cellLine(line):
                consume(line.line)
            case .region, .columnTrack, .rowTrack, .cell, .rule:
                break
            }
        }
    }

    mutating func consume(_ line: LayoutLine)
    {
        consume(line.text)
        caretStops += line.remainingCaretStops.count + 1
        consume(line.sourceSlices)
        consume(line.defaultFont)
        let generatedRuns = line.marker?.glyphRuns ?? []
        if let marker = line.marker
        {
            consume(marker.source.label)
        }
        for run in line.glyphRuns + generatedRuns
        {
            glyphs += run.remainingGlyphs.count + 1
            consume(run.font)
            consume(run.sourceSlices)
            consume(run.firstGlyph.sourceSlices)
            for glyph in run.remainingGlyphs
            {
                consume(glyph.sourceSlices)
            }
            for decoration in run.decorations
            {
                decorations += 1
                consume(decoration.sourceSlices)
            }
        }
    }
}
