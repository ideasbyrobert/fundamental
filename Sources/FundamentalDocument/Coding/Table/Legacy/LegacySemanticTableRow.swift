struct LegacySemanticTableRow: Decodable, Sendable
{
    let cells: [LegacySemanticTableCell]
    let sourceLocation: String?
}
