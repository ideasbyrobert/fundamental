import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    @MainActor
    @Test("Unicode source scope font and caret evidence remain exact")
    func textEvidence() throws
    {
        let link = try #require(SemanticLinkDestination("https://f.test"))
        let language = try #require(SemanticLanguageIdentifier("hy"))
        let runs: [SemanticRun] = [
            PresentationFixture.run("e\u{301} "),
            .scoped(SemanticScopedRun(
                text: "👨‍👩‍👧‍👦",
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
                ], width: 500)
            )
        )
        let presented = try PresentationFixture.snapshot(raster)
        let line = try #require(
            PresentationFixture.textResidents(presented).first?.1
        )
        guard case let .text(source) = raster.interactionMap
            .firstRegion.content
        else
        {
            Issue.record("Expected text evidence")
            return
        }
        #expect(line.text == source.text)
        #expect(line.lineBounds.minX == source.lineBounds.minX)
        #expect(line.lineBounds.minY == source.lineBounds.minY)
        #expect(line.baseline.x == source.baseline.x)
        #expect(line.baseline.y == source.baseline.y)
        #expect(line.defaultFont.postScriptName
            == source.defaultFont.postScriptName)
        #expect(line.defaultFont.uniqueName == source.defaultFont.uniqueName)
        #expect(line.defaultFont.versionName
            == source.defaultFont.versionName)
        #expect(line.defaultFont.pointSize == source.defaultFont.pointSize)
        #expect(line.sourceSlices.map(\.text)
            == source.sourceSlices.map(\.text))
        #expect(line.sourceSlices.map(\.range)
            == source.sourceSlices.map(\.range))
        #expect(line.caretSites.map(\.utf16Offset)
            == source.caretSites.map(\.utf16Offset))
        #expect(line.caretSites.map(\.position.x)
            == source.caretSites.map(\.position.x))
        #expect(line.sourceSlices.map(\.scope).contains
        {
            $0 == .linkAndLanguage(
                link: "https://f.test",
                language: "hy"
            )
        })
    }
}
