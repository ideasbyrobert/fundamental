import Foundation
import Testing

@testable import FundamentalDocument

@Suite("A canonical document")
struct CanonicalDocumentTests
{
    @Test("construction preserves every canonical document fact")
    func constructionPreservesRequiredFacts() throws
    {
        let document = try Self.document()
        let expectedContent = try Self.content("Text")

        #expect(document.documentID == FundamentalDocumentID(Self.uuid(1)))
        #expect(document.revision == DocumentRevision(8))
        #expect(document.content == expectedContent)
    }

    @Test("every canonical component participates in equality")
    func everyComponentParticipatesInEquality() throws
    {
        let base = try Self.document()
        let equal = try Self.document()
        let variants = [
            try Self.document(documentMarker: 2),
            try Self.document(revision: 9),
            try Self.document(text: "Other")
        ]

        #expect(base == equal)
        #expect(variants.allSatisfy { $0 != base })
    }

    @Test("zero and terminal revisions survive unchanged")
    func revisionBoundsSurviveUnchanged() throws
    {
        let initial = try Self.document(revision: 0)
        let terminal = try Self.document(revision: UInt64.max)

        #expect(initial.revision == .zero)
        #expect(terminal.revision == DocumentRevision(UInt64.max))
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let original = try Self.document(revision: 8, text: "Original")
        let replacement = try Self.document(
            documentMarker: 2,
            revision: 9,
            text: "Replacement"
        )
        let expectedContent = try Self.content("Original")

        #expect(original.documentID == FundamentalDocumentID(Self.uuid(1)))
        #expect(original.revision == DocumentRevision(8))
        #expect(original.content == expectedContent)
        #expect(replacement != original)
    }

    private static func document(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        text: String = "Text"
    ) throws -> CanonicalDocument
    {
        CanonicalDocument(
            documentID: FundamentalDocumentID(uuid(documentMarker)),
            revision: DocumentRevision(revision),
            content: try content(text)
        )
    }

    private static func content(
        _ text: String
    ) throws -> CanonicalDocumentContent
    {
        try #require(
            CanonicalDocumentContent(
                firstBlock: CanonicalDocumentContentTests.identified(
                    marker: 1,
                    text: text
                ),
                remainingBlocks: []
            )
        )
    }

    private static func uuid(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (marker, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
