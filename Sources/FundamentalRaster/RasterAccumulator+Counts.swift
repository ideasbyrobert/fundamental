extension RasterAccumulator
{
    func sourceSliceCount(
        _ slices: [RasterSourceSlice],
        startingAt count: Int
    ) -> Int?
    {
        adding(count, slices.count)
    }

    func adding(_ first: Int, _ second: Int) -> Int?
    {
        let (value, overflow) = first.addingReportingOverflow(second)
        return overflow ? nil : value
    }
}
