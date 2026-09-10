import FundamentalViewport

extension ViewportRasterizer
{
    static func admits(
        _ viewport: ViewportSnapshot,
        targetBounds: RasterRectangle, capacities: RasterCapacities
    ) -> Bool
    {
        var budget = RasterAdmissionBudget(capacities: capacities)
        let (count, overflow) = viewport.residents.remaining.count
            .addingReportingOverflow(1)
        guard !overflow
        else
        {
            return false
        }
        for index in 0 ..< count
        {
            let resident = index == 0
                ? viewport.residents.first
                : viewport.residents.remaining[index - 1]
            guard admits(
                resident, targetBounds: targetBounds, budget: &budget
            )
            else
            {
                return false
            }
        }
        return true
    }
}
