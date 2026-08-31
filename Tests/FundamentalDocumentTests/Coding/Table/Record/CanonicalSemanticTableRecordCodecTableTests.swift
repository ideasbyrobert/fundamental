import Testing

@testable import FundamentalDocument

extension CanonicalSemanticTableRecordCodecTests
{
    static func tableRoot(
        _ table: String
    ) -> String
    {
        #"{"record":"semantic","table":\#(table)}"#
    }

    static func regularCell(
        text: String
    ) -> String
    {
        let run = #"{"text":"\#(text)","traits":[]}"#
        return #"{"alignment":"leading","kind":"regular","runs":[\#(run)]}"#
    }

    @Test("regular and captioned tables decode their exact owned facts")
    func regularAndCaptionedTablesDecodeExactOwnedFacts() throws
    {
        let caption = #"[{"text":"Caption","traits":[]}]"#
        let captioned =
            #"{"caption":\#(caption),"content":\#(Self.emptyContent),"#
            + #""kind":"captioned"}"#
        let regularRecord = try Self.decode(Self.semanticRoot)
        let captionedRecord = try Self.decode(Self.tableRoot(captioned))

        guard case .regular = regularRecord.table,
              case let .captioned(table) = captionedRecord.table
        else
        {
            Issue.record("Expected regular and captioned tables")
            return
        }
        #expect(table.caption.runs.map(\.text) == ["Caption"])
    }

    @Test("content preserves row cell and alignment order")
    func contentPreservesRowCellAndAlignmentOrder() throws
    {
        let first = Self.regularCell(text: "First")
        let second = Self.regularCell(text: "Second")
        let third = Self.regularCell(text: "Third")
        let header = #"{"cells":[\#(first),\#(second)]}"#
        let body = #"{"cells":[\#(third)]}"#
        let content =
            #"{"bodyRows":[\#(body)],"columnAlignments":["trailing","#
            + #""leading"],"headerRows":[\#(header)]}"#
        let table = #"{"content":\#(content),"kind":"regular"}"#
        let decoded = try Self.decode(Self.tableRoot(table)).table.content

        #expect(decoded.headerRows[0].cells.map(\.plainText) == [
            "First",
            "Second"
        ])
        #expect(decoded.bodyRows[0].cells.map(\.plainText) == ["Third"])
        #expect(decoded.columnAlignments == [.trailing, .leading])
    }

    @Test("malformed tables content rows and captions refuse atomically")
    func malformedTablesContentRowsAndCaptionsRefuseAtomically()
    {
        let badRow = #"{"cells":null}"#
        let badContent =
            #"{"bodyRows":[\#(badRow)],"columnAlignments":[],"headerRows":[]}"#
        let emptyCaption =
            #"{"caption":[],"content":\#(Self.emptyContent),"#
            + #""kind":"captioned"}"#
        let cases = [
            #"{"content":\#(Self.emptyContent),"kind":"future"}"#,
            emptyCaption,
            #"{"content":\#(Self.emptyContent),"kind":"captioned"}"#,
            #"{"caption":[],"content":\#(Self.emptyContent),"kind":"regular"}"#,
            #"{"content":null,"kind":"regular"}"#,
            #"{"content":\#(badContent),"kind":"regular"}"#,
            #"{"content":{"bodyRows":[],"headerRows":[]},"kind":"regular"}"#,
            #"{"content":{"bodyRows":[],"columnAlignments":["future"],"#
            + #""headerRows":[]},"kind":"regular"}"#
        ]

        for table in cases
        {
            Self.expectRefusal(Self.tableRoot(table))
        }
    }
}
