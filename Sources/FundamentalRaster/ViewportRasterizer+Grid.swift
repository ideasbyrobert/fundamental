import FundamentalViewport

extension ViewportRasterizer
{
    static func appendGrid(
        _ resident: ResidentLayoutFragment,
        residentID: RasterResidentID,
        residence: RasterResidence,
        frame: RasterRectangle,
        targetBounds: RasterRectangle,
        specification: RasterSpecificationIdentity,
        ruleOwners: inout [RasterResidentID: RasterResidentID],
        accumulator: inout RasterAccumulator
    ) -> Bool
    {
        guard case let .grid(fragment) = resident.fragment
        else
        {
            return false
        }
        switch fragment.content
        {
        case .region:
            return accumulator.append(RasterInteractionRegion(
                residentID: residentID,
                residence: residence,
                role: .table,
                frame: frame,
                content: .region
            )) && appendFill(
                residentID: residentID,
                role: .tableBackground,
                bounds: frame,
                targetBounds: targetBounds,
                color: specification.palette.tableBackground,
                sourceSlices: [],
                specification: specification,
                accumulator: &accumulator
            )
        case let .columnTrack(track):
            let alignment: RasterTableAlignment
            switch track.alignment
            {
            case .leading:
                alignment = .leading
            case .center:
                alignment = .center
            case .trailing:
                alignment = .trailing
            case .unspecified:
                alignment = .unspecified
            }
            return accumulator.append(RasterInteractionRegion(
                residentID: residentID,
                residence: residence,
                role: .tableColumn(track.index),
                frame: frame,
                content: .columnTrack(RasterTableColumnGeometry(
                    index: track.index,
                    alignment: alignment,
                    origin: track.origin,
                    extent: track.extent
                ))
            ))
        case let .rowTrack(track):
            let role: RasterInteractionRole
            switch track.scope
            {
            case .header:
                role = .headerRow(track.index)
            case .body:
                role = .bodyRow(track.index)
            }
            guard accumulator.append(RasterInteractionRegion(
                residentID: residentID,
                residence: residence,
                role: role,
                frame: frame,
                content: .rowTrack(RasterTableRowGeometry(
                    index: track.index,
                    origin: track.origin,
                    extent: track.extent
                ))
            ))
            else
            {
                return false
            }
            return track.scope != .header || appendFill(
                residentID: residentID,
                role: .headerBackground,
                bounds: frame,
                targetBounds: targetBounds,
                color: specification.palette.headerBackground,
                sourceSlices: [],
                specification: specification,
                accumulator: &accumulator
            )
        case let .cell(cell):
            let projected = alignment(cell.projectedAlignment)
            let resolved = alignment(cell.resolvedAlignment)
            let role: RasterInteractionRole
            switch cell.scope
            {
            case .header:
                role = .headerCell(
                    row: cell.sourceRow,
                    cell: cell.sourceCell
                )
            case .body:
                role = .bodyCell(
                    row: cell.sourceRow,
                    cell: cell.sourceCell
                )
            }
            return accumulator.append(RasterInteractionRegion(
                residentID: residentID,
                residence: residence,
                role: role,
                frame: frame,
                content: .cell(RasterTableCellGeometry(
                    sourceRow: cell.sourceRow,
                    sourceCell: cell.sourceCell,
                    rowTrack: cell.rowTrack,
                    columnTrack: cell.columnTrack,
                    rowSpan: cell.rowSpan,
                    columnSpan: cell.columnSpan,
                    projectedAlignment: projected,
                    resolvedAlignment: resolved
                ))
            ))
        case let .rule(owner):
            guard let ownerID = Self.ownerID(
                owner,
                of: residentID,
                in: accumulator.regions
            )
            else
            {
                return false
            }
            ruleOwners[residentID] = ownerID
            return appendFill(
                residentID: ownerID,
                role: .tableRule,
                bounds: frame,
                targetBounds: targetBounds,
                color: specification.palette.rule,
                sourceSlices: [],
                specification: specification,
                accumulator: &accumulator
            )
        case .captionLine, .cellLine:
            return false
        }
    }

    private static func ownerID(
        _ owner: ResidentLayoutGridRuleOwner,
        of ruleID: RasterResidentID,
        in regions: [RasterInteractionRegion]
    ) -> RasterResidentID?
    {
        regions.first
        {
            guard $0.residentID.blockID == ruleID.blockID,
                  $0.residentID.blockOrdinal == ruleID.blockOrdinal
            else
            {
                return false
            }
            switch (owner, $0.content)
            {
            case (.table, .region):
                return $0.role == .table
            case let (.row(index), .rowTrack(row)):
                return row.index == index
            case let (.column(index), .columnTrack(column)):
                return column.index == index
            default:
                return false
            }
        }?.residentID
    }

    private static func alignment(
        _ value: ResidentTableColumnAlignment
    ) -> RasterTableAlignment
    {
        switch value
        {
        case .leading:
            .leading
        case .center:
            .center
        case .trailing:
            .trailing
        case .unspecified:
            .unspecified
        }
    }
}
