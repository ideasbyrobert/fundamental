import Testing

@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    @Test("empty semantic forms preserve exact measurement and block spacing")
    func emptyFontGeometry() throws
    {
        let native = NativeTextKit2Layout()
        for runs in try LayoutEmptyFontFixture.emptyRuns()
        {
            let blocks = try LayoutEmptyFontFixture.blocks(runs)
            let request = try LayoutFixture.request(width: 240)
            let snapshot = try native.layout(
                LayoutFixture.projection(blocks), request: request
            )
            var nextY = 0.0
            for (index, block) in blocks.enumerated()
            {
                let result = try product(block, width: 240)
                expectParity(result.measurement, result.snapshot)
                let extent = try #require(result.measurement.extents.first)
                let fragment = snapshot.fragments[index]
                #expect(fragment.frame.minY == nextY)
                #expect(fragment.frame.size.height == extent.frame.size.height)
                nextY += extent.frame.size.height
                if index < blocks.count - 1
                {
                    nextY += request.parameters.blockSpacing
                }
            }
            #expect(snapshot.size.height == nextY)
        }
    }
}
