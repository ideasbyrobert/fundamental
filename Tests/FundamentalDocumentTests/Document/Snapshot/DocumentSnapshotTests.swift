import Testing

@testable import FundamentalDocument

@Suite("A document snapshot")
struct DocumentSnapshotTests
{
    @Test("construction preserves generation and document")
    func constructionPreservesRequiredFacts() throws
    {
        let snapshot = try Self.snapshot(
            blocks: [(2, Self.editableBlock(.paragraph))]
        )

        #expect(snapshot.generation == SnapshotGeneration(3))
        #expect(snapshot.document.revision == DocumentRevision(8))
    }

    @Test("every required component participates in equality")
    func everyComponentParticipatesInEquality() throws
    {
        let block = Self.editableBlock(.paragraph)
        let base = try Self.snapshot(blocks: [(2, block)])
        let equal = try Self.snapshot(blocks: [(2, block)])
        let variants = [
            try Self.snapshot(generation: 4, blocks: [(2, block)]),
            try Self.snapshot(revision: 9, blocks: [(2, block)])
        ]

        #expect(base == equal)
        #expect(variants.allSatisfy { $0 != base })
    }

    @Test(
        "every table record remains readable",
        arguments: DocumentSnapshotTableForm.allCases
    )
    func everyTableRecordRemainsReadable(
        _ form: DocumentSnapshotTableForm
    ) throws
    {
        let block = try Self.tableBlock(form)
        let snapshot = try Self.snapshot(blocks: [(2, block)])

        #expect(snapshot.document.content.blocks[0].block == block)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let original = try Self.snapshot(
            blocks: [(2, Self.editableBlock(.paragraph, text: "Original"))]
        )
        let replacement = try Self.snapshot(
            generation: 4,
            blocks: [(2, Self.editableBlock(.paragraph, text: "Changed"))]
        )

        #expect(original.generation == SnapshotGeneration(3))
        #expect(original != replacement)
    }
}
