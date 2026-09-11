enum ParagraphLineFit
{
    case unavailable
    case admitted(ParagraphSpacing)

    init(metrics: ParagraphLineMetrics, width: Double, terminal: Bool)
    {
        let delta = width - metrics.advance
        if delta == 0 || (terminal && delta >= 0)
        {
            self = .admitted(.init(
                kind: .natural, adjustment: 0, advance: metrics.advance,
                ratio: 0, fitness: .normal
            ))
            return
        }
        if let minimum = metrics.gaps.map(\.advance).min(), minimum > 0
        {
            let adjustment = delta / Double(metrics.gaps.count)
            let capacity = minimum * (delta >= 0 ? 0.75 : 0.25)
            let ratio = adjustment / capacity
            if ratio.isFinite, ratio >= -1, ratio <= 1
            {
                self = .admitted(.init(
                    kind: .justified, adjustment: adjustment, advance: width,
                    ratio: ratio, fitness: ParagraphFitness(ratio: ratio)
                ))
                return
            }
        }
        if delta >= 0
        {
            self = .admitted(.init(
                kind: .ragged, adjustment: 0, advance: metrics.advance,
                ratio: delta / width, fitness: .ragged
            ))
        }
        else
        {
            self = .unavailable
        }
    }
}
