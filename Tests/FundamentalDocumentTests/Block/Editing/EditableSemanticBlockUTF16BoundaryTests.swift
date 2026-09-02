import Testing

@testable import FundamentalDocument

extension EditableSemanticBlockUTF16Tests
{
    @Test("a surrogate-pair interior is refused")
    func surrogatePairInteriorIsRefused() throws
    {
        let editable = try Self.editable(["A🌍B"])

        #expect(!editable.admitsCharacterBoundary(at: try Self.offset(2)))
        #expect(editable.admitsCharacterBoundary(at: try Self.offset(1)))
        #expect(editable.admitsCharacterBoundary(at: try Self.offset(3)))
    }

    @Test("a decomposed grapheme interior is refused")
    func decomposedGraphemeInteriorIsRefused() throws
    {
        let editable = try Self.editable(["e\u{301}"])

        #expect(!editable.admitsCharacterBoundary(at: try Self.offset(1)))
        #expect(editable.admitsCharacterBoundary(at: try Self.offset(2)))
    }

    @Test("ZWJ and flag grapheme interiors are refused")
    func complexGraphemeInteriorsAreRefused() throws
    {
        for text in ["👩‍💻", "🇦🇲"]
        {
            let editable = try Self.editable([text])
            for value in 1..<editable.utf16Count
            {
                #expect(!editable.admitsCharacterBoundary(
                    at: try Self.offset(value)
                ))
            }
        }
    }

    @Test("a grapheme spanning a run boundary stays indivisible")
    func crossRunGraphemeInteriorIsRefused() throws
    {
        let editable = try Self.editable(["e", "\u{301}"])

        #expect(editable.utf16Count == 2)
        #expect(!editable.admitsCharacterBoundary(at: try Self.offset(1)))
    }
}
