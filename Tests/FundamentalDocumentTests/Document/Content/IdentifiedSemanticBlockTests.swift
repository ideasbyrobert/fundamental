import Foundation
import Testing

@testable import FundamentalDocument

@Suite("An identified semantic block")
struct IdentifiedSemanticBlockTests
{
    @Test("construction preserves identity and semantic payload")
    func constructionPreservesRequiredFacts()
    {
        let blockID = FundamentalBlockID(Self.uuid(1))
        let block = Self.paragraph("Exact")
        let identified = IdentifiedSemanticBlock(
            blockID: blockID,
            block: block
        )

        #expect(identified.blockID == blockID)
        #expect(identified.block == block)
    }

    @Test("all admitted semantic forms survive unchanged")
    func allAdmittedFormsSurviveUnchanged() throws
    {
        let run = SemanticRun(text: "Text")
        let blocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: [run])),
            .heading(.title(TitleSemanticHeading(runs: [run]))),
            .code(.plain(PlainSemanticCodeBlock(runs: [run]))),
            .table(try SemanticBlockTests.emptyTableRecord())
        ]

        for (index, block) in blocks.enumerated()
        {
            let identified = IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(Self.uuid(UInt8(index))),
                block: block
            )
            #expect(identified.block == block)
        }
    }

    @Test("equal payloads under distinct identities remain distinct")
    func equalPayloadsRemainNominallyDistinct()
    {
        let block = Self.paragraph("Shared")
        let first = IdentifiedSemanticBlock(
            blockID: FundamentalBlockID(Self.uuid(1)),
            block: block
        )
        let second = IdentifiedSemanticBlock(
            blockID: FundamentalBlockID(Self.uuid(2)),
            block: block
        )

        #expect(first.block == second.block)
        #expect(first != second)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let original = IdentifiedSemanticBlock(
            blockID: FundamentalBlockID(Self.uuid(1)),
            block: Self.paragraph("Original")
        )
        let replacement = IdentifiedSemanticBlock(
            blockID: original.blockID,
            block: Self.paragraph("Replacement")
        )

        #expect(original.block == Self.paragraph("Original"))
        #expect(replacement.block == Self.paragraph("Replacement"))
    }

    static func paragraph(_ text: String) -> SemanticBlock
    {
        .paragraph(
            SemanticParagraph(runs: [SemanticRun(text: text)])
        )
    }

    static func uuid(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (marker, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
