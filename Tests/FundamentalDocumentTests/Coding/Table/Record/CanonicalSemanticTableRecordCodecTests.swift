import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Canonical semantic table record coding")
struct CanonicalSemanticTableRecordCodecTests
{
    static let emptyContent =
        #"{"bodyRows":[],"columnAlignments":[],"headerRows":[]}"#
    static let emptyTable =
        #"{"content":\#(emptyContent),"kind":"regular"}"#
    static let semanticRoot =
        #"{"record":"semantic","table":\#(emptyTable)}"#

    static func decode(
        _ json: String
    ) throws -> SemanticTableRecord
    {
        try SemanticTableRecordCodec.decode(Data(json.utf8))
    }

    static func expectRefusal(
        _ json: String
    )
    {
        do
        {
            _ = try decode(json)
            Issue.record("Expected canonical decoding to refuse the value")
        }
        catch
        {
        }
    }

    @Test("semantic and sourced roots decode their exact record forms")
    func semanticAndSourcedRootsDecodeExactRecordForms() throws
    {
        let target = #"{"kind":"table"}"#
        let fact =
            #"{"confidence":0.5,"kind":"confidence","target":\#(target)}"#
        let sourcedRoot =
            #"{"evidence":[\#(fact)],"record":"sourced","#
            + #""table":\#(Self.emptyTable)}"#
        let semantic = try Self.decode(Self.semanticRoot)
        let sourced = try Self.decode(sourcedRoot)
        let reversed = try Self.decode(
            #"{"table":\#(Self.emptyTable),"record":"semantic"}"#
            + "  \n\t"
        )
        guard case let .semantic(semanticTable) = semantic,
              case let .sourced(sourcedTable) = sourced
        else
        {
            Issue.record("Expected both canonical record forms")
            return
        }
        #expect(semanticTable.content.headerRows.isEmpty)
        #expect(reversed == semantic)
        #expect(sourcedTable.table == semanticTable)
        #expect(sourcedTable.evidence.facts.count == 1)
    }

    @Test("a present record member commits decoding to canonical input")
    func presentRecordMemberCommitsToCanonicalInput() throws
    {
        let legacy =
            #"{"columnAlignments":[],"confidence":1,"#
            + #""headerRowCount":0,"rows":[]}"#
        let committed =
            #"{"columnAlignments":[],"confidence":1,"#
            + #""headerRowCount":0,"record":"future","rows":[]}"#

        _ = try Self.decode(legacy)
        Self.expectRefusal(committed)
    }

    @Test("malformed root and record forms refuse atomically")
    func malformedRootAndRecordFormsRefuseAtomically()
    {
        let cases = [
            "[]",
            "{}",
            #"{"record":null,"table":\#(Self.emptyTable)}"#,
            #"{"record":1,"table":\#(Self.emptyTable)}"#,
            #"{"record":"future","table":\#(Self.emptyTable)}"#,
            #"{"record":"semantic"}"#,
            #"{"record":"semantic","table":null}"#,
            #"{"evidence":[],"record":"semantic","table":\#(Self.emptyTable)}"#,
            #"{"record":"sourced","table":\#(Self.emptyTable)}"#
        ]

        for json in cases
        {
            Self.expectRefusal(json)
        }
    }
}
