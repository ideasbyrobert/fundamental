import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    @Test("canonically equivalent replacement remains an admitted edit")
    func equivalentSpelling() throws
    {
        let fixture = try SessionTestDocument(texts: ["\u{00E9}"])
        let insertion = try #require(SemanticInsertion(
            text: "e\u{0301}",
            attributes: .direct(traits: [])
        ))
        let replacement = try #require(SemanticTextReplacement(
            range: fixture.selection(0, 1).range,
            insertion: insertion
        ))
        let next = try Self.editable(DocumentSessionTransition(
            .edit(fixture.observation, .text(.replacement(replacement))),
            in: fixture.state
        ))
        let block = try #require(EditableSemanticBlock(
            next.snapshot.document.content.firstBlock.block
        ))
        #expect(block.runs.map(\.text).joined().utf16.elementsEqual(
            "e\u{0301}".utf16
        ))
        #expect(next.snapshot.document.revision.value == 9)
        #expect(next.snapshot.generation.value == 4)
        #expect(next.selection.range.start.utf16Offset.value == 2)
        let original = try #require(EditableSemanticBlock(
            fixture.editable.snapshot.document.content.firstBlock.block
        ))
        #expect(original.runs.map(\.text).joined().utf16.elementsEqual(
            "\u{00E9}".utf16
        ))
    }
}
