import Testing

@testable import FundamentalDocument

extension DocumentSnapshotTests
{
    @Test("zero and terminal generations survive unchanged")
    func generationBoundsSurviveUnchanged() throws
    {
        let block = Self.editableBlock(.paragraph)
        let initial = try Self.snapshot(generation: 0, blocks: [(2, block)])
        let terminal = try Self.snapshot(
            generation: UInt64.max,
            blocks: [(2, block)]
        )

        #expect(initial.generation == .zero)
        #expect(terminal.generation == SnapshotGeneration(UInt64.max))
    }

    @Test("generation and document revision remain independent")
    func generationAndRevisionRemainIndependent() throws
    {
        let snapshot = try Self.snapshot(
            generation: 27,
            revision: 4,
            blocks: [(2, Self.editableBlock(.paragraph))]
        )

        #expect(snapshot.generation == SnapshotGeneration(27))
        #expect(snapshot.document.revision == DocumentRevision(4))
    }

    @Test("mixed readable content survives exactly")
    func mixedReadableContentSurvivesExactly() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.editableBlock(.paragraph)),
            (3, try Self.tableBlock(.sourcedCaptioned)),
            (4, Self.editableBlock(.code))
        ]
        let snapshot = try Self.snapshot(blocks: blocks)

        #expect(snapshot.document.content.blocks.map(\.block) ==
            blocks.map(\.1))
    }
}
