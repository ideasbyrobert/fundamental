import Testing

@testable import FundamentalLayout

@Suite("Zero-row table track evidence")
struct RasterZeroRowTableTests
{
    @MainActor
    @Test(arguments: [false, true])
    func columnsOwnStructuralBands(captioned: Bool) throws
    {
        let block = captioned
            ? try RasterFixture.captionedZeroRowTable()
            : try RasterFixture.zeroRowTable()
        let layout = try RasterFixture.layout([block], width: 300)
        let fragments: [LayoutGridFragment] = layout.fragments.compactMap
        {
            guard case let .grid(fragment) = $0 else { return nil }
            return fragment
        }
        let columns: [LayoutRectangle] = fragments.compactMap
        {
            guard case .columnTrack = $0.content else { return nil }
            return $0.frame
        }
        #expect(columns.count == 2)
        #expect(columns.allSatisfy { $0.size.height > 0 })
        let captionMaximum: Double? = fragments.compactMap
        {
            guard case let .captionLine(line) = $0.content
            else
            {
                return nil
            }
            return line.frame.maxY
        }.max()
        if let captionMaximum
        {
            #expect(columns.allSatisfy
            {
                $0.minY >= captionMaximum
            })
        }
    }
}
