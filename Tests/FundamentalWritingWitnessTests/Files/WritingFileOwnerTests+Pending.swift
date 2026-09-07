import Foundation
import FundamentalDocument
import FundamentalStorage
import Testing

@testable import FundamentalWritingWitness

extension WritingFileOwnerTests
{
    @Test("typing during a paused save remains unsaved after its receipt")
    func typingDuringSave() async throws
    {
        let fixture = try WritingFileFixture()
        defer
        {
            fixture.remove()
        }
        let source = try WritingTestDocument("A")
        let session = DocumentSession(state: source.state)
        let projection = try source.projection()
        let range = try #require(projection.range(
            NSRange(location: 1, length: 0)
        ))
        let insertion = try #require(SemanticInsertion(
            text: "B", attributes: .direct(traits: [])
        ))
        let edit = CanonicalDocumentEdit.text(.insertion(SemanticTextInsertion(
            point: range.start, insertion: insertion
        )))
        let storage = WritingSuspendedStorage()
        let owner = WritingFileOwner(session: session, storage: storage)
        let previous = session.document
        let task = Task
        {
            try await owner.save(to: fixture.location)
        }
        await storage.waitForSave()
        #expect(owner.isSaving)
        session.submit(.edit(projection.observation, edit))
        await storage.continueSave()
        try await task.value
        #expect(owner.session.isDirty)
        #expect(!owner.isSaving)
        let saved = try await DocumentFileStore().read(fixture.location)
        #expect(saved.document == previous)
        #expect(owner.session.document != saved.document)
        #expect(owner.binding?.revision == saved.revision)
    }

    @Test("a second save cannot replace the live request while storage waits")
    func overlappingSave() async throws
    {
        let fixture = try WritingFileFixture()
        defer
        {
            fixture.remove()
        }
        let storage = WritingSuspendedStorage()
        let owner = WritingFileOwner(
            session: DocumentSession(state: try WritingTestDocument("A").state),
            storage: storage
        )
        let task = Task
        {
            try await owner.save(to: fixture.location)
        }
        await storage.waitForSave()
        await #expect(throws: WritingFileFailure.busy)
        {
            try await owner.save(to: fixture.location)
        }
        #expect(owner.isSaving)
        await storage.continueSave()
        try await task.value
        #expect(!owner.session.isDirty)
    }
}
