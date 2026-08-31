import Testing

@testable import FundamentalDocument

extension CanonicalSemanticTableRecordCodecTests
{
    static func cellRoot(
        _ cells: String
    ) -> String
    {
        let row = #"{"cells":[\#(cells)]}"#
        let content =
            #"{"bodyRows":[\#(row)],"columnAlignments":[],"headerRows":[]}"#
        let table = #"{"content":\#(content),"kind":"regular"}"#
        return tableRoot(table)
    }
    static func invalidEvidenceMemberCases() -> [String]
    {
        let table = #"{"kind":"table"}"#
        let fields = [
            ("sourceLocation", "location"),
            ("confidence", "confidence"),
            ("repair", "repair")
        ]
        return fields.flatMap
        {
            let kind = $0.0
            let member = $0.1
            return [
                fact(#""kind":"\#(kind)""#, target: table),
                fact(#""kind":"\#(kind)","\#(member)":null"#,
                     target: table),
                fact(#""kind":"\#(kind)","\#(member)":{}"#,
                     target: table)
            ]
        } + [fact(
            #""kind":"repair","repair":"future""#,
            target: table)]
    }
    @Test("regular and spanning cells decode exact extents")
    func regularAndSpanningCellsDecodeExactExtents() throws
    {
        let run = #"{"text":"Cell","traits":[]}"#
        let regular =
            #"{"alignment":"leading","kind":"regular","runs":[\#(run)]}"#
        let extent = #"{"columns":2,"rows":1}"#
        let spanning =
            #"{"alignment":"center","extent":\#(extent),"#
            + #""kind":"spanning","runs":[\#(run)]}"#
        let root = Self.cellRoot(#"\#(regular),\#(spanning)"#)
        let cells = try Self.decode(root).table.content.bodyRows[0].cells

        guard case let .regular(first) = cells[0],
              case let .spanning(second) = cells[1]
        else
        {
            Issue.record("Expected regular and spanning cells")
            return
        }
        #expect(first.alignment == .leading)
        #expect(second.alignment == .center)
        #expect(second.extent.rowCount == 1)
        #expect(second.extent.columnCount == 2)
    }
    @Test("malformed and tag incompatible cells and extents refuse")
    func malformedAndTagIncompatibleCellsAndExtentsRefuse()
    {
        let run = #"{"text":"Cell","traits":[]}"#
        let extents = [
            #"{"columns":1,"rows":1}"#,
            #"{"columns":0,"rows":2}"#,
            #"{"columns":2,"rows":-1}"#,
            #"{"columns":2.5,"rows":1}"#,
            #"{"columns":2,"rows":true}"#,
            #"{"columns":2}"#
        ]
        var cells = extents.map
        {
            #"{"alignment":"leading","extent":\#($0),"#
            + #""kind":"spanning","runs":[\#(run)]}"#
        }
        let regularWithExtent =
            #"{"alignment":"leading","extent":{"columns":2,"rows":1},"#
            + #""kind":"regular","runs":[\#(run)]}"#
        cells += [
            #"{"alignment":"leading","kind":"spanning","runs":[\#(run)]}"#,
            #"{"alignment":"future","kind":"regular","runs":[\#(run)]}"#,
            #"{"alignment":"leading","kind":"regular","runs":null}"#,
            #"{"kind":"regular","runs":[\#(run)]}"#,
            regularWithExtent,
            #"{"alignment":"leading","kind":"future","runs":[\#(run)]}"#
        ]

        for cell in cells
        {
            Self.expectRefusal(Self.cellRoot(cell))
        }
    }
}
