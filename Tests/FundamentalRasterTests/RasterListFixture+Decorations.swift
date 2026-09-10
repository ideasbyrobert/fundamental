import Testing

@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterListFixture
{
    static func expectDecorations(
        _ line: LayoutLine, owner: RasterResidentID, raster: RasterSnapshot
    ) throws
    {
        let specification = raster.lineage.specification
        let actual: [RasterFill] = raster.marks.compactMap
        {
            guard case let .fill(fill) = $0, fill.residentID == owner
            else { return nil }
            return fill
        }
        let expected = line.glyphRuns.flatMap(\.decorations).filter
        {
            (try? bounds($0.frame).intersection(
                specification.logicalBounds
            )) != nil
        }
        #expect(actual.count == expected.count)
        for (fill, native) in zip(actual, expected)
        {
            let role: RasterFillRole = native.kind == .underline
                ? .underline : .strikethrough
            #expect(fill.role == role)
            let clip = try #require(bounds(native.frame).intersection(
                specification.logicalBounds
            ))
            #expect(fill.logicalBounds == clip)
            #expect(fill.pixelBounds == RasterPixelBounds(
                logicalBounds: clip, backingScale: specification.backingScale
            ))
            #expect(fill.color == specification.palette.decoration)
            #expect(fill.sourceSlices
                == RasterFixture.expectedSlices(native.sourceSlices))
        }
    }
}
