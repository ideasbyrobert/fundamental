import Foundation
import FundamentalRaster

extension PresentationComposer
{
    static func textContent(
        _ value: RasterInteractionText,
        domain: PresentationTextDomain
    ) -> PresentedTextLine?
    {
        guard let line = textLine(value),
              line.firstCaretSite.sourcePoint.domain == domain
        else
        {
            return nil
        }
        return line
    }

    static func cellLine(
        _ value: RasterInteractionText,
        blockID: UUID,
        row: Int,
        cell: Int
    ) -> PresentedTextLine?
    {
        guard row >= 0,
              cell >= 0
        else
        {
            return nil
        }
        return textContent(
            value,
            domain: .cell(blockID: blockID, row: row, cell: cell)
        )
    }

    static func tableColumn(
        _ value: RasterTableColumnGeometry
    ) -> PresentedTableColumn?
    {
        guard value.index >= 0,
              value.origin.isFinite,
              value.extent.isFinite,
              value.extent > 0
        else
        {
            return nil
        }
        return PresentedTableColumn(
            index: value.index,
            alignment: tableAlignment(value.alignment),
            origin: value.origin,
            extent: value.extent
        )
    }

    static func tableRow(
        _ value: RasterTableRowGeometry
    ) -> PresentedTableRow?
    {
        guard value.index >= 0,
              value.origin.isFinite,
              value.extent.isFinite,
              value.extent > 0
        else
        {
            return nil
        }
        return PresentedTableRow(
            index: value.index,
            origin: value.origin,
            extent: value.extent
        )
    }

    static func cellArea(
        _ value: RasterTableCellGeometry,
        row: Int,
        cell: Int
    ) -> PresentedTableCellGeometry?
    {
        guard row >= 0,
              cell >= 0,
              value.sourceRow == row,
              value.sourceCell == cell,
              value.rowTrack >= 0,
              value.columnTrack >= 0,
              value.rowSpan > 0,
              value.columnSpan > 0
        else
        {
            return nil
        }
        return PresentedTableCellGeometry(
            sourceRow: value.sourceRow,
            sourceCell: value.sourceCell,
            rowTrack: value.rowTrack,
            columnTrack: value.columnTrack,
            rowSpan: value.rowSpan,
            columnSpan: value.columnSpan,
            projectedAlignment: tableAlignment(
                value.projectedAlignment
            ),
            resolvedAlignment: tableAlignment(value.resolvedAlignment)
        )
    }

    static func tableAlignment(
        _ value: RasterTableAlignment
    ) -> PresentationTableAlignment
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
