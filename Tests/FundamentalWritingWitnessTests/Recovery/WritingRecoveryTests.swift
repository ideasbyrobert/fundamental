import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Committed writing recovery", .serialized)
struct WritingRecoveryTests
{
    static func record(
        _ text: String, identifier: UUID = UUID(), revision: UInt64 = 8,
        sequence: UInt64 = 1
    ) throws -> WritingRecoveryRecord
    {
        let original = try WritingTestDocument(text).projection()
        let document = CanonicalDocument(
            documentID: original.snapshot.snapshot.document.documentID,
            revision: DocumentRevision(revision),
            content: original.snapshot.snapshot.document.content
        )
        let seed = try #require(WritingDocumentSeed(document: document))
        let snapshot = try #require(WritingProjection(seed.state)).snapshot
        return try #require(WritingRecoveryRecord(
            identifier: identifier, sequence: sequence, name: "Writing.fun",
            source: URL(fileURLWithPath: "/tmp/Writing.fun"), snapshot: snapshot
        ))
    }

    static func directory() throws -> URL
    {
        let directory = FileManager.default.temporaryDirectory.appending(
            path: "FundamentalRecovery-" + UUID().uuidString
        )
        try FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true
        )
        return directory.resolvingSymlinksInPath()
    }

    @Test("canonical roles, spelling and backward selection survive recovery")
    func roundTrip() throws
    {
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "Мир e\u{301} 👨‍👩‍👧‍👦", traits: [.strong])
            ])),
            .listItem(SemanticListItem(kind: .numbered,
                                       runs: [SemanticRun(text: "Item")]))
        ], start: 6, end: 0).projection()
        let record = try #require(WritingRecoveryRecord(
            identifier: UUID(), sequence: 32, name: "Recovered writing",
            source: nil, snapshot: source.snapshot
        ))
        let codec = WritingRecoveryCodec()
        let restored = try codec.decode(codec.encode(record))
        #expect(restored.snapshot.snapshot.document ==
            source.snapshot.snapshot.document)
        #expect(restored.snapshot.selection == source.snapshot.selection)
        #expect(restored.identifier == record.identifier)
        #expect(restored.sequence == 32)
        #expect(restored.source == nil)
        let session = DocumentSession(state: .editable(restored.snapshot))
        #expect(session.isDirty)
        #expect(!session.canUndo)
        #expect(!session.canRedo)
        let projection = try #require(WritingProjection(session.state))
        #expect(Array(projection.text.utf16) == Array(source.text.utf16))
    }
}
