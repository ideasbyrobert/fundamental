enum TerminalFailure: Error, Equatable
{
    case invalidAdvance
}

enum TerminalCost
{
    static func penalty(
        _ spacing: ParagraphSpacing, width: Double,
        end: ParagraphBreak, previous: ParagraphBreak
    ) throws -> Double
    {
        guard width.isFinite, width > 0
        else
        {
            throw ParagraphFailure.invalidWidth
        }
        guard spacing.advance.isFinite, spacing.advance >= 0
        else
        {
            throw TerminalFailure.invalidAdvance
        }
        guard case .terminal(.end) = end.kind, previous.kind.rank != 0
        else
        {
            return 0
        }
        let ratio = max(0, (0.25 - spacing.advance / width) / 0.1)
        let badness = 100 * ratio * ratio * ratio
        let line = 10 + badness
        return line * line - 100 + (previous.hyphenated ? 5000 : 0)
    }

    static func adding(
        to score: QualityScore, spacing: ParagraphSpacing, width: Double,
        end: ParagraphBreak, previous: ParagraphBreak
    ) throws -> QualityScore
    {
        let total = try score.demerits + penalty(
            spacing, width: width, end: end, previous: previous
        )
        guard total.isFinite
        else
        {
            throw ParagraphFailure.scoreOverflow
        }
        return QualityScore(emergency: score.emergency, demerits: total)
    }
}
