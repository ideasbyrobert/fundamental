import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle

extension MacReaderListTests
{
    @Test("native numbering retains every item through one hundred",
          arguments: SemanticListKind.allCases)
    func numbering(kind: SemanticListKind) throws
    {
        let texts = (1 ... 100).map { "Value \($0)" }
        let source = try MacReaderDocumentFixture.source(texts.map
        {
            MacReaderListFixture.block(kind, $0)
        })
        let model = try MacReaderDocumentFixture.model(
            source, width: 500, height: 5_000
        )
        let residents = model.snapshot.presentedDocument.residents.all
        try #require(residents.count == 100)
        #expect(MacReaderDocumentFixture.texts(model) == texts)
        for (index, resident) in residents.enumerated()
        {
            let item = try #require(resident.content.listItem)
            let marker = try #require(resident.content.listMarker)
            #expect(item.position.index == index)
            #expect(item.position.count == 100)
            #expect(marker.source.item == item)
            #expect(marker.source.residentID == resident.residentID)
            #expect(marker.source.label
                == (kind == .bulleted ? "•" : "\(index + 1)."))
        }
    }

    @Test("kind changes and intervening paragraphs restart independent lists")
    func independentLists() throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderListFixture.block(.bulleted, "Bullet one"),
            MacReaderListFixture.block(.bulleted, "Bullet two"),
            MacReaderListFixture.block(.numbered, "Number one"),
            MacReaderListFixture.block(.numbered, "Number two"),
            MacReaderDocumentFixture.paragraph("Between lists"),
            MacReaderListFixture.block(.numbered, "Restart number"),
            MacReaderListFixture.block(.bulleted, "Restart bullet")
        ])
        let model = try MacReaderDocumentFixture.model(source)
        let items = model.snapshot.presentedDocument.residents.all
            .compactMap(\.content.listItem)
        #expect(items.map(\.position.index) == [0, 1, 0, 1, 0, 0])
        #expect(items.map(\.position.count) == [2, 2, 2, 2, 1, 1])
        #expect(items.map(\.label) == ["•", "•", "1.", "2.", "1.", "•"])
    }
}
