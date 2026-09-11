package struct ParagraphScore: Equatable, Comparable, Sendable
{
    package let emergency: Int
    package let ragged: Int
    package let demerits: Double

    package static let zero = Self(emergency: 0, ragged: 0, demerits: 0)

    package static func < (left: Self, right: Self) -> Bool
    {
        if left.emergency != right.emergency
        {
            return left.emergency < right.emergency
        }
        if left.ragged != right.ragged
        {
            return left.ragged < right.ragged
        }
        return left.demerits < right.demerits
    }

    func appending(
        _ spacing: ParagraphSpacing, end: ParagraphBreak,
        previous: ParagraphBreak, fitness: ParagraphFitness
    ) throws -> Self
    {
        let nextEmergency = emergency.addingReportingOverflow(end.emergency)
        let nextRagged = ragged.addingReportingOverflow(spacing.ragged)
        let line = 10 + spacing.badness
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
        guard !nextEmergency.overflow, !nextRagged.overflow, total.isFinite
        else
        {
            throw ParagraphFailure.scoreOverflow
        }
        return Self(
            emergency: nextEmergency.partialValue,
            ragged: nextRagged.partialValue,
            demerits: total
        )
    }
}
