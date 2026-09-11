@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Foundation

struct ReferenceLineAssessment
{
    let ragged: Int
    let fitness: Int
    let demerits: Double

    static func assess(
        _ metrics: ParagraphLineMetrics, width: Double, terminal: Bool
    ) -> Self?
    {
        if metrics.advance == width || (terminal && metrics.advance <= width)
        {
            return Self(ragged: 0, fitness: 1, demerits: 100)
        }
        let difference = width - metrics.advance
        let spaceWidths = metrics.gaps.map(\.advance)
        if let smallest = spaceWidths.min(), smallest > 0
        {
            let fraction = difference
                / Double(spaceWidths.count) / smallest
            if fraction >= -0.25 && fraction <= 0.75
            {
                let normalized = fraction >= 0 ? fraction / 0.75
                    : fraction / 0.25
                let fitness: Int
                switch normalized
                {
                case ..<(-0.5): fitness = 0
                case ...0.5: fitness = 1
                case ...0.8: fitness = 2
                default: fitness = 3
                }
                let badness = 100 * pow(abs(normalized), 3)
                return Self(ragged: 0, fitness: fitness,
                            demerits: pow(10 + badness, 2))
            }
        }
        if metrics.advance <= width
        {
            let badness = 100 * pow(difference / width, 3)
            return Self(ragged: 1, fitness: 4,
                        demerits: pow(10 + badness, 2))
        }
        return nil
    }

    func extending(
        _ score: ParagraphScore, previousFitness: Int,
        previous: ParagraphBreak, next: ParagraphBreak
    ) -> ParagraphScore
    {
        let emergency: Int
        if case .emergency = next.kind
        {
            emergency = 1
        }
        else
        {
            emergency = 0
        }
        var extra = demerits
        switch next.kind
        {
        case .authored(_, conditional: true): extra += 100
        case .automatic: extra += 2500
        default: break
        }
        if previous.hyphenated && next.hyphenated
        {
            extra += 3000
        }
        if previous.kind.rank != 0, !next.terminal,
           abs(previousFitness - fitness) >= 2
        {
            extra += 3000
        }
        return ParagraphScore(
            emergency: score.emergency + emergency,
            ragged: score.ragged + ragged,
            demerits: score.demerits + extra
        )
    }
}
