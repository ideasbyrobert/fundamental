extension QualityPath
{
    @MainActor
    func materializing(
        cache: ParagraphEdgeCache, width: Double
    ) throws -> ParagraphPath
    {
        let points = cache.candidates.breaks
        var start = 0
        var score = ParagraphScore.zero
        var fitness = ParagraphFitness.normal
        for end in nodes
        {
            guard case let .measured(metrics) = try cache.measure(
                      from: start, to: end
                  ),
                  case let .admitted(spacing) = ParagraphLineFit(
                      metrics: metrics, width: width,
                      terminal: points[end].terminal
                  )
            else
            {
                throw ParagraphFailure.changedMeasurement
            }
            score = try score.appending(
                spacing, end: points[end], previous: points[start],
                fitness: fitness
            )
            fitness = spacing.fitness
            start = end
        }
        return ParagraphPath(
            nodes: nodes, score: score, statesRetained: statesRetained,
            transitions: transitions
        )
    }
}
