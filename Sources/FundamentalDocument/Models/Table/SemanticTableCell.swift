struct SemanticTableCell: Codable, Equatable, Sendable
{
    var runs: [SemanticRun]
    var isHeader: Bool
    var rowSpan: Int
    var columnSpan: Int
    var alignment: SemanticTableColumnAlignment
    var sourceLocation: String?
    var confidence: Double

    init(
        runs: [SemanticRun],
        isHeader: Bool = false,
        rowSpan: Int = 1,
        columnSpan: Int = 1,
        alignment: SemanticTableColumnAlignment = .unspecified,
        sourceLocation: String? = nil,
        confidence: Double = 1
    )
    {
        self.runs = runs
        self.isHeader = isHeader
        self.rowSpan = max(1, rowSpan)
        self.columnSpan = max(1, columnSpan)
        self.alignment = alignment
        self.sourceLocation = sourceLocation
        self.confidence = confidence
    }

    var plainText: String
    {
        runs.map(\.text).joined()
    }
}
