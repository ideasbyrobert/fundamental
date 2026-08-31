import Testing
@testable import FundamentalDocument
extension CanonicalSemanticTableRecordCodecTests
{
    static func expectedEvidence() throws -> [SemanticTableEvidenceFact]
    {
        let row = try #require(SemanticTableRowIndex(0))
        let cell = try #require(SemanticTableCellIndex(0))
        return [
            .repair(try #require(SemanticTableRepair(
                target: .table, kind: .headerRowCountClamped
            ))),
            .sourceLocation(
                target: .row(row),
                location: try #require(SemanticTableSourceLocation("row:0"))
            ),
            .confidence(
                target: .cell(row: row, cell: cell),
                confidence: try #require(SemanticTableConfidence(0.75))
            )
        ]
    }
    @Test("all evidence facts and positional targets decode exact values")
    func allEvidenceFactsAndPositionalTargetsDecodeExactValues() throws
    {
        let tableTarget = #"{"kind":"table"}"#
        let rowTarget = #"{"kind":"row","row":0}"#
        let cellTarget = #"{"cell":0,"kind":"cell","row":0}"#
        let repair = Self.fact(
            #""kind":"repair","repair":"headerRowCountClamped""#,
            target: tableTarget)
        let location = Self.fact(
            #""kind":"sourceLocation","location":"row:0""#,
            target: rowTarget)
        let confidence = Self.fact(
            #""confidence":0.75,"kind":"confidence""#,
            target: cellTarget)
        let json = #"\#(repair),\#(location),\#(confidence)"#
        let record = try Self.decode(Self.sourcedRoot(json))
        guard case let .sourced(sourced) = record
        else
        {
            Issue.record("Expected sourced evidence")
            return
        }
        #expect(sourced.evidence.facts == (try Self.expectedEvidence()))
    }
    @Test("evidence order canonicalizes and conflicts refuse atomically")
    func evidenceOrderCanonicalizesAndConflictsRefuseAtomically() throws
    {
        let confidence =
            #"{"confidence":1,"kind":"confidence","target":{"kind":"table"}}"#
        let location = Self.fact(
            #""kind":"sourceLocation","location":"table:1""#,
            target: #"{"kind":"table"}"#)
        let json = Self.sourcedRoot(#"\#(confidence),\#(location)"#)
        let record = try Self.decode(json)
        guard case let .sourced(sourced) = record
        else
        {
            Issue.record("Expected sourced evidence")
            return
        }
        guard case .sourceLocation = sourced.evidence.facts[0]
        else
        {
            Issue.record("Expected canonical evidence order")
            return
        }
        Self.expectRefusal(Self.sourcedRoot(""))
        Self.expectRefusal(Self.sourcedRoot(
            #"\#(confidence),\#(confidence)"#))
        let blankRepair = Self.fact(
            #""kind":"repair","repair":"blankSourceLocationDiscarded""#,
            target: #"{"kind":"table"}"#)
        Self.expectRefusal(Self.sourcedRoot(
            #"\#(location),\#(blankRepair)"#
        ))
    }
    @Test("invalid targets confidence and repairs refuse atomically")
    func invalidTargetsConfidenceAndRepairsRefuseAtomically()
    {
        let validCell = #"{"cell":0,"kind":"cell","row":0}"#
        let cases = Self.invalidEvidenceCases()
            + Self.invalidEvidenceMemberCases()
            + Self.invalidEvidenceTargetCases()
        for evidence in cases
        {
            Self.expectRefusal(Self.sourcedRoot(evidence))
        }
        let rowSpan = Self.fact(
            #""kind":"repair","repair":"nonpositiveRowSpanNormalizedToOne""#,
            target: validCell)
        Self.expectRefusal(Self.sourcedRoot(
            rowSpan,
            table: Self.tallEvidenceTable
        ))
    }
}
