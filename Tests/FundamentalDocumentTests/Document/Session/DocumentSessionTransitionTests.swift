import Testing

@testable import FundamentalDocument

@Suite("Immutable session succession")
struct DocumentSessionTransitionTests
{
    @Test(
        "all five edits preserve specialized document and caret succession",
        arguments: SessionTestEdit.allCases
    )
    func specializedParity(_ form: SessionTestEdit) throws
    {
        let fixture = try SessionTestDocument()
        let edit = try form.edit(in: fixture)
        let expected = try Self.specialized(edit, in: fixture.state)
        let result = DocumentSessionTransition(
            .edit(fixture.observation, edit),
            in: fixture.state
        )
        let editable = try Self.editable(result)
        #expect(editable.snapshot.document == expected.0)
        #expect(editable.selection == .caret(at: expected.1.point))
        #expect(editable.snapshot.generation.value == 4)
        #expect(editable.snapshot.document.revision.value == 9)
        try Self.expectSpelling(editable.snapshot.document, expected.0)
    }

    @Test("the retained source remains unchanged after succession")
    func immutableSource() throws
    {
        let fixture = try SessionTestDocument(texts: ["e\u{0301}BCD", "EF"])
        let source = fixture.state
        let original = source.snapshot.document
        let edit = try SessionTestEdit.inserted("X", at: fixture.point(0))
        _ = try Self.editable(DocumentSessionTransition(
            .edit(fixture.observation, edit),
            in: source
        ))
        #expect(source == fixture.state)
        #expect(source.snapshot.generation.value == 3)
        #expect(source.snapshot.document.revision.value == 8)
        try Self.expectSpelling(source.snapshot.document, original)
        let runs = try #require(EditableSemanticBlock(
            source.snapshot.document.content.blocks[0].block
        )).runs
        #expect(runs.map(\.text).joined().utf16.elementsEqual(
            "e\u{0301}BCD".utf16
        ))
    }
}
