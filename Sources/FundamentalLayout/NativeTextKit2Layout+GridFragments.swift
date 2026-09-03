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
        let rowOrigin = grid.rowTracks.first?.origin
            ?? grid.captionLines.map(\.frame.maxY).max()
            ?? grid.frame.minY
        let rowMaximumY = grid.rowTracks.last.map
        {
            $0.origin + $0.extent
        } ?? grid.frame.maxY
        for track in grid.rowTracks
        {
            fragments.append(.grid(LayoutGridFragment(
                anchor: LayoutFragmentAnchor(
                    source: grid.source,
                    fragmentOrdinal: fragments.count
                ),
                source: grid.source,
                frame: try rectangle(
                    x: grid.frame.minX,
                    y: track.origin,
                    width: grid.frame.size.width,
                    height: track.extent
                ),
                content: .rowTrack(track)
            )))
        }
        for track in grid.columnTracks
        {
            fragments.append(.grid(LayoutGridFragment(
                anchor: LayoutFragmentAnchor(
                    source: grid.source,
                    fragmentOrdinal: fragments.count
                ),
                source: grid.source,
                frame: try rectangle(
                    x: grid.frame.minX + track.origin,
                    y: rowOrigin,
                    width: track.extent,
                    height: rowMaximumY - rowOrigin
                ),
                content: .columnTrack(track)
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
        for rule in try gridRules(grid)
        {
            fragments.append(.grid(LayoutGridFragment(
                anchor: LayoutFragmentAnchor(
                    source: grid.source,
                    fragmentOrdinal: fragments.count
                ),
                source: grid.source,
                frame: rule.frame,
                content: .rule(rule.owner)
            )))
        }
        return fragments
    }
}
