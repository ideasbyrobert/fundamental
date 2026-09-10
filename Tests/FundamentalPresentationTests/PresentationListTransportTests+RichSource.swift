import Testing

@testable import FundamentalDocument

extension PresentationListTransportTests
{
    @Test("all traits and scopes preserve complete list transport",
          arguments: SemanticListKind.allCases, [
            SemanticInlineTrait.strong, .emphasis, .underline,
            .strikethrough, .inlineCode, .superscript, .subscriptText
          ])
    func richSource(kind: SemanticListKind, trait: SemanticInlineTrait) throws
    {
        let link = try #require(SemanticLinkDestination(
            "https://example.invalid"
        ))
        let language = try #require(SemanticLanguageIdentifier("ru-RU"))
        let runs: [SemanticRun] = [
            SemanticRun(text: "Direct ", traits: [trait]),
            .scoped(SemanticScopedRun(text: "Link ", scopes: .link(link))),
            .scoped(SemanticScopedRun(text: "Язык ",
                                      scopes: .language(language))),
            .scoped(SemanticScopedRun(
                text: "Both 👩🏽‍💻",
                scopes: .linkAndLanguage(link: link, language: language)
            ))
        ]
        let layout = try PresentationFixture.layout([
            .listItem(SemanticListItem(kind: kind, runs: runs))
        ], width: 500)
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(layout)
        )
        try PresentationListFixture.expectTransfer(
            raster, PresentationFixture.snapshot(raster)
        )
    }

    @Test("all one hundred positions preserve marker and source facts",
          arguments: SemanticListKind.allCases)
    func numbering(kind: SemanticListKind) throws
    {
        let raster = try PresentationListFixture.raster(
            kind, text: "Value", count: 100, width: 240
        )
        let snapshot = try PresentationFixture.snapshot(raster)
        try PresentationListFixture.expectTransfer(raster, snapshot)
        let items = snapshot.presentedDocument.residents.all
            .compactMap(\.content.listItem)
        #expect(items.count == 100)
        #expect(items.map(\.position.index) == Array(0 ..< 100))
        #expect(items.allSatisfy { $0.position.count == 100 })
    }
}
