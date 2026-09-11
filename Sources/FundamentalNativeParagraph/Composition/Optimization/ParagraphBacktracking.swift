@MainActor
enum ParagraphBacktracking
{
    static func path(
        states: [[QualityReachability]], range: Range<Int>, transitions: Int
    ) throws -> QualityPath
    {
        let end = states.count - 1
        var best: QualityReachability = .unavailable
        var selected = ParagraphFitness.normal
        for fitness in ParagraphFitness.allCases
        {
            if case let .reached(candidate) = states[end][fitness.rawValue]
            {
                if case let .reached(old) = best, !(candidate.score < old.score)
                {
                    continue
                }
                best = .reached(candidate)
                selected = fitness
            }
        }
        guard case let .reached(last) = best
        else
        {
            throw ParagraphFailure.noFeasibleLayout(range)
        }
        var node = end
        var fitness = selected
        var nodes: [Int] = []
        while node != 0
        {
            nodes.append(node)
            guard case let .reached(state) = states[node][fitness.rawValue],
                  case let .state(previous, previousFitness) =
                    state.predecessor,
                  previous < node
            else
            {
                throw ParagraphFailure.invalidPredecessor
            }
            node = previous
            fitness = previousFitness
        }
        return QualityPath(
            nodes: nodes.reversed(), score: last.score,
            statesRetained: states.flatMap { $0 }.filter
            {
                if case .reached = $0
                {
                    return true
                }
                return false
            }.count,
            transitions: transitions
        )
    }
}
