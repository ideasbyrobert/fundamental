struct LegacySemanticTableCell: Decodable, Sendable
{
    let runs: [SemanticRun]
    let isHeader: Bool
    let rowSpan: Int
    let columnSpan: Int
    let alignment: SemanticTableColumnAlignment
    let sourceLocation: String?
    let confidence: Double
}
