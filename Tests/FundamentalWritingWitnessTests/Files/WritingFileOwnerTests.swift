import Foundation
import FundamentalDocument
import FundamentalStorage
import Testing

@testable import FundamentalWritingWitness

@Suite("Native document file ownership")
@MainActor
struct WritingFileOwnerTests
{
    @Test("saving and opening connect one session to verified stored content")
    func saveAndOpen() async throws
    {
        let fixture = try WritingFileFixture()
        defer
        {
            fixture.remove()
        }
        let source = try WritingTestDocument("Exact e\u{301} 👩‍💻 writing.")
        let owner = WritingFileOwner(
            session: DocumentSession(state: source.state)
        )
        let before = owner.session.document
        #expect(owner.binding == nil)
        #expect(owner.session.isDirty)
        try await owner.save(to: fixture.location)
        #expect(owner.binding?.location == fixture.location)
        #expect(!owner.session.isDirty)
        #expect(!owner.isSaving)
        let opened = try await WritingFileOwner.open(fixture.location)
        #expect(opened.session !== owner.session)
        #expect(opened.session.document == before)
        #expect(!opened.session.isDirty)
        #expect(opened.binding?.revision == owner.binding?.revision)
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let expected = try codec.encode(before)
        #expect(try Data(contentsOf: fixture.location.url) == expected)
    }

    @Test("occupied new files leave the session dirty and unbound")
    func refusedCreation() async throws
    {
        let fixture = try WritingFileFixture()
        defer
        {
            fixture.remove()
        }
        let bytes = Data("An existing file.".utf8)
        try bytes.write(to: fixture.location.url)
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("New writing.").state
        ))
        await #expect(throws: DocumentFileFailure.destinationExists)
        {
            try await owner.save(to: fixture.location)
        }
        #expect(owner.session.isDirty)
        #expect(!owner.isSaving)
        #expect(owner.binding == nil)
        #expect(try Data(contentsOf: fixture.location.url) == bytes)
    }
}
