import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

extension RasterListTransportTests
{
    @Test("all inline traits preserve source and generated marker separation",
          arguments: SemanticListKind.allCases, [
              SemanticInlineTrait.strong, .emphasis, .underline,
              .strikethrough, .inlineCode, .superscript, .subscriptText
          ])
    func traits(kind: SemanticListKind, trait: SemanticInlineTrait) throws
    {
        let source = "Office e\u{301} 👩🏽‍💻"
        let layout = try RasterFixture.layout([
            RasterListFixture.block(kind, source, traits: [trait])
        ], width: 400)
        let raster = try RasterFixture.snapshot(RasterFixture.viewport(layout))
        for (line, region) in zip(
            RasterListFixture.lines(layout), raster.interactionMap.regions
        )
        {
            try RasterListFixture.expect(line, region: region, raster: raster)
        }
        #expect(RasterListFixture.texts(raster).map(\.text) == [source])
    }

    @Test("scoped list text retains destinations language and decorations",
          arguments: SemanticListKind.allCases)
    func scopes(kind: SemanticListKind) throws
    {
        let link = try #require(SemanticLinkDestination("https://list.test"))
        let language = try #require(SemanticLanguageIdentifier("ru"))
        let runs: [SemanticRun] = [
            RasterFixture.run("D"),
            .scoped(SemanticScopedRun(
                text: "L", traits: [.underline], scopes: .link(link)
            )),
            .scoped(SemanticScopedRun(
                text: "Я", scopes: .language(language)
            )),
            .scoped(SemanticScopedRun(
                text: "e\u{301}👩🏽‍💻", traits: [.strikethrough],
                scopes: .linkAndLanguage(link: link, language: language)
            ))
        ]
        let layout = try RasterFixture.layout([
            .listItem(SemanticListItem(kind: kind, runs: runs))
        ], width: 400)
        let raster = try RasterFixture.snapshot(RasterFixture.viewport(layout))
        for (line, region) in zip(
            RasterListFixture.lines(layout), raster.interactionMap.regions
        )
        {
            try RasterListFixture.expect(line, region: region, raster: raster)
        }
        #expect(RasterListFixture.texts(raster).flatMap(\.sourceSlices)
            .map(\.scope) == [
                .direct, .link("https://list.test"), .language("ru"),
                .linkAndLanguage(link: "https://list.test", language: "ru")
            ])
    }
}
