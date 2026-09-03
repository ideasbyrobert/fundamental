import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

@Suite("Raster interaction roles")
struct RasterInteractionRoleTests
{
    @MainActor
    @Test("body title every section level and code retain exact roles")
    func textRoles() throws
    {
        let sections = SemanticHeadingLevel.allCases.map
        {
            SemanticBlock.heading(.section(SectionSemanticHeading(
                runs: [RasterFixture.run("Section \($0.rawValue)")],
                level: $0
            )))
        }
        let blocks = [
            SemanticBlock.paragraph(SemanticParagraph(runs: [
                RasterFixture.run("Body")
            ])),
            .heading(.title(TitleSemanticHeading(runs: [
                RasterFixture.run("Title")
            ])))
        ] + sections + [
            .code(.plain(PlainSemanticCodeBlock(runs: [
                RasterFixture.run("let value = 1")
            ])))
        ]
        let layout = try RasterFixture.layout(blocks, width: 800)
        let raster = try RasterFixture.snapshot(
            RasterFixture.viewport(layout)
        )
        let roles: [RasterInteractionRole]
        roles = raster.interactionMap.regions.compactMap
        {
            guard case .text = $0.content else { return nil }
            return $0.role
        }
        #expect(roles == [
            .body,
            .title,
            .section(.one),
            .section(.two),
            .section(.three),
            .section(.four),
            .section(.five),
            .section(.six),
            .code
        ])
    }
}
