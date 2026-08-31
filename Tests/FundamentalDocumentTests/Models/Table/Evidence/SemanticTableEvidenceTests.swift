import Testing

@testable import FundamentalDocument

@Suite("Semantic table evidence")
struct SemanticTableEvidenceTests
{
    static func row(
        _ value: Int
    ) throws -> SemanticTableRowIndex
    {
        try #require(SemanticTableRowIndex(value))
    }

    static func cell(
        _ value: Int
    ) throws -> SemanticTableCellIndex
    {
        try #require(SemanticTableCellIndex(value))
    }

    static func location(
        target: SemanticTableEvidenceTarget,
        value: String = "source"
    ) throws -> SemanticTableEvidenceFact
    {
        .sourceLocation(
            target: target,
            location: try #require(
                SemanticTableSourceLocation(value)
            )
        )
    }

    static func confidence(
        target: SemanticTableConfidenceTarget,
        value: Double = 0.5
    ) throws -> SemanticTableEvidenceFact
    {
        .confidence(
            target: target,
            confidence: try #require(
                SemanticTableConfidence(value)
            )
        )
    }

    static func repair(
        target: SemanticTableEvidenceTarget,
        kind: SemanticTableRepairKind
    ) throws -> SemanticTableEvidenceFact
    {
        .repair(try #require(SemanticTableRepair(
            target: target,
            kind: kind
        )))
    }

    static func evidence(
        _ facts: [SemanticTableEvidenceFact]
    ) throws -> SemanticTableEvidence
    {
        let firstFact = try #require(facts.first)
        return try #require(SemanticTableEvidence(
            firstFact: firstFact,
            remainingFacts: Array(facts.dropFirst())
        ))
    }

    @Test("a single fact forms nonempty evidence")
    func singleFactFormsNonemptyEvidence() throws
    {
        let fact = try Self.location(target: .table)
        let evidence = try Self.evidence([fact])

        #expect(evidence.firstFact == fact)
        #expect(evidence.remainingFacts.isEmpty)
        #expect(evidence.facts == [fact])
    }

    @Test("reconstruction leaves original evidence unchanged")
    func reconstructionLeavesOriginalEvidenceUnchanged() throws
    {
        let originalFact = try Self.location(target: .table)
        let original = try Self.evidence([originalFact])
        let row = try Self.row(0)
        let changed = try Self.evidence([
            Self.location(target: .row(row), value: "changed")
        ])

        #expect(original != changed)
        #expect(original.facts == [originalFact])
    }
}
