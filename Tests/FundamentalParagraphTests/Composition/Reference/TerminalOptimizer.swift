@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
@MainActor
struct TerminalOptimizer
{
    let cache: ParagraphEdgeCache
    let width: Double

    func optimize() throws -> QualityPath
    {
        guard width.isFinite, width > 0
        else
        {
            throw ParagraphFailure.invalidWidth
        }
        let points = cache.candidates.breaks
        let empty = [QualityReachability](
            repeating: .unavailable, count: ParagraphFitness.allCases.count
        )
        var states = [[QualityReachability]](
            repeating: empty, count: points.count
        )
        states[0][ParagraphFitness.normal.rawValue] = .reached(.init(
            score: .zero, predecessor: .start
        ))
        var transitions = 0
        for end in 1..<points.count
        {
            for start in 0..<end
            {
                guard states[start].contains(where: Self.reached),
                      case let .measured(metrics) = try cache.measure(
                          from: start, to: end
                      ),
                      case let .admitted(spacing) = ParagraphLineFit(
                          metrics: metrics, width: width,
                          terminal: points[end].terminal
                      )
                else
                {
                    continue
                }
                for fitness in ParagraphFitness.allCases
                {
                    guard case let .reached(previous) =
                        states[start][fitness.rawValue]
                    else
                    {
                        continue
                    }
                    transitions += 1
                    let base = try previous.score.appending(
                        spacing, end: points[end], previous: points[start],
                        fitness: fitness
                    )
                    let score = try TerminalCost.adding(
                        to: base, spacing: spacing, width: width,
                        end: points[end], previous: points[start]
                    )
                    let target = spacing.fitness.rawValue
                    if case let .reached(existing) = states[end][target],
                       !(score < existing.score)
                    {
                        continue
                    }
                    states[end][target] = .reached(.init(
                        score: score,
                        predecessor: .state(node: start, fitness: fitness)
                    ))
                }
            }
        }
        return try ParagraphBacktracking.path(
            states: states, range: cache.candidates.line.range,
            transitions: transitions
        )
    }

    private static func reached(_ state: QualityReachability) -> Bool
    {
        if case .reached = state
        {
            return true
        }
        return false
    }
}
