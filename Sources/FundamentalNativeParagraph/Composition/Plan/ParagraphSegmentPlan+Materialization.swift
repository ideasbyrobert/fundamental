extension ParagraphSegmentPlan
{
    @MainActor
    init(cache: ParagraphEdgeCache, path: ParagraphPath, width: Double) throws
    {
        let points = cache.candidates.breaks
        var start = 0
        var lines: [ParagraphPlannedLine] = []
        for end in path.nodes
        {
            let a = points[start]
            let b = points[end]
            guard case let .measured(metrics) = try cache.measure(
                      from: start, to: end
                  ),
                  case let .admitted(spacing) = ParagraphLineFit(
                      metrics: metrics, width: width, terminal: b.terminal
                  )
            else
            {
                throw ParagraphFailure.changedMeasurement
            }
            let display = try HyphenatedDisplay(
                cache.collection, range: a.position..<b.visibleEnd,
                end: b.kind.displayEnd
            )
            let shaped = try HyphenatedShapedLine(
                display: display, attributes: cache.attributes
            )
            let replay = try ParagraphLineMetrics(
                shaped.measurement, units: display.units
            )
            guard replay == metrics
            else
            {
                throw ParagraphFailure.changedMeasurement
            }
            lines.append(.init(
                sourceRange: a.position..<b.position,
                tail: cache.collection.source.fragments(
                    in: b.visibleEnd..<b.position
                ).fragments,
                ending: b, shaped: shaped, metrics: metrics, spacing: spacing
            ))
            start = end
        }
        candidates = cache.candidates
        self.path = path
        self.lines = lines
        nativeMeasurements = cache.nativeMeasurements + lines.count
        metricRequests = cache.requests
    }
}
