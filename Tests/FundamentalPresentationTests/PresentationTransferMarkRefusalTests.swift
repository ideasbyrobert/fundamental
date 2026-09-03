import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationTransferTests
{
    @MainActor
    @Test("a mark sourced from another resident domain refuses atomically")
    func foreignMarkSourceRefuses() throws
    {
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run(
                            "Underlined",
                            traits: [.underline]
                        )
                    ])),
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("Foreign")
                    ]))
                ])
            )
        )
        let poisoned = try PresentationFixture
            .rasterWithForeignFillSource(raster)
        #expect(PresentationComposer().present(
            poisoned,
            request: try PresentationFixture.request(poisoned)
        ) == nil)
    }
}
