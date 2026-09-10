import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

@Suite("Exact list presentation transport")
@MainActor
struct PresentationListTransportTests
{
    @Test("source and generated ink retain every transported fact",
          arguments: SemanticListKind.allCases, [
            "", "Source", "e\u{301} 👩🏽‍💻 Հայերեն Раздел",
            "First\nSecond", "\n"
          ])
    func firstLine(kind: SemanticListKind, source: String) throws
    {
        let raster = try PresentationListFixture.raster(kind, text: source)
        let snapshot = try PresentationFixture.snapshot(raster)
        try PresentationListFixture.expectTransfer(raster, snapshot)
        let residents = snapshot.presentedDocument.residents.all
        #expect(residents.compactMap(\.content.textLine).map(\.text)
            .joined().utf16.elementsEqual(source.utf16))
        #expect(residents.compactMap(\.content.listMarker).count == 1)
        let second = try #require(PresentationComposer().present(
            raster,
            request: PresentationFixture.request(raster, generation: 20),
            reusing: snapshot
        ))
        #expect(snapshot.presentedDocument.storage
            === second.presentedDocument.storage)
        #expect(zip(residents, second.presentedDocument.residents.all)
            .allSatisfy { $0.storage === $1.storage })
    }

    @Test("continuations retain context without a resident marker",
          arguments: SemanticListKind.allCases)
    func continuation(kind: SemanticListKind) throws
    {
        let layout = try PresentationFixture.layout([
            .listItem(SemanticListItem(kind: kind, runs: [
                PresentationFixture.run(
                    "Readable source continues across several visual lines."
                )
            ]))
        ], width: 180)
        let fragment = try #require(layout.fragments.dropFirst().first)
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                layout, y: fragment.frame.minY + 0.5,
                height: fragment.frame.size.height - 1
            )
        )
        let snapshot = try PresentationFixture.snapshot(raster)
        try PresentationListFixture.expectTransfer(raster, snapshot)
        let residents = snapshot.presentedDocument.residents.all
        #expect(residents.allSatisfy { $0.residentID.fragmentOrdinal > 0 })
        #expect(residents.allSatisfy { $0.content.listMarker == nil })
        #expect(residents.allSatisfy
        {
            $0.content.listItem?.position.index == 0
                && $0.content.listItem?.position.count == 1
        })
    }
}
