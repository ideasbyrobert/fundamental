@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
@MainActor
struct TerminalReferenceSearch
{
    let cache: ParagraphEdgeCache
    let width: Double

    func run(upperBound: QualityScore? = nil) throws
        -> (best: QualityReferencePath, completePaths: Int, pruned: Int)
    {
        let points = cache.candidates.breaks
        var complete = 0
        var pruned = 0
        var best: QualityReferencePath?
        func walk(_ node: Int, path: QualityReferencePath) throws
        {
            if let bound = upperBound,
               path.rank > (bound.emergency, bound.demerits)
            {
                pruned += 1
                return
            }
            if node == points.count - 1
            {
                complete += 1
                if let old = best, !(path.rank < old.rank)
                {
                    return
                }
                best = path
                return
            }
            for next in (node + 1)..<points.count
            {
                guard let line = try assessment(from: node, to: next)
                else
                {
                    continue
                }
                try walk(next, path: line.appending(
                    to: path, node: next,
                    previous: points[node], next: points[next]
                ))
            }
        }
        try walk(0, path: .empty)
        guard let best
        else
        {
            throw ParagraphFailure.noFeasibleLayout(cache.candidates.line.range)
        }
        return (best, complete, pruned)
    }

    func assessment(from start: Int, to end: Int) throws
        -> TerminalReferenceLine?
    {
        guard case let .measured(metrics) = try cache.measure(
            from: start, to: end
        )
        else
        {
            return nil
        }
        return TerminalReferenceLine.assess(
            metrics, width: width,
            terminal: cache.candidates.breaks[end].terminal
        )
    }

    func evaluate(_ nodes: [Int]) throws -> QualityReferencePath
    {
        var result = QualityReferencePath.empty
        var start = 0
        for end in nodes
        {
            guard let line = try assessment(from: start, to: end)
            else
            {
                throw ParagraphFailure.changedMeasurement
            }
            result = line.appending(
                to: result, node: end,
                previous: cache.candidates.breaks[start],
                next: cache.candidates.breaks[end]
            )
            start = end
        }
        return result
    }
}
