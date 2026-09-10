import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle

@Suite("Canonical lists in the native Reader", .serialized)
@MainActor
struct MacReaderListTests
{
    @Test("a supplied list reaches native Reader resources",
          arguments: SemanticListKind.allCases)
    func suppliedList(kind: SemanticListKind) throws
    {
        let text = "Exact e\u{301} 👩🏽‍💻 Հայերեն Раздел"
        let source = try MacReaderDocumentFixture.source([
            .listItem(SemanticListItem(
                kind: kind, runs: [SemanticRun(text: text)]
            ))
        ])
        let retained = source
        let model = try MacReaderDocumentFixture.model(source)
        #expect(MacReaderDocumentFixture.texts(model).joined() == text)
        #expect(source == retained)
    }
}
