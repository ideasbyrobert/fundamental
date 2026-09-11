import FundamentalDocument
import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@MainActor
@Suite("Generated hyphen ink preserves the canonical document")
struct AutomaticSessionTests
{
    @Test
    func shapingKeepsEncodedTextSelectionAndHistoryUnchanged() throws
    {
        let language = try WordFixture.language("ru_RU")
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let session = try ParagraphSessionFixture.session([
            WordFixture.run("👩‍💻 "),
            WordFixture.scoped(
                "раи", .linkAndLanguage(link: link, language: language),
                traits: [.strong]
            ),
            WordFixture.run("", traits: [.inlineCode]),
            WordFixture.scoped(
                "\u{306}", .language(language), traits: [.emphasis]
            ),
            WordFixture.scoped("он", .language(language))
        ])
        let state = session.state
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let encoded = try codec.encode(session.document)
        let source = try ParagraphSessionFixture.source(session)
        let collection = try AutomaticFixture.collection(
            source, language: .russian
        )
        let ink = try #require(collection.inks.first)
        #expect(collection.inks.count == 1)
        #expect(ink.sourceRange == 10..<10)
        #expect(ink.character == 8..<10)
        #expect(ink.context.map(\.runIndex) == [1, 3])
        #expect(ink.styleOrigin.runIndex == 1)
        let line = try AutomaticFixture.line(
            collection, range: 0..<10,
            end: .automatic(collection.selectAutomatic(0))
        )
        #expect(line.display.units == Array(source.source.utf16[0..<10])
            + [0x2010])
        #expect(line.runs.flatMap(\.glyphs).flatMap(\.sources)
            .contains(.generated(ink)))
        #expect(try ExplicitFixture.reconstructed(line.display.body.slice)
            == Array(source.source.utf16[0..<10]))
        #expect(session.state == state)
        #expect(try codec.encode(session.document) == encoded)
        #expect(try codec.decode(encoded) == session.document)
        #expect(!session.isDirty && !session.canUndo && !session.canRedo)
        #expect(collection.source.paragraph.runs == source.paragraph.runs)
    }
}
