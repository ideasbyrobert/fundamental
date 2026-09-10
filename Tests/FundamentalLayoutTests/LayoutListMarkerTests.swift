import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Native generated list marker shaping")
struct LayoutListMarkerTests
{
    @MainActor
    @Test("marker glyphs never acquire canonical text slices")
    func generatedProvenance() throws
    {
        let native = NativeTextKit2Layout()
        for kind in SemanticListKind.allCases
        {
            for text in ["", "e\u{301}😀 Раздел", "First\nSecond"]
            {
                let runs = text.isEmpty ? [] : [try LayoutFixture.scoped(text)]
                let projection = try LayoutFixture.projection([
                    .listItem(SemanticListItem(kind: kind, runs: runs))
                ])
                guard case let .prose(block, prose) = projection.firstBlock
                else
                {
                    Issue.record("Expected projected list prose")
                    continue
                }
                let source = try #require(LayoutListMarkerSource(
                    block: block, role: prose.role
                ))
                let marker = try native.listMarker(
                    source, baselineX: 19.25, baselineY: 37.5
                )
                #expect(marker.source.block == block)
                #expect(marker.source.role == prose.role)
                #expect(marker.advance > 0)
                #expect(marker.inkBounds.size.width > 0)
                #expect(marker.inkBounds.size.height > 0)
                #expect(marker.glyphRuns.map(\.paintOrder)
                    == Array(marker.glyphRuns.indices))
                for run in marker.glyphRuns
                {
                    #expect(run.sourceSlices.isEmpty)
                    #expect(run.decorations.isEmpty)
                    #expect(run.style.baselineOffset == 0)
                    #expect(run.glyphs.allSatisfy { $0.sourceSlices.isEmpty })
                }
                #expect(prose.runs.map(\.text).joined() == text)
                let snapshot = try native.layout(projection,
                    request: LayoutFixture.request(width: 240))
                if case let .lines(fragment) = snapshot.firstFragment
                {
                    #expect(fragment.line.marker?.source == source)
                }
                else
                {
                    Issue.record("Expected list line")
                }
            }
        }
    }
}
