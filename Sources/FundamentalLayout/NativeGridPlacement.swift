import FundamentalProjection

struct NativeGridPlacement
{
    let scope: LayoutTableRowScope
    let sourceRow: Int
    let sourceCell: Int
    let rowTrack: Int
    let columnTrack: Int
    let rowSpan: Int
    let columnSpan: Int
    let alignment: ProjectedTableColumnAlignment
    let runs: [ProjectedRun]
}
