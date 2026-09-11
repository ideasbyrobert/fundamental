@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Foundation

struct QualityReferenceLine
{
    let ragged: Int
    let fitness: Int
    let cost: Double

    static func assess(
        _ metrics: ParagraphLineMetrics, width: Double, terminal: Bool
    ) -> Self?
    {
        guard let fit = ReferenceLineAssessment.assess(
            metrics, width: width, terminal: terminal
        )
        else
        {
            return nil
        }
        let cost: Double
        if fit.ragged == 1 && !terminal
        {
            let margin = (width - metrics.advance) / (width / 10)
            cost = pow(110 + 100 * pow(margin, 3), 2)
        }
        else
        {
            cost = fit.demerits
        }
        return Self(ragged: fit.ragged, fitness: fit.fitness, cost: cost)
    }

    func appending(
        to path: QualityReferencePath, node: Int,
        previous: ParagraphBreak, next: ParagraphBreak
    ) -> QualityReferencePath
    {
        var extra = cost
        var emergency = 0
        switch next.kind
        {
        case .emergency: emergency = 1
        case .authored(_, conditional: true): extra += 100
        case .automatic: extra += 2500
        default: break
        }
        if previous.hyphenated && next.hyphenated
        {
            extra += 3000
        }
        if previous.kind.rank != 0, !next.terminal,
           abs(path.fitness - fitness) >= 2
        {
            extra += 3000
        }
        return QualityReferencePath(
            nodes: path.nodes + [node],
            emergency: path.emergency + emergency,
            ragged: path.ragged + ragged,
            demerits: path.demerits + extra, fitness: fitness
        )
    }
}
