import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("native projection retains every scoped non-table source",
          arguments: [0, 1, 2])
    func nativeScopeProjectionAdmission(_ form: Int) throws
    {
        let attributes = SemanticRunAttributes.scoped(
            traits: [.strong], scopes: try WritingScopeFixture.scopes()[form]
        )
        let text = "Ae\u{301}😀Z"
        let blocks = try WritingInlineFixture.roles([
            SemanticRun(text: text, attributes: attributes)
        ])
        let source = try WritingTestDocument(blocks: blocks)
        let projection = try #require(WritingProjection(source.state))
        #expect(projection.snapshot.snapshot.document ==
            source.state.snapshot.document)
        #expect(projection.map.spans.count == blocks.count)
        #expect(projection.text.utf16.elementsEqual(
            Array(repeating: text, count: blocks.count)
                .joined(separator: "\n").utf16
        ))
    }

    @Test("native projection retains terminal scoped typing intent")
    func nativeScopeTypingAdmission() throws
    {
        let source = try WritingTestDocument("").projection().snapshot
        let link = try #require(SemanticLinkDestination(
            WritingScopeFixture.link
        ))
        let intent = DocumentTypingIntent(attributes:
            .scoped(traits: [], scopes: .link(link)))
        let state = try #require(EditableDocumentSnapshot(
            snapshot: source.snapshot, selection: source.selection,
            typingIntent: intent
        ))
        let projection = try #require(WritingProjection(.editable(state)))
        #expect(projection.snapshot.typingIntent == intent)
        #expect(projection.text.isEmpty)
        #expect(projection.snapshot.snapshot.document ==
            source.snapshot.document)
    }
}
