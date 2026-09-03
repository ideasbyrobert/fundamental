import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

@Suite("Raster run scope evidence")
struct RasterScopeTests
{
    @MainActor
    @Test("direct link language and joined scopes survive exactly")
    func scopes() throws
    {
        let link = try #require(SemanticLinkDestination(
            "https://fundamental.test"
        ))
        let language = try #require(SemanticLanguageIdentifier("en-US"))
        let runs: [SemanticRun] = [
            RasterFixture.run("D"),
            .scoped(SemanticScopedRun(
                text: "L",
                traits: [.underline],
                scopes: .link(link)
            )),
            .scoped(SemanticScopedRun(
                text: "G",
                scopes: .language(language)
            )),
            .scoped(SemanticScopedRun(
                text: "B",
                scopes: .linkAndLanguage(
                    link: link,
                    language: language
                )
            ))
        ]
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: runs))
        let layout = try RasterFixture.layout([block], width: 400)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout)
        )
        guard case let .text(text) = raster.interactionMap
            .firstRegion.content
        else
        {
            Issue.record("Expected text interaction")
            return
        }
        #expect(text.sourceSlices.map(\.scope) == [
            .direct,
            .link("https://fundamental.test"),
            .language("en-US"),
            .linkAndLanguage(
                link: "https://fundamental.test",
                language: "en-US"
            )
        ])
        let markScopes: [RasterRunScope] = raster.marks.flatMap
        {
            switch $0
            {
            case let .glyphs(batch):
                return batch.sourceSlices.map(\.scope)
                    + batch.glyphs.flatMap(\.sourceSlices).map(\.scope)
            case let .fill(fill):
                return fill.sourceSlices.map(\.scope)
            }
        }
        guard let decoration = raster.marks.first(where:
        {
            guard case let .fill(fill) = $0 else { return false }
            return fill.role == .underline
        })
        else
        {
            Issue.record("Expected scoped decoration")
            return
        }
        guard case let .fill(fill) = decoration
            else
            {
                Issue.record("Expected fill")
                return
            }
        #expect(fill.sourceSlices.map(\.scope)
            == [.link("https://fundamental.test")])
        for scope in text.sourceSlices.map(\.scope)
        {
            #expect(markScopes.contains { $0 == scope })
        }
    }
}
