import FundamentalProjection

extension NativeTextKit2Layout
{
    func proseFragments(
        lines: [LayoutLine],
        source: ProjectedBlockSource,
        role: ProjectedProseRole,
        width: Double
    ) throws -> [LayoutFragment]
    {
        try lines.enumerated().map
        {
            index, line in
            .lines(LayoutLineFragment(
                anchor: LayoutFragmentAnchor(
                    source: source,
                    fragmentOrdinal: index
                ),
                source: source,
                role: .prose(role),
                frame: try residencyFrame(line, width: width),
                line: line
            ))
        }
    }

    func codeFragments(
        lines: [LayoutLine],
        source: ProjectedBlockSource,
        width: Double
    ) throws -> [LayoutFragment]
    {
        try lines.enumerated().map
        {
            index, line in
            .lines(LayoutLineFragment(
                anchor: LayoutFragmentAnchor(
                    source: source,
                    fragmentOrdinal: index
                ),
                source: source,
                role: .code,
                frame: try residencyFrame(line, width: width),
                line: line
            ))
        }
    }

    func residencyFrame(
        _ line: LayoutLine,
        x: Double = 0,
        width: Double
    ) throws -> LayoutRectangle
    {
        try rectangle(
            x: x,
            y: line.frame.minY,
            width: width,
            height: line.frame.size.height
        )
    }
}
