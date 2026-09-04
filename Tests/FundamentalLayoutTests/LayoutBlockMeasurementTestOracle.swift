@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    func expectedContents(
        _ fragments: [LayoutFragment]
    ) -> [LayoutFragmentExtentContent]
    {
        fragments.map
        {
            switch $0
            {
            case let .lines(line):
                .line(line.role)
            case let .grid(grid):
                switch grid.content
                {
                case .region:
                    .tableRegion
                case .captionLine:
                    .tableCaptionLine
                case .columnTrack:
                    .tableColumnTrack
                case .rowTrack:
                    .tableRowTrack
                case .cell:
                    .tableCell
                case .cellLine:
                    .tableCellLine
                case .rule:
                    .tableRule
                }
            }
        }
    }

    func expectedContentFonts(
        _ fragments: [LayoutFragment]
    ) -> [LayoutFontIdentity]
    {
        var fonts: [LayoutFontIdentity] = []
        var seen: Set<LayoutFontIdentity> = []
        for fragment in fragments
        {
            switch fragment
            {
            case let .lines(line):
                appendExpectedFonts(
                    line.line,
                    to: &fonts,
                    seen: &seen
                )
            case let .grid(grid):
                switch grid.content
                {
                case let .captionLine(line):
                    appendExpectedFonts(line, to: &fonts, seen: &seen)
                case let .cellLine(line):
                    appendExpectedFonts(
                        line.line,
                        to: &fonts,
                        seen: &seen
                    )
                case .region, .columnTrack, .rowTrack, .cell, .rule:
                    break
                }
            }
        }
        return fonts
    }

    func appendExpectedFonts(
        _ line: LayoutLine,
        to fonts: inout [LayoutFontIdentity],
        seen: inout Set<LayoutFontIdentity>
    )
    {
        for font in [line.defaultFont] + line.glyphRuns.map(\.font)
            where seen.insert(font).inserted
        {
            fonts.append(font)
        }
    }
}
