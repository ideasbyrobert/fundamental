extension NativeTextKit2Layout
{
    func gridFragments(
        _ grid: LayoutGrid
    ) throws -> [LayoutFragment]
    {
        var fragments: [LayoutFragment] = []
        fragments.append(.grid(LayoutGridFragment(
            anchor: LayoutFragmentAnchor(
                source: grid.source,
                fragmentOrdinal: fragments.count
            ),
            source: grid.source,
            frame: grid.frame,
            content: .region
        )))
        for line in grid.captionLines
        {
            fragments.append(.grid(LayoutGridFragment(
                anchor: LayoutFragmentAnchor(
                    source: grid.source,
                    fragmentOrdinal: fragments.count
                ),
                source: grid.source,
                frame: try residencyFrame(
                    line,
                    width: grid.frame.size.width
                ),
                content: .captionLine(line)
            )))
        }
        for cell in grid.cells
        {
            fragments.append(.grid(LayoutGridFragment(
                anchor: LayoutFragmentAnchor(
                    source: grid.source,
                    fragmentOrdinal: fragments.count
                ),
                source: grid.source,
                frame: cell.frame,
                content: .cell(cell)
            )))
        }
        for line in grid.cellLines
        {
            fragments.append(.grid(LayoutGridFragment(
                anchor: LayoutFragmentAnchor(
                    source: grid.source,
                    fragmentOrdinal: fragments.count
                ),
                source: grid.source,
                frame: line.frame,
                content: .cellLine(line)
            )))
        }
        return fragments
    }
}
