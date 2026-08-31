import Foundation
import Testing

@testable import FundamentalDocument

@Suite("Canonical document content")
struct CanonicalDocumentContentTests
{
    @Test("one first block forms exact nonempty content")
    func firstBlockFormsNonemptyContent() throws
    {
        let first = Self.identified(marker: 1, text: "First")
        let content = try #require(
            CanonicalDocumentContent(
                firstBlock: first,
                remainingBlocks: []
            )
        )

        #expect(content.firstBlock == first)
        #expect(content.remainingBlocks.isEmpty)
        #expect(content.blocks == [first])
    }

    @Test("multiple blocks preserve exact order")
    func multipleBlocksPreserveOrder() throws
    {
        let blocks = [
            Self.identified(marker: 1, text: "First"),
            Self.identified(marker: 2, text: "Second"),
            Self.identified(marker: 3, text: "Third")
        ]
        let content = try #require(
            CanonicalDocumentContent(
                firstBlock: blocks[0],
                remainingBlocks: Array(blocks.dropFirst())
            )
        )

        #expect(content.blocks == blocks)
    }

    @Test("all admitted semantic forms coexist unchanged")
    func allAdmittedFormsCoexist() throws
    {
        let run = SemanticRun(text: "Text")
        let semanticBlocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: [run])),
            .heading(.title(TitleSemanticHeading(runs: [run]))),
            .code(.plain(PlainSemanticCodeBlock(runs: [run]))),
            .table(SemanticBlockTests.emptyTableRecord())
        ]
        let blocks = semanticBlocks.enumerated().map
        {
            index, block in
            Self.identified(marker: UInt8(index), block: block)
        }
        let content = try #require(
            CanonicalDocumentContent(
                firstBlock: blocks[0],
                remainingBlocks: Array(blocks.dropFirst())
            )
        )

        #expect(content.blocks.map(\.block) == semanticBlocks)
    }

    static func identified(
        marker: UInt8,
        text: String
    ) -> IdentifiedSemanticBlock
    {
        identified(
            marker: marker,
            block: IdentifiedSemanticBlockTests.paragraph(text)
        )
    }

    static func identified(
        marker: UInt8,
        block: SemanticBlock
    ) -> IdentifiedSemanticBlock
    {
        IdentifiedSemanticBlock(
            blockID: FundamentalBlockID(uuid(marker)),
            block: block
        )
    }

    private static func uuid(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (marker, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
