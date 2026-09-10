import FundamentalViewport

extension ViewportRasterizer
{
    static func admits(
        _ slices: [ResidentLayoutSourceSlice],
        budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        for slice in slices
        {
            guard budget.consumeSourceSlice(slice.text)
            else
            {
                return false
            }
            for payload in slice.scopePayloads
            {
                guard budget.consumeText(payload)
                else
                {
                    return false
                }
            }
        }
        return true
    }
}
