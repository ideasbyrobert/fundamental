import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle

extension MacReaderDocumentInputTests
{
    @Test("supplied lists never become a demonstration document",
          arguments: SemanticListKind.allCases, [false, true])
    func listAdmission(kind: SemanticListKind, mixed: Bool) throws
    {
        let text = "A supplied list item"
        let list = MacReaderListFixture.block(kind, text)
        let blocks = mixed
            ? [MacReaderDocumentFixture.paragraph("Before the list."), list]
            : [list]
        let source = try MacReaderDocumentFixture.source(blocks)
        let retained = source
        let expected = mixed ? "Before the list." + text : text
        let model = try MacReaderDocumentFixture.model(source)
        #expect(MacReaderDocumentFixture.texts(model).joined() == expected)
        let controller = try MacReaderDocumentFixture.window(source)
        let window = try #require(controller.window)
        defer { window.close() }
        #expect(MacReaderDocumentFixture.texts(controller.readerView.model)
            .joined() == expected)
        #expect(source == retained)
    }
}
