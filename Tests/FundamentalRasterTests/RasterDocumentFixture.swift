import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

extension RasterFixture
{
    static let documentID = UUID(uuid: (
        0x67, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1
    ))

    static func run(
        _ text: String,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticRun
    {
        .direct(SemanticDirectRun(
            text: text,
            traits: traits
        ))
    }

    @MainActor
    static func layout(
        _ blocks: [SemanticBlock],
        width: Double = 240,
        rowSpacing: Double = 4,
        cellPadding: Double = 5
    ) throws -> LayoutSnapshot
    {
        let identified = blocks.enumerated().map
        {
            IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(UUID(uuid: (
                    0x68, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, 0, 0, 0, 0, 0,
                    UInt8($0.offset + 1)
                ))),
                block: $0.element
            )
        }
        let firstBlock = try #require(identified.first)
        let content = try #require(CanonicalDocumentContent(
            firstBlock: firstBlock,
            remainingBlocks: Array(identified.dropFirst())
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
            generation: 11,
            width: width,
            blockSpacing: 12,
            rowSpacing: rowSpacing,
            columnSpacing: 6,
            cellPadding: cellPadding
        ))
        return try NativeTextKit2Layout().layout(
            projection,
            request: request
        )
    }
}
