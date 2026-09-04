extension LayoutFragmentExtent
{
    init(_ fragment: LayoutFragment)
    {
        let content: LayoutFragmentExtentContent
        switch fragment
        {
        case let .lines(line):
            content = .line(line.role)
        case let .grid(grid):
            switch grid.content
            {
            case .region:
                content = .tableRegion
            case .captionLine:
                content = .tableCaptionLine
            case .columnTrack:
                content = .tableColumnTrack
            case .rowTrack:
                content = .tableRowTrack
            case .cell:
                content = .tableCell
            case .cellLine:
                content = .tableCellLine
            case .rule:
                content = .tableRule
            }
        }
        self.init(
            source: fragment.source,
            anchor: fragment.anchor,
            frame: fragment.frame,
            content: content
        )
    }
}
