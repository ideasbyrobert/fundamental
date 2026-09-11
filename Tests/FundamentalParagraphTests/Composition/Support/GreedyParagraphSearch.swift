@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
@MainActor
struct GreedyParagraphSearch
{
    let cache: ParagraphEdgeCache
    let width: Double

    func run() throws -> ReferenceParagraphPath
    {
        let points = cache.candidates.breaks
        var current = 0
        var path = ReferenceParagraphPath(nodes: [], score: .zero, fitness: 1)
        while current < points.count - 1
        {
            var chosen: ReferenceParagraphPath?
            for next in (current + 1)..<points.count
            {
                guard case let .measured(metrics) = try cache.measure(
                          from: current, to: next
                      ),
                      let line = ReferenceLineAssessment.assess(
                          metrics, width: width, terminal: points[next].terminal
                      )
                else
                {
                    continue
                }
                let candidate = ReferenceParagraphPath(
                    nodes: path.nodes + [next],
                    score: line.extending(
                        path.score, previousFitness: path.fitness,
                        previous: points[current], next: points[next]
                    ),
                    fitness: line.fitness
                )
                if let old = chosen, !(candidate.rank < old.rank)
                {
                    continue
                }
                chosen = candidate
            }
            guard let selected = chosen, let next = selected.nodes.last
            else
            {
                throw ParagraphFailure.noFeasibleLayout(
                    cache.candidates.line.range
                )
            }
            current = next
            path = selected
        }
        return path
    }
}
