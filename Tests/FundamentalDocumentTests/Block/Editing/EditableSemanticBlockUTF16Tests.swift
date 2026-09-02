import Testing

@testable import FundamentalDocument

@Suite("Editable semantic block UTF-16 measurement")
struct EditableSemanticBlockUTF16Tests
{
    @Test("measurement preserves composed and decomposed spelling")
    func measurementPreservesSourceSpelling() throws
    {
        let composed = try Self.editable(["Café ", "🌍"])
        let decomposed = try Self.editable(["Cafe", "\u{301} ", "🌍"])

        #expect(composed.utf16Count == 7)
        #expect(decomposed.utf16Count == 8)
    }

    @Test("empty text admits only its zero boundary")
    func emptyTextAdmitsOnlyZero() throws
    {
        let editable = try Self.editable([])

        #expect(editable.utf16Count == 0)
        #expect(editable.admitsCharacterBoundary(at: try Self.offset(0)))
        #expect(!editable.admitsCharacterBoundary(at: try Self.offset(1)))
    }

    @Test("ASCII beginning interior and end are boundaries")
    func asciiBoundariesAreAdmitted() throws
    {
        let editable = try Self.editable(["ABC"])

        for value in 0...3
        {
            #expect(editable.admitsCharacterBoundary(
                at: try Self.offset(value)
            ))
        }
    }

    @Test("offsets beyond measured text are refused")
    func outOfBoundsOffsetsAreRefused() throws
    {
        let editable = try Self.editable(["ABC"])

        #expect(!editable.admitsCharacterBoundary(at: try Self.offset(4)))
    }

    static func editable(
        _ texts: [String]
    ) throws -> EditableSemanticBlock
    {
        let runs = texts.map { SemanticRun(text: $0) }
        let block = SemanticBlock.paragraph(
            SemanticParagraph(runs: runs)
        )
        return try #require(EditableSemanticBlock(block))
    }

    static func offset(
        _ value: Int
    ) throws -> DocumentUTF16Offset
    {
        try #require(DocumentUTF16Offset(value))
    }
}
