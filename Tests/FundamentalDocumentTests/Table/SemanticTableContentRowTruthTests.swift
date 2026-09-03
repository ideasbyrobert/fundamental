import Testing

@testable import FundamentalDocument

extension SemanticTableContentTests
{
    @Test("a span may cross the header and body boundary")
    func spanMayCrossHeaderAndBodyBoundary() throws
    {
        let cell = try Self.spanningCell(rows: 2, columns: 1)
        let content = SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [cell])],
            bodyRows: [BodySemanticTableRow(cells: [])],
            columnAlignments: []
        )

        #expect(content?.headerRows[0].cells == [cell])
        #expect(content?.bodyRows.count == 1)
    }

    @Test("a body span may end at the final semantic row")
    func bodySpanMayEndAtFinalSemanticRow() throws
    {
        let cell = try Self.spanningCell(rows: 2, columns: 1)
        let content = SemanticTableContent(
            headerRows: [],
            bodyRows: [
                BodySemanticTableRow(cells: [cell]),
                BodySemanticTableRow(cells: [])
            ],
            columnAlignments: []
        )

        #expect(content?.bodyRows.count == 2)
    }

    @Test("header and body overreach are refused")
    func headerAndBodyOverreachAreRefused() throws
    {
        let cell = try Self.spanningCell(rows: 2, columns: 1)
        let headerOverreach = SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [cell])],
            bodyRows: [],
            columnAlignments: []
        )
        let bodyOverreach = SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [])],
            bodyRows: [BodySemanticTableRow(cells: [cell])],
            columnAlignments: []
        )

        #expect(headerOverreach == nil)
        #expect(bodyOverreach == nil)
    }

    @Test("column extent does not bound row admission")
    func columnExtentDoesNotBoundRowAdmission() throws
    {
        let cell = try Self.spanningCell(rows: 1, columns: Int.max)
        let content = SemanticTableContent(
            headerRows: [],
            bodyRows: [BodySemanticTableRow(cells: [cell])],
            columnAlignments: []
        )

        #expect(content?.bodyRows[0].cells == [cell])
    }

    @Test("empty tables and empty rows remain admitted")
    func emptyTablesAndRowsRemainAdmitted()
    {
        let empty = SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        )
        let rows = SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [])],
            bodyRows: [BodySemanticTableRow(cells: [])],
            columnAlignments: []
        )

        #expect(empty != nil)
        #expect(rows != nil)
    }
}
