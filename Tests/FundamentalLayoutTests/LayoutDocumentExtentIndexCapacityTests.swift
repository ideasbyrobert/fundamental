import Testing

@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    @MainActor
    @Test("every finite capacity admits its boundary and refuses one over")
    func capacityBoundary() throws
    {
        let base = try product(try mixedBlocks(), width: 360)
        let values = try measurements(
            base.projection,
            request: base.request
        )
        let exact = try factCapacity(values)
        #expect(LayoutDocumentExtentIndex(
            projection: base.projection,
            request: base.request,
            capacity: exact,
            measurements: values
        ) != nil)
        for reduced in try reducedCapacities(exact)
        {
            #expect(LayoutDocumentExtentIndex(
                projection: base.projection,
                request: base.request,
                capacity: reduced,
                measurements: values
            ) == nil)
        }
        for position in 0 ..< 5
        {
            var maxima = [1, 1, 1, 1, 1]
            maxima[position] = 0
            #expect(LayoutExtentIndexCapacity(
                maximumBlockCount: maxima[0],
                maximumExtentCount: maxima[1],
                maximumResolvedFontCount: maxima[2],
                maximumTableRowCount: maxima[3],
                maximumTableCellCount: maxima[4]
            ) == nil)
        }
    }
}
