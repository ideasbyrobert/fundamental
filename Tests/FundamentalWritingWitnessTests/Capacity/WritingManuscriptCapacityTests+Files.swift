import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingManuscriptCapacityTests
{
    @Test("a representative manuscript saves and reopens exact owned content")
    func manuscriptFile() async throws
    {
        let fixture = try WritingFileFixture()
        defer
        {
            fixture.remove()
        }
        let corpus = try WritingMeasurementCorpus(paragraphs: 1_000)
        let seed = try #require(WritingDocumentSeed(document: corpus.document))
        let owner = WritingFileOwner(session: DocumentSession(
            state: seed.state
        ))
        try await owner.save(to: fixture.location)
        let opened = try await WritingFileOwner.open(fixture.location)
        #expect(opened.session.document == corpus.document)
        #expect(!opened.session.isDirty)
        let projection = try #require(WritingProjection(opened.session.state))
        #expect(projection.map.utf16Count == corpus.utf16Count)
        #expect(projection.map.spans.count == 1_000)
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        #expect(try codec.encode(opened.session.document) ==
            codec.encode(corpus.document))
    }
}
