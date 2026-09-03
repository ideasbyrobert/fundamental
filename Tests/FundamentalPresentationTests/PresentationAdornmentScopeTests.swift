import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("selection trims text while preserving every exact scope")
    func selectionPreservesTrimmedScopes() throws
    {
        let link = try #require(SemanticLinkDestination("https://scope.test"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let runs: [SemanticRun] = [
            PresentationFixture.run("ab"),
            .scoped(SemanticScopedRun(
                text: "cd",
                scopes: .link(link)
            )),
            .scoped(SemanticScopedRun(
                text: "ef",
                scopes: .language(language)
            )),
            .scoped(SemanticScopedRun(
                text: "gh",
                scopes: .linkAndLanguage(
                    link: link,
                    language: language
                )
            ))
        ]
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: runs))
                ], width: 400)
            )
        )
        let snapshot = try PresentationFixture.snapshot(raster)
        let line = try #require(
            PresentationFixture.textResidents(snapshot).first
        )
        let lower = try PresentationFixture.position(
            line.0,
            line: line.1,
            caret: 1
        )
        let upper = try PresentationFixture.position(
            line.0,
            line: line.1,
            caret: 7
        )
        let result = try selection(raster, anchor: lower, focus: upper)
        #expect(result.text == "bcdefg")
        #expect(result.sourceSlices.map(\.text) == ["b", "cd", "ef", "g"])
        #expect(result.sourceSlices.map(\.range)
            == [1 ..< 2, 2 ..< 4, 4 ..< 6, 6 ..< 7])
        #expect(result.sourceSlices.map(\.scope) == [
            .direct,
            .link("https://scope.test"),
            .language("hy"),
            .linkAndLanguage(link: "https://scope.test", language: "hy")
        ])
    }
}
