import Testing

@testable import FundamentalMacOracle

@Suite("Native Reader input from one immutable document", .serialized)
@MainActor
struct MacReaderDocumentInputTests
{
    @Test("the requested canonical source replaces the demonstration")
    func requestedDocumentIsTheReaderSource() throws
    {
        let text = "The Reader receives this document. e\u{301} 😀 Раздел."
        let source = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.paragraph(text)
        ])
        let model = try MacReaderDocumentFixture.model(source)
        let identifiers = Set(
            model.snapshot.presentedDocument.residents.all.map
            {
                $0.residentID.blockID
            }
        )
        #expect(identifiers == Set(source.document.content.blocks.map
        {
            $0.blockID.value
        }))
        #expect(MacReaderDocumentFixture.texts(model).joined() == text)
        #expect(model.layoutExecutionCount == 1)
    }
}
