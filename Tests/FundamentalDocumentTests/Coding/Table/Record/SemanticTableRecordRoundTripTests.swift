import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Semantic table record reopening")
struct SemanticTableRecordRoundTripTests
{
    static func fullRecord() throws -> SemanticTableRecord
    {
        let scopes = SemanticRunScopes.linkAndLanguage(
            link: try #require(
                SemanticLinkDestination("chapter/one")),
            language: try #require(SemanticLanguageIdentifier("hy"))
        )
        let head = SemanticTableCell.regular(RegularSemanticTableCell(
            runs: [SemanticRun(text: "Head")],
            alignment: .leading
        ))
        let extent = try #require(SemanticTableCellExtent(
            rowCount: 1,
            columnCount: 2
        ))
        let body = SemanticTableCell.spanning(SpanningSemanticTableCell(
            runs: [.scoped(SemanticScopedRun(
                text: "Body",
                traits: [.strong, .emphasis],
                scopes: scopes
            ))],
            alignment: .center,
            extent: extent
        ))
        let content = SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [head])],
            bodyRows: [BodySemanticTableRow(cells: [body])],
            columnAlignments: [.leading, .center]
        )
        let caption = SemanticTableCaption(
            firstRun: SemanticRun(text: "Caption", traits: [.emphasis]),
            remainingRuns: [.scoped(SemanticScopedRun(
                text: "Scope",
                traits: [.strong],
                scopes: scopes
            ))]
        )
        let table = SemanticTable.captioned(CaptionedSemanticTable(
            content: content,
            caption: caption
        ))
        return .sourced(
            try SemanticTableRecordEncodingTests.fullSourcedTable(table)
        )
    }
    @Test("legacy regular records survive canonical reopen")
    func legacyRegularRecordsSurviveCanonicalReopen() throws
    {
        let record = try SemanticTableRecordCodec.decode(
            LegacySemanticTableRecordCodecTests.regularData()
        )
        let data = try SemanticTableRecordCodec.encode(record)
        #expect(try SemanticTableRecordCodec.decode(data) == record)
    }
    @Test("legacy sourced captioned evidence survives canonical reopen")
    func legacySourcedCaptionedEvidenceSurvivesCanonicalReopen() throws
    {
        let data = LegacySemanticTableRecordCodecTests.captionedData()
        let before = try LegacySemanticTableRecordCodecTests.sourced(data)
        let record = try SemanticTableRecordCodec.decode(data)
        let reopened = try SemanticTableRecordCodec.decode(
            SemanticTableRecordCodec.encode(record)
        )
        #expect(record == .sourced(before))
        #expect(reopened == .sourced(before))
    }
    @Test("every semantic table form survives reopen")
    func everySemanticTableFormSurvivesReopen() throws
    {
        let records = [
            SemanticTableRecordEncodingTests.minimalRecord(),
            .semantic(SemanticTableRecordTests.captionedTable()),
            try Self.fullRecord(),
            try SemanticTableRecordEncodingTests.sourcedRegularRecord(),
            try SemanticTableRecordEncodingTests.variedRecord()
        ]
        for record in records
        {
            let data = try SemanticTableRecordCodec.encode(record)
            #expect(try SemanticTableRecordCodec.decode(data) == record)
        }
    }
    @Test("canonical bytes reach a fixed point")
    func canonicalBytesReachAFixedPoint() throws
    {
        let first = SemanticTableRecordEncodingTests.fullGoldenData()
        let record = try SemanticTableRecordCodec.decode(first)
        let second = try SemanticTableRecordCodec.encode(record)
        #expect(second == first)
    }
}
