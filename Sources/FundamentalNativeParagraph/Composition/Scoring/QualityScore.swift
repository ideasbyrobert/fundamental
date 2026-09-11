package struct QualityScore: Equatable, Comparable, Sendable
{
    package let emergency: Int
    package let demerits: Double

    package static let zero = Self(emergency: 0, demerits: 0)

    package static func < (left: Self, right: Self) -> Bool
    {
        if left.emergency != right.emergency
        {
            return left.emergency < right.emergency
        }
        return left.demerits < right.demerits
    }

    func appending(
        _ spacing: ParagraphSpacing, end: ParagraphBreak,
        previous: ParagraphBreak, fitness: ParagraphFitness
    ) throws -> Self
    {
        let next = emergency.addingReportingOverflow(end.emergency)
        let badness: Double
        if spacing.kind == .ragged && !end.terminal
        {
            let ratio = 10 * spacing.ratio
            badness = 100 + 100 * ratio * ratio * ratio
        }
        else
        {
            badness = spacing.badness
        }
        let line = 10 + badness
        var extra = line * line + end.penalty
        if end.hyphenated && previous.hyphenated
        {
            extra += 3000
        }
        if previous.kind.rank != 0, !end.terminal,
           abs(fitness.rawValue - spacing.fitness.rawValue) > 1
        {
            extra += 3000
        }
        let total = demerits + extra
        guard !next.overflow, total.isFinite
        else
        {
            throw ParagraphFailure.scoreOverflow
        }
        return Self(emergency: next.partialValue, demerits: total)
    }
}
