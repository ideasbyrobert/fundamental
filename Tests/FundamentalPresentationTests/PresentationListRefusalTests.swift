import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

@Suite("Explicit list presentation admission boundary")
@MainActor
struct PresentationListRefusalTests
{
    @Test("list glyph provenance and marker text cannot be silently dropped",
          arguments: SemanticListKind.allCases, ["", "Source"])
    func firstLine(kind: SemanticListKind, source: String) throws
    {
        let layout = try PresentationFixture.layout([
            .listItem(SemanticListItem(
                kind: kind, runs: [PresentationFixture.run(source)]
            ))
        ])
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(layout)
        )
        let composer = PresentationComposer()
        let lineage = try #require(composer.rasterLineage(of: raster))
        let request = try PresentationFixture.request(raster)
        #expect(composer.present(raster, request: request) == nil)
        guard case let .text(text) = raster.interactionMap.firstRegion.content
        else
        {
            Issue.record("Expected list text")
            return
        }
        #expect(text.marker != nil)
        #expect(PresentationComposer.textLine(text) == nil)
        var generated = 0
        for mark in raster.marks
        {
            guard case let .glyphs(batch) = mark,
                  case .listMarker = batch.source
            else { continue }
            generated += 1
            #expect(PresentationComposer.glyphBatch(
                batch, specification: lineage.specification
            ) == nil)
        }
        #expect(generated > 0)
    }

    @Test("continuations refuse even when their marker is not resident")
    func continuation() throws
    {
        let layout = try PresentationFixture.layout([
            .listItem(SemanticListItem(kind: .numbered, runs: [
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
        let request = try PresentationFixture.request(raster)
        #expect(PresentationComposer().present(raster, request: request) == nil)
    }
}
