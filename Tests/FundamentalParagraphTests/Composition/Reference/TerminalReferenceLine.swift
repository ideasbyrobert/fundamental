@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Foundation

struct TerminalReferenceLine
{
    let base: QualityReferenceLine
    let advance: Double
    let width: Double

    static func assess(
        _ metrics: ParagraphLineMetrics, width: Double, terminal: Bool
    ) -> Self?
    {
        guard let base = QualityReferenceLine.assess(
            metrics, width: width, terminal: terminal
        )
        else
        {
            return nil
        }
        return Self(base: base, advance: metrics.advance, width: width)
    }

    func appending(
        to path: QualityReferencePath, node: Int,
        previous: ParagraphBreak, next: ParagraphBreak
    ) -> QualityReferencePath
    {
        let result = base.appending(
            to: path, node: node, previous: previous, next: next
        )
        if case .start = previous.kind
        {
            return result
        }
        return addingTerminalCost(to: result, previous: previous, next: next)
    }

    private func addingTerminalCost(
        to path: QualityReferencePath,
        previous: ParagraphBreak, next: ParagraphBreak
    ) -> QualityReferencePath
    {
        guard case .terminal(.end) = next.kind
        else
        {
            return path
        }
        let shortage = max(0, width / 4 - advance)
        let badness = 100 * pow(shortage / (width / 10), 3)
        var extra = pow(10 + badness, 2) - 100
        switch previous.kind
        {
        case .authored, .automatic: extra += 5000
        default: break
        }
        return QualityReferencePath(
            nodes: path.nodes, emergency: path.emergency, ragged: path.ragged,
            demerits: path.demerits + extra, fitness: path.fitness
        )
    }
}
