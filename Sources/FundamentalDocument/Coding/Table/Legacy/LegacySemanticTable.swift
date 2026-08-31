struct LegacySemanticTable: Decodable, Sendable
{
    let rows: [LegacySemanticTableRow]
    let headerRowCount: Int
    let columnAlignments: [SemanticTableColumnAlignment]
    let caption: [SemanticRun]?
    let sourceLocation: String?
    let confidence: Double
}
