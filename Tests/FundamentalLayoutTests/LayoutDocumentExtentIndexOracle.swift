import Testing

@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    func expectParity(
        _ index: LayoutDocumentExtentIndex,
        _ snapshot: LayoutSnapshot
    )
    {
        #expect(index.lineage == snapshot.lineage)
        #expect(index.size == snapshot.size)
        #expect(index.extents.map(\.source)
            == snapshot.fragments.map(\.source))
        #expect(index.extents.map(\.anchor)
            == snapshot.fragments.map(\.anchor))
        #expect(index.extents.map(\.frame)
            == snapshot.fragments.map(\.frame))
        #expect(index.extents.map(\.content)
            == snapshot.fragments.map(content))
    }

    func content(_ fragment: LayoutFragment) -> LayoutFragmentExtentContent
    {
        switch fragment
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

    func expectQueryParity(
        _ actual: LayoutDocumentExtentQuery,
        _ expected: LayoutFragmentQuery
    )
    {
        #expect(actual.extents.map(\.anchor)
            == expected.fragments.map(\.anchor))
        #expect(actual.extents.map(\.frame)
            == expected.fragments.map(\.frame))
        #expect(actual.extents.map(\.content)
            == expected.fragments.map(content))
        #expect(actual.hasMore == expected.hasMore)
    }
}
