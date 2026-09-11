@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
@MainActor
struct ExhaustiveParagraphSearch
{
    let cache: ParagraphEdgeCache
    let width: Double

    func run(upperBound: ParagraphScore? = nil) throws
        -> (best: ReferenceParagraphPath, completePaths: Int, pruned: Int)
    {
        let points = cache.candidates.breaks
        var complete = 0
        var pruned = 0
        var best: ReferenceParagraphPath?
        func walk(_ node: Int, path: ReferenceParagraphPath) throws
        {
            if let bound = upperBound,
               path.rank > (bound.emergency, bound.ragged, bound.demerits)
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
                guard case let .measured(metrics) = try cache.measure(
                          from: node, to: next
                      ),
                      let line = ReferenceLineAssessment.assess(
                          metrics, width: width, terminal: points[next].terminal
                      )
                else
                {
                    continue
                }
                try walk(next, path: ReferenceParagraphPath(
                    nodes: path.nodes + [next],
                    score: line.extending(
                        path.score, previousFitness: path.fitness,
                        previous: points[node], next: points[next]
                    ),
                    fitness: line.fitness
                ))
            }
        }
        try walk(0, path: .init(nodes: [], score: .zero, fitness: 1))
        guard let best
        else
        {
            throw ParagraphFailure.noFeasibleLayout(cache.candidates.line.range)
        }
        return (best, complete, pruned)
    }
}
