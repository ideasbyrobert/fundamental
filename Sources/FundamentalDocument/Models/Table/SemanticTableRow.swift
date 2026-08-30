struct SemanticTableRow: Codable, Equatable, Sendable
{
    var cells: [SemanticTableCell]
    var sourceLocation: String?

    init(
        cells: [SemanticTableCell],
        sourceLocation: String? = nil
    )
    {
        self.cells = cells
        self.sourceLocation = sourceLocation
    }
}
