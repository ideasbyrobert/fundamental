import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection
@testable import FundamentalViewport

enum ViewportFixture
{
    static let documentID = UUID(uuid: (
        0x71, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1
    ))

    @MainActor
    static func layout(
        repetitions: Int = 40,
        width: Double = 140,
        generation: UInt64 = 11
    ) throws -> LayoutSnapshot
    {
        let run = SemanticRun.direct(SemanticDirectRun(
            text: String(
                repeating: "bounded native viewport content ",
                count: repetitions
            ),
            traits: []
        ))
        let block = IdentifiedSemanticBlock(
            blockID: FundamentalBlockID(blockID),
            block: .paragraph(SemanticParagraph(runs: [run]))
        )
        let content = try #require(CanonicalDocumentContent(
            firstBlock: block,
            remainingBlocks: []
        ))
        let document = CanonicalDocument(
            documentID: FundamentalDocumentID(documentID),
            revision: DocumentRevision(7),
            content: content
        )
        let projection = ProjectionSnapshot(DocumentSnapshot(
            generation: SnapshotGeneration(9),
            document: document
        ))
        let request = try #require(LayoutRequest(
            generation: generation,
            width: width,
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

    static var blockID: UUID
    {
        UUID(uuid: (
            0x72, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 1
        ))
    }

    static func bounds(
        of fragment: LayoutFragment
    ) throws -> LayoutRectangle
    {
        try #require(LayoutRectangle(
            origin: fragment.frame.origin,
            size: fragment.frame.size
        ))
    }

    static func request(
        layout: LayoutSnapshot,
        bounds: LayoutRectangle,
        preceding: Double = 0,
        following: Double = 0,
        limit: Int = 8,
        generation: UInt64 = 13
    ) throws -> ViewportRequest
    {
        try #require(ViewportRequest(
            expectedLayoutLineage: layout.lineage,
            generation: generation,
            visibleBounds: bounds,
            precedingOverscanExtent: preceding,
            followingOverscanExtent: following,
            maximumResidentCount: limit
        ))
    }
}
