import FundamentalProjection

struct LayoutBlockMeasurement: Equatable, Sendable
{
    let block: ProjectedBlock
    let parameters: LayoutParameters
    let kind: LayoutBlockMeasurementKind
    let firstExtent: LayoutFragmentExtent
    let remainingExtents: [LayoutFragmentExtent]
    let contentFonts: [LayoutFontIdentity]

    var source: ProjectedBlockSource
    {
        block.source
    }

    var extents: [LayoutFragmentExtent]
    {
        [firstExtent] + remainingExtents
    }

    var resolvedFonts: [LayoutFontIdentity]
    {
        switch kind
        {
        case .prose, .code:
            contentFonts
        case let .table(table):
            if contentFonts.contains(table.structuralFont)
            {
                contentFonts
            }
            else
            {
                contentFonts + [table.structuralFont]
            }
        }
    }

    init?(
        block: ProjectedBlock,
        parameters: LayoutParameters,
        kind: LayoutBlockMeasurementKind,
        firstExtent: LayoutFragmentExtent,
        remainingExtents: [LayoutFragmentExtent],
        contentFonts: [LayoutFontIdentity]
    )
    {
        let source = block.source
        let extents = [firstExtent] + remainingExtents
        guard extents.allSatisfy(
            { $0.source == source }
        ),
              extents.allSatisfy(
                  { $0.anchor.blockID == source.blockID }
              ),
              extents.allSatisfy(
                  { $0.anchor.blockOrdinal == source.ordinal }
              ),
              extents.map(\.anchor.fragmentOrdinal)
                == Array(extents.indices),
              Set(contentFonts).count == contentFonts.count,
              firstExtent.frame.minX == 0,
              firstExtent.frame.minY == 0,
              Self.matches(
                  block: block,
                  kind: kind,
                  extents: extents
              ),
              Self.matches(
                  kind: kind,
                  extents: extents,
                  contentFonts: contentFonts,
                  parameters: parameters
              )
        else
        {
            return nil
        }
        self.block = block
        self.parameters = parameters
        self.kind = kind
        self.firstExtent = firstExtent
        self.remainingExtents = remainingExtents
        self.contentFonts = contentFonts
    }

    private static func matches(
        block: ProjectedBlock,
        kind: LayoutBlockMeasurementKind,
        extents: [LayoutFragmentExtent]
    ) -> Bool
    {
        switch (block, kind)
        {
        case let (.prose(_, prose), .prose(role)):
            return prose.role == role
        case (.code, .code):
            return true
        case let (.table(_, record), .table(table)):
            return matches(
                table: record.table,
                measurement: table,
                extents: extents
            )
        case (.prose, .code), (.prose, .table),
             (.code, .prose), (.code, .table),
             (.table, .prose), (.table, .code):
            return false
        }
    }

    private static func matches(
        table: ProjectedTable,
        measurement: LayoutTableMeasurement,
        extents: [LayoutFragmentExtent]
    ) -> Bool
    {
        let content = table.content
        let rows = content.headerRows + content.bodyRows
        let rowCount = content.headerRows.count.addingReportingOverflow(
            content.bodyRows.count
        )
        guard !rowCount.overflow
        else
        {
            return false
        }
        var cellCount = 0
        for row in rows
        {
            let next = cellCount.addingReportingOverflow(row.cells.count)
            guard !next.overflow
            else
            {
                return false
            }
            cellCount = next.partialValue
        }
        let expectsCaption: Bool
        switch table
        {
        case .regular:
            expectsCaption = false
        case .captioned:
            expectsCaption = true
        }
        let hasCaption = extents.contains
        {
            $0.content == .tableCaptionLine
        }
        return expectsCaption == hasCaption
            && rowCount.partialValue == measurement.rowCount
            && cellCount == measurement.cellCount
    }

    private static func matches(
        kind: LayoutBlockMeasurementKind,
        extents: [LayoutFragmentExtent],
        contentFonts: [LayoutFontIdentity],
        parameters: LayoutParameters
    ) -> Bool
    {
        switch kind
        {
        case let .prose(role):
            return !contentFonts.isEmpty && extents.allSatisfy
            {
                $0.content == .line(.prose(role))
                    && $0.frame.minX == 0
                    && $0.frame.minY >= 0
                    && $0.frame.size.width == parameters.width
            }
        case .code:
            return !contentFonts.isEmpty && extents.allSatisfy
            {
                $0.content == .line(.code)
                    && $0.frame.minX == 0
                    && $0.frame.minY >= 0
                    && $0.frame.size.width == parameters.width
            }
        case let .table(table):
            let regionCount = extents.filter
            {
                $0.content == .tableRegion
            }.count
            let rowCount = extents.filter
            {
                $0.content == .tableRowTrack
            }.count
            let cellCount = extents.filter
            {
                $0.content == .tableCell
            }.count
            let hasContent = extents.contains
            {
                $0.content == .tableCaptionLine
                    || $0.content == .tableCellLine
            }
            let region = extents[0].frame
            return extents.first?.content == .tableRegion
                && regionCount == 1
                && region.size.width >= parameters.width
                && extents.allSatisfy(\.content.isTableContent)
                && extents.allSatisfy
                {
                    Self.contains(region, $0.frame)
                }
                && rowCount == table.rowCount
                && cellCount == table.cellCount
                && (hasContent
                    ? !contentFonts.isEmpty
                    : contentFonts.isEmpty)
        }
    }

    private static func contains(
        _ outer: LayoutRectangle,
        _ inner: LayoutRectangle
    ) -> Bool
    {
        inner.minX >= outer.minX
            && inner.minY >= outer.minY
            && inner.maxX <= outer.maxX
            && inner.maxY <= outer.maxY
    }
}
