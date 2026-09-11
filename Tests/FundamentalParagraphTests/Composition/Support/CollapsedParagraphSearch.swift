@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
@MainActor
struct CollapsedParagraphSearch
{
    let cache: ParagraphEdgeCache
    let width: Double

    func run() throws -> ReferenceParagraphPath
    {
        let points = cache.candidates.breaks
        var states = [ReferenceParagraphPath?](
            repeating: nil, count: points.count
        )
        states[0] = .init(nodes: [], score: .zero, fitness: 1)
        for end in 1..<points.count
        {
            for start in 0..<end
            {
                guard let previous = states[start],
                      case let .measured(metrics) = try cache.measure(
                          from: start, to: end
                      ),
                      let line = ReferenceLineAssessment.assess(
                          metrics, width: width, terminal: points[end].terminal
                      )
                else
                {
                    continue
                }
                let candidate = ReferenceParagraphPath(
                    nodes: previous.nodes + [end],
                    score: line.extending(
                        previous.score, previousFitness: previous.fitness,
                        previous: points[start], next: points[end]
                    ),
                    fitness: line.fitness
                )
                if let old = states[end], !(candidate.rank < old.rank)
                {
                    continue
                }
                states[end] = candidate
            }
        }
        guard let result = states.last.flatMap({ $0 })
        else
        {
            throw ParagraphFailure.noFeasibleLayout(cache.candidates.line.range)
        }
        return result
    }
}
