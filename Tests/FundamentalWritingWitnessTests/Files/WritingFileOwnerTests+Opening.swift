import Foundation
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingFileOwnerTests
{
    @Test("unsupported writing content is refused without changing its file")
    func unsupportedContent() async throws
    {
        let fixture = try WritingFileFixture()
        defer
        {
            fixture.remove()
        }
        let source = try WritingTestDocument("A").state
        let document = DocumentSession(state: source).document
        let original = try #require(document.content.blocks.first)
        let changed = IdentifiedSemanticBlock(
            blockID: original.blockID,
            block: .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "Strong", traits: [.strong])
            ]))
        )
        let content = try #require(CanonicalDocumentContent(
            firstBlock: changed, remainingBlocks: []
        ))
        let rich = CanonicalDocument(
            documentID: document.documentID,
            revision: document.revision,
            content: content
        )
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let bytes = try codec.encode(rich)
        try bytes.write(to: fixture.location.url)
        await #expect(throws: WritingFileFailure.unsupportedDocument)
        {
            try await WritingFileOwner.open(fixture.location)
        }
        #expect(try Data(contentsOf: fixture.location.url) == bytes)
    }

    @Test("save as creates a new binding while preserving the original file")
    func saveAs() async throws
    {
        let fixture = try WritingFileFixture()
        defer
        {
            fixture.remove()
        }
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("First file.").state
        ))
        try await owner.save(to: fixture.location)
        let oldBytes = try Data(contentsOf: fixture.location.url)
        let copy = try #require(DocumentFileLocation(
            fixture.directory.appending(path: "Copy.fundamental")
        ))
        try await owner.save(to: copy)
        #expect(owner.binding?.location == copy)
        #expect(!owner.session.isDirty)
        #expect(try Data(contentsOf: fixture.location.url) == oldBytes)
        #expect(try Data(contentsOf: copy.url) == oldBytes)
    }
}
