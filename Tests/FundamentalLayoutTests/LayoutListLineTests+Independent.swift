import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutListLineTests
{
    @MainActor
    @Test("independent and reversed items preserve eager list identity")
    func independentItems() throws
    {
        let blocks = (0 ..< 100).map
        {
            index in
            SemanticBlock.listItem(SemanticListItem(
                kind: .numbered, runs: [LayoutFixture.direct(
                    index.isMultiple(of: 3) ? "" : "Item\nContinuation"
                )]
            ))
        }
        let projection = try LayoutFixture.projection(blocks)
        let native = NativeTextKit2Layout()
        let request = try LayoutFixture.request(width: 220)
        let eager = try native.layout(projection, request: request)
        for block in projection.blocks.reversed()
        {
            let fragments = eager.fragments.filter
            {
                $0.source == block.source
            }
            let origin = try #require(fragments.first).frame.minY
            let independent = try native.blockLayout(
                block, originY: origin, parameters: request.parameters
            )
            #expect(independent.fragments == fragments)
            let measurement = try native.measure(
                block, parameters: request.parameters
            )
            #expect(measurement.extents.map(\.source)
                == fragments.map(\.source))
            #expect(measurement.extents.map(\.anchor)
                == fragments.map(\.anchor))
            #expect(measurement.extents.map { $0.frame.size }
                == fragments.map { $0.frame.size })
            let fragment = try #require(fragments.first)
            guard case let .lines(first) = fragment
            else
            {
                Issue.record("Expected a list line")
                continue
            }
            let marker = try #require(first.line.marker)
            #expect(marker.source.label == "\(block.source.ordinal + 1).")
            #expect(marker.source.position.count == 100)
            #expect(marker.glyphRuns.allSatisfy
            {
                measurement.contentFonts.contains($0.font)
            })
        }
    }
}
