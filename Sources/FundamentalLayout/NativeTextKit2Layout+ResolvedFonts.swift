extension NativeTextKit2Layout
{
    func resolvedFonts(
        in fragments: [LayoutFragment],
        grids: [LayoutGrid]
    ) -> [LayoutFontIdentity]
    {
        var fonts = resolvedContentFonts(in: fragments)
        var seen = Set(fonts)
        for grid in grids where seen.insert(grid.structuralFont).inserted
        {
            fonts.append(grid.structuralFont)
        }
        return fonts
    }

    func resolvedContentFonts(
        in fragments: [LayoutFragment]
    ) -> [LayoutFontIdentity]
    {
        var fonts: [LayoutFontIdentity] = []
        var seen: Set<LayoutFontIdentity> = []
        for fragment in fragments
        {
            switch fragment
            {
            case let .lines(fragment):
                appendFonts(
                    of: fragment.line,
                    to: &fonts,
                    seen: &seen
                )
            case let .grid(fragment):
                switch fragment.content
                {
                case .region:
                    break
                case let .captionLine(line):
                    appendFonts(of: line, to: &fonts, seen: &seen)
                case .columnTrack, .rowTrack, .rule:
                    break
                case .cell:
                    break
                case let .cellLine(gridLine):
                    appendFonts(
                        of: gridLine.line,
                        to: &fonts,
                        seen: &seen
                    )
                }
            }
        }
        return fonts
    }

    func appendFonts(
        of line: LayoutLine,
        to fonts: inout [LayoutFontIdentity],
        seen: inout Set<LayoutFontIdentity>
    )
    {
        let candidates = [line.defaultFont]
            + line.glyphRuns.map(\.font)
            + (line.marker?.glyphRuns.map(\.font) ?? [])
        for font in candidates where seen.insert(font).inserted
        {
            fonts.append(font)
        }
    }
}
