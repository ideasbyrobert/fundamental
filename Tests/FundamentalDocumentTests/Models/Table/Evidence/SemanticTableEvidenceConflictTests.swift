import Testing

@testable import FundamentalDocument

extension SemanticTableEvidenceTests
{
    @Test("equal and conflicting location duplicates are refused")
    func equalAndConflictingLocationDuplicatesAreRefused() throws
    {
        let first = try Self.location(target: .table, value: "first")
        for value in ["first", "second"]
        {
            let second = try Self.location(target: .table, value: value)
            #expect(SemanticTableEvidence(
                firstFact: first,
                remainingFacts: [second]
            ) == nil)
        }
    }

    @Test("equal and conflicting confidence duplicates are refused")
    func equalAndConflictingConfidenceDuplicatesAreRefused() throws
    {
        let first = try Self.confidence(target: .table, value: 0.5)
        for value in [0.5, 0.75]
        {
            let second = try Self.confidence(
                target: .table,
                value: value
            )
            #expect(SemanticTableEvidence(
                firstFact: first,
                remainingFacts: [second]
            ) == nil)
        }
    }

    @Test("a repeated repair kind at one target is refused")
    func repeatedRepairKindAtOneTargetIsRefused() throws
    {
        let repair = try Self.repair(
            target: .table,
            kind: .headerRowCountClamped
        )

        #expect(SemanticTableEvidence(
            firstFact: repair,
            remainingFacts: [repair]
        ) == nil)
    }

    @Test("distinct repair kinds at one target are admitted")
    func distinctRepairKindsAtOneTargetAreAdmitted() throws
    {
        let header = try Self.repair(
            target: .table,
            kind: .headerRowCountClamped
        )
        let blank = try Self.repair(
            target: .table,
            kind: .blankSourceLocationDiscarded
        )
        let evidence = try Self.evidence([blank, header])

        #expect(evidence.facts == [header, blank])
    }

    @Test("location and blank repair conflict only at one target")
    func locationAndBlankRepairConflictOnlyAtOneTarget() throws
    {
        let row = try Self.row(0)
        let location = try Self.location(target: .table)
        let sameTarget = try Self.repair(
            target: .table,
            kind: .blankSourceLocationDiscarded
        )
        let otherTarget = try Self.repair(
            target: .row(row),
            kind: .blankSourceLocationDiscarded
        )

        #expect(SemanticTableEvidence(
            firstFact: location,
            remainingFacts: [sameTarget]
        ) == nil)
        #expect(try Self.evidence([
            otherTarget,
            location
        ]).facts == [location, otherTarget])
    }
}
