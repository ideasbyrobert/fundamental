@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    func tableFacts(
        _ measurement: LayoutBlockMeasurement
    ) -> LayoutTableMeasurement?
    {
        guard case let .table(table) = measurement.kind
        else
        {
            return nil
        }
        return table
    }

    func resolvedFonts(
        _ measurements: [LayoutBlockMeasurement]
    ) -> [LayoutFontIdentity]
    {
        var result: [LayoutFontIdentity] = []
        var seen: Set<LayoutFontIdentity> = []
        for measurement in measurements
        {
            append(measurement.contentFonts, to: &result, seen: &seen)
        }
        for measurement in measurements
        {
            if case let .table(table) = measurement.kind
            {
                append([table.structuralFont], to: &result, seen: &seen)
            }
        }
        return result
    }

    private func append(
        _ candidates: [LayoutFontIdentity],
        to result: inout [LayoutFontIdentity],
        seen: inout Set<LayoutFontIdentity>
    )
    {
        for candidate in candidates where seen.insert(candidate).inserted
        {
            result.append(candidate)
        }
    }
}
