import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

extension ViewportFixture
{
    @MainActor
    static func tableLayout() throws -> LayoutSnapshot
    {
        let header = HeaderSemanticTableRow(cells: [
            .regular(RegularSemanticTableCell(
                runs: [run("Header cell")],
                alignment: .leading
            ))
        ])
        let body = BodySemanticTableRow(cells: [
            .regular(RegularSemanticTableCell(
                runs: [run("Body cell")],
                alignment: .leading
            ))
        ])
        let content = SemanticTableContent(
            headerRows: [header],
            bodyRows: [body],
            columnAlignments: [.leading]
        )
        let table = SemanticTable.regular(RegularSemanticTable(
            content: content
        ))
        let identified = IdentifiedSemanticBlock(
            blockID: FundamentalBlockID(blockID),
            block: .table(.semantic(table))
        )
        let documentContent = try #require(CanonicalDocumentContent(
            firstBlock: identified,
            remainingBlocks: []
        ))
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(documentID),
            revision: DocumentRevision(7),
            content: documentContent
        )
        let projection = ProjectionSnapshot(DocumentSnapshot(
            generation: SnapshotGeneration(9),
            document: document
        ))
        let request = try #require(LayoutRequest(
            generation: 11,
            width: 360,
            blockSpacing: 12,
            rowSpacing: 4,
            columnSpacing: 6,
            cellPadding: 5
        ))
        return try NativeTextKit2Layout().layout(
            projection,
            request: request
        )
    }

    static func run(_ text: String) -> SemanticRun
    {
        .direct(SemanticDirectRun(text: text, traits: []))
    }
}
