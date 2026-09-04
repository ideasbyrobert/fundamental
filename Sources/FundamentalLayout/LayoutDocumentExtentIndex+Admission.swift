import Foundation
import FundamentalProjection

extension LayoutDocumentExtentIndex
{
    static func matches(
        _ blocks: [ProjectedBlock],
        measurements: [LayoutBlockMeasurement]
    ) -> Bool
    {
        var blockIDs = Set<UUID>()
        for (ordinal, pair) in zip(blocks, measurements).enumerated()
        {
            let block = pair.0
            let measurement = pair.1
            guard block.source.ordinal == ordinal,
                  block == measurement.block,
                  blockIDs.insert(block.source.blockID).inserted
            else
            {
                return false
            }
        }
        return true
    }

    static func admitFacts(
        _ measurements: [LayoutBlockMeasurement],
        parameters: LayoutParameters,
        capacity: LayoutExtentIndexCapacity
    ) -> (fonts: [LayoutFontIdentity], extentCount: Int)?
    {
        var extentCount = 0
        var rowCount = 0
        var cellCount = 0
        for measurement in measurements
        {
            guard measurement.parameters == parameters,
                  let nextExtentCount = adding(
                      extentCount,
                      measurement.extents.count
                  )
            else
            {
                return nil
            }
            extentCount = nextExtentCount
            if case let .table(table) = measurement.kind
            {
                guard let nextRowCount = adding(
                    rowCount,
                    table.rowCount
                ),
                      let nextCellCount = adding(
                          cellCount,
                          table.cellCount
                      )
                else
                {
                    return nil
                }
                rowCount = nextRowCount
                cellCount = nextCellCount
            }
        }
        let fonts = resolvedFonts(measurements)
        guard extentCount <= capacity.maximumExtentCount,
              fonts.count <= capacity.maximumResolvedFontCount,
              rowCount <= capacity.maximumTableRowCount,
              cellCount <= capacity.maximumTableCellCount
        else
        {
            return nil
        }
        return (fonts, extentCount)
    }

    private static func resolvedFonts(
        _ measurements: [LayoutBlockMeasurement]
    ) -> [LayoutFontIdentity]
    {
        var fonts: [LayoutFontIdentity] = []
        var seen: Set<LayoutFontIdentity> = []
        for measurement in measurements
        {
            append(
                measurement.contentFonts,
                to: &fonts,
                seen: &seen
            )
        }
        for measurement in measurements
        {
            guard case let .table(table) = measurement.kind
            else
            {
                continue
            }
            append(
                [table.structuralFont],
                to: &fonts,
                seen: &seen
            )
        }
        return fonts
    }

    private static func append(
        _ candidates: [LayoutFontIdentity],
        to fonts: inout [LayoutFontIdentity],
        seen: inout Set<LayoutFontIdentity>
    )
    {
        for font in candidates where seen.insert(font).inserted
        {
            fonts.append(font)
        }
    }

    private static func adding(_ first: Int, _ second: Int) -> Int?
    {
        let result = first.addingReportingOverflow(second)
        return result.overflow ? nil : result.partialValue
    }
}
