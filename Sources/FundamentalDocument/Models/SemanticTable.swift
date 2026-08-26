struct SemanticTable: Equatable, Sendable
{
    var rows: [SemanticTableRow]
    var headerRowCount: Int
    var columnAlignments: [SemanticTableColumnAlignment]
    var caption: [SemanticRun]?
    var sourceLocation: String?
    var confidence: Double

    init(
        rows: [SemanticTableRow],
        headerRowCount: Int = 0,
        columnAlignments: [SemanticTableColumnAlignment] = [],
        caption: [SemanticRun]? = nil,
        sourceLocation: String? = nil,
        confidence: Double = 1
    )
    {
        self.rows = rows
        self.headerRowCount = min(max(0, headerRowCount), rows.count)
        self.columnAlignments = columnAlignments
        self.caption = caption
        self.sourceLocation = sourceLocation
        self.confidence = confidence
    }
}
