import FundamentalViewport

extension ViewportRasterizer
{
    static func residence(
        _ residence: ViewportResidence
    ) -> RasterResidence
    {
        switch residence
        {
        case .visible:
            .visible
        case .overscan(.preceding):
            .overscan(.preceding)
        case .overscan(.following):
            .overscan(.following)
        }
    }

    static func role(_ role: ResidentLayoutLineRole)
        -> RasterInteractionRole?
    {
        switch role
        {
        case let .prose(.bulleted(position)):
            RasterListPosition(index: position.index, count: position.count)
                .map(RasterInteractionRole.bulleted)
        case let .prose(.numbered(position)):
            RasterListPosition(index: position.index, count: position.count)
                .map(RasterInteractionRole.numbered)
        case .prose(.body):
            .body
        case .prose(.title):
            .title
        case .prose(.section(.one)):
            .section(.one)
        case .prose(.section(.two)):
            .section(.two)
        case .prose(.section(.three)):
            .section(.three)
        case .prose(.section(.four)):
            .section(.four)
        case .prose(.section(.five)):
            .section(.five)
        case .prose(.section(.six)):
            .section(.six)
        case .code:
            .code
        }
    }

    static func role(_ line: ResidentLayoutGridLine)
        -> RasterInteractionRole
    {
        switch line.scope
        {
        case .header:
            .headerCell(row: line.sourceRow, cell: line.sourceCell)
        case .body:
            .bodyCell(row: line.sourceRow, cell: line.sourceCell)
        }
    }
}
