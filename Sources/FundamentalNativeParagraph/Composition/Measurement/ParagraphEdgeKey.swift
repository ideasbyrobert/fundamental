struct ParagraphEdgeKey: Hashable
{
    let start: Int
    let end: Int
}

enum ParagraphEdgeMeasurement
{
    case unavailable
    case measured(ParagraphLineMetrics)
}
