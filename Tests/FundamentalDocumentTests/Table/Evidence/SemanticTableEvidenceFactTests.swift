import Testing

@testable import FundamentalDocument

@Suite("A semantic table evidence fact")
struct SemanticTableEvidenceFactTests
{
    @Test("a source-location fact preserves its required facts")
    func sourceLocationFactPreservesRequiredFacts() throws
    {
        let location = try #require(
            SemanticTableSourceLocation("after paragraph 3")
        )
        let fact = SemanticTableEvidenceFact.sourceLocation(
            target: .table,
            location: location
        )

        guard case let .sourceLocation(target, admitted) = fact
        else
        {
            Issue.record("Expected a source-location fact")
            return
        }

        #expect(target == .table)
        #expect(admitted == location)
    }

    @Test("a confidence fact preserves its required facts")
    func confidenceFactPreservesRequiredFacts() throws
    {
        let confidence = try #require(SemanticTableConfidence(0.75))
        let fact = SemanticTableEvidenceFact.confidence(
            target: .table,
            confidence: confidence
        )

        guard case let .confidence(target, admitted) = fact
        else
        {
            Issue.record("Expected a confidence fact")
            return
        }

        #expect(target == .table)
        #expect(admitted == confidence)
    }

    @Test("a repair fact preserves its required fact")
    func repairFactPreservesRequiredFact() throws
    {
        let repair = try #require(
            SemanticTableRepair(
                target: .table,
                kind: .headerRowCountClamped
            )
        )
        let fact = SemanticTableEvidenceFact.repair(repair)

        guard case let .repair(admitted) = fact
        else
        {
            Issue.record("Expected a repair fact")
            return
        }

        #expect(admitted == repair)
    }

    @Test("reconstruction leaves the original fact unchanged")
    func reconstructionLeavesOriginalFactUnchanged() throws
    {
        let originalConfidence = try #require(
            SemanticTableConfidence(0.25)
        )
        let changedConfidence = try #require(
            SemanticTableConfidence(0.75)
        )
        let original = SemanticTableEvidenceFact.confidence(
            target: .table,
            confidence: originalConfidence
        )
        let changed = SemanticTableEvidenceFact.confidence(
            target: .table,
            confidence: changedConfidence
        )

        #expect(original != changed)
        #expect(original == .confidence(
            target: .table,
            confidence: originalConfidence
        ))
    }
}
