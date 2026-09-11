struct SpacingAdjustments: Sendable
{
    let indices: [Int]
    let amount: Double

    @MainActor
    init(_ plan: ParagraphPlannedLine) throws
    {
        let gaps = plan.metrics.gaps
        amount = plan.spacing.adjustment
        indices = gaps.map(\.index)
        let actual = plan.metrics.advance + Double(gaps.count) * amount
        guard amount.isFinite, actual.isFinite,
              abs(actual - plan.spacing.advance) < 0.000001,
              indices == indices.sorted(), Set(indices).count == indices.count,
              gaps.allSatisfy({
                  $0.advance.isFinite && $0.advance > 0
                      && amount >= -0.25 * $0.advance
                      && amount <= 0.75 * $0.advance
              }),
              plan.spacing.kind == .justified || amount == 0,
              amount == 0 || !gaps.isEmpty
        else
        {
            throw NativeSpacingFailure.invalidPlan
        }
    }

    func count(before offset: Int) -> Int
    {
        var lower = 0
        var upper = indices.count
        while lower < upper
        {
            let middle = lower + (upper - lower) / 2
            if indices[middle] < offset
            {
                lower = middle + 1
            }
            else
            {
                upper = middle
            }
        }
        return lower
    }

    func isGap(_ index: Int) -> Bool
    {
        let found = count(before: index)
        return found < indices.count && indices[found] == index
    }
}
