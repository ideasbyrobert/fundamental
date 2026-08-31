import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Semantic table record encoding")
struct SemanticTableRecordEncodingTests
{
    typealias Canonical = CanonicalSemanticTableRecordCodecTests
    static func minimalRecord() -> SemanticTableRecord
    {
        .semantic(SourcedSemanticTableTests.table())
    }
    static func fullSourcedTable(_ table: SemanticTable)
        throws -> SourcedSemanticTable
    {
        typealias E = SemanticTableEvidenceTests
        let r0 = try E.row(0)
        let r1 = try E.row(1)
        let c = try E.cell(0)
        let facts = [
            try E.location(target: .table, value: "table:1"),
            try E.confidence(target: .table, value: 0.75),
            try E.repair(target: .table, kind: .headerRowCountClamped),
            try E.location(target: .row(r0), value: "row:0"),
            try E.confidence(target: .cell(row: r0, cell: c), value: 1),
            try E.repair(
                target: .cell(row: r0, cell: c),
                kind: .contradictoryCellHeaderFlagDiscarded),
            try E.repair(
                target: .row(r1), kind: .blankSourceLocationDiscarded),
            try E.confidence(target: .cell(row: r1, cell: c), value: 0.5),
            try E.repair(
                target: .cell(row: r1, cell: c),
                kind: .nonpositiveRowSpanNormalizedToOne)
        ]
        return try SourcedSemanticTableTests.sourced(table: table, facts: facts)
    }
    static func variedRecord() throws -> SemanticTableRecord
    {
        let traits =
            #"["emphasis","inlineCode","strong","strikethrough","# +
            #""subscript","superscript","underline"]"#
        let link =
            #"{"link":"chapter/two","text":"Link","traits":\#(traits)}"#
        let language =
            #"{"language":"hy","text":"Language","traits":[]}"#
        let trailing =
            #"{"alignment":"trailing","kind":"regular","runs":[\#(link)]}"#
        let unspecified =
            #"{"alignment":"unspecified","kind":"regular","# +
            #""runs":[\#(language)]}"#
        let row = #"{"cells":[\#(trailing),\#(unspecified)]}"#
        let content =
            #"{"bodyRows":[\#(row)],"columnAlignments":["trailing","# +
            #""unspecified"],"headerRows":[]}"#
        let table = #"{"content":\#(content),"kind":"regular"}"#
        return try Canonical.decode(Canonical.tableRoot(table))
    }
    static func sourcedRegularRecord() throws -> SemanticTableRecord
    {
        let target = #"{"cell":0,"kind":"cell","row":0}"#
        let repair = Canonical.fact(
            #""kind":"repair","# +
            #""repair":"nonpositiveColumnSpanNormalizedToOne""#,
            target: target)
        return try Canonical.decode(Canonical.sourcedRoot(repair))
    }
    @Test("semantic and sourced roots encode their exact owned members")
    func semanticAndSourcedRootsEncodeExactOwnedMembers() throws
    {
        let semantic = try Self.text(SemanticTableRecordCodec.encode(
            Self.minimalRecord()
        ))
        let sourced = try Self.text(SemanticTableRecordCodec.encode(
            SemanticTableRecordRoundTripTests.fullRecord()
        ))
        #expect(semantic.hasPrefix(#"{"record":"semantic","table":"#))
        #expect(semantic.contains(#""evidence":"#) == false)
        #expect(sourced.hasPrefix(#"{"evidence":"#))
        #expect(sourced.contains(#","record":"sourced","table":"#))
    }
    @Test("encoding uses one line feed and unescaped slashes")
    func encodingUsesOneLineFeedAndUnescapedSlashes() throws
    {
        let data = try SemanticTableRecordCodec.encode(
            try SemanticTableRecordRoundTripTests.fullRecord()
        )
        let text = try Self.text(data)
        #expect(data.last == 0x0A)
        #expect(data.dropLast().contains(0x0A) == false)
        #expect(text.contains("chapter/one"))
        #expect(text.contains(#"chapter\/one"#) == false)
    }
    static func text(_ data: Data) throws -> String
    {
        try #require(String(data: data, encoding: .utf8))
    }
}
