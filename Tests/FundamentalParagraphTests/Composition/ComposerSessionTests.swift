import FundamentalDocument
import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@MainActor
struct ComposerSessionTests
{
    @Test func lineChoicesPreserveEncodedDocumentSelectionAndHistory() throws
    {
        let russian = try WordFixture.language("ru_RU")
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let session = try ParagraphSessionFixture.session([
            WordFixture.run("👩‍💻 extraordinary re\u{AD}presentation "),
            WordFixture.scoped(
                "раи", .linkAndLanguage(link: link, language: russian),
                traits: [.strong]
            ),
            WordFixture.run("", traits: [.inlineCode]),
            WordFixture.scoped(
                "\u{306}", .language(russian), traits: [.emphasis]
            ),
            WordFixture.scoped("он", .language(russian))
        ])
        let state = session.state
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let encoded = try codec.encode(session.document)
        let source = try ParagraphSessionFixture.source(session)
        let collection = try AutomaticFixture.collection(source)
        var generated = false
        for width in [60.0, 90, 140]
        {
            let paragraph = try ParagraphComposition(collection, width: width)
            {
                try ShapingFixture.attributes($0, size: 18)
            }
            try ParagraphAssertions.verify(paragraph)
            for glyph in paragraph.segments.flatMap(\.lines)
                .flatMap({ $0.shaped.runs }).flatMap(\.glyphs)
            {
                for case let .generated(ink) in glyph.sources
                {
                    #expect(ink.sourceRange.isEmpty)
                    generated = true
                }
            }
            #expect(paragraph.collection.source.paragraph == source.paragraph)
            #expect(session.state == state)
            #expect(try codec.encode(session.document) == encoded)
            #expect(!session.isDirty && !session.canUndo && !session.canRedo)
        }
        #expect(generated)
        #expect(try codec.decode(encoded) == session.document)
    }
}
