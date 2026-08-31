import Testing

@testable import FundamentalDocument

extension SemanticTableCellAdmissionTests
{
    @Test("missing locations produce no location or location repair")
    func missingLocationsProduceNoLocationOrLocationRepair() throws
    {
        let admission = try Self.admit(Self.legacy())

        #expect(admission.evidence.count == 1)
        guard case .confidence = admission.evidence[0]
        else
        {
            Issue.record("Expected only confidence evidence")
            return
        }
    }

    @Test("blank and nonblank locations admit their exact evidence")
    func blankAndNonblankLocationsAdmitTheirExactEvidence() throws
    {
        let blank = try Self.admit(
            Self.legacy(sourceLocation: " \t\n ")
        )
        let exactValue = "  table:2:3  "
        let exact = try Self.admit(
            Self.legacy(sourceLocation: exactValue)
        )
        let (row, cell) = try Self.indices()
        let target = SemanticTableEvidenceTarget.cell(
            row: row,
            cell: cell
        )
        let repair = try #require(
            SemanticTableRepair(
                target: target,
                kind: .blankSourceLocationDiscarded
            )
        )
        let location = try #require(
            SemanticTableSourceLocation(exactValue)
        )

        #expect(blank.evidence.contains(.repair(repair)))
        #expect(exact.evidence.contains(.sourceLocation(
            target: target,
            location: location
        )))
    }

    @Test("closed confidence values admit exact cell facts")
    func closedConfidenceValuesAdmitExactCellFacts() throws
    {
        let (row, cell) = try Self.indices()
        let target = SemanticTableConfidenceTarget.cell(
            row: row,
            cell: cell
        )

        for value in [0.0, 0.5, 1.0]
        {
            let admission = try Self.admit(
                Self.legacy(confidence: value)
            )
            let confidence = try #require(
                SemanticTableConfidence(value)
            )

            #expect(admission.evidence.contains(.confidence(
                target: target,
                confidence: confidence
            )))
        }
    }
}
