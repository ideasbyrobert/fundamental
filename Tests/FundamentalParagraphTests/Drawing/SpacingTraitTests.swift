@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import CoreText
import Testing

@MainActor
struct SpacingTraitTests
{
    @Test func everyTraitRetainsNativeFontsBaselinesAndDecorations() throws
    {
        for traits in NativeWordScopeTests.allowedTraits
        {
            let name = traits.map(\.rawValue).sorted().joined(separator: "-")
            let source = try WordFixture.source([
                WordFixture.run("AVATAR a b", traits: traits)
            ])
            let value = try AutomaticFixture.collection(source)
            for size in [18.0, 36]
            {
                let shaped = try AutomaticFixture.line(
                    value, range: 0..<10, size: size
                )
                let natural = try SpacedNativeLine(
                    SpacingFixture.plan(shaped, amount: 0)
                )
                if !traits.contains(.underline)
                    && !traits.contains(.strikethrough)
                {
                    let reference = try SpacingRaster(
                        width: natural.advance + 64, height: 128, scale: 2
                    )
                    {
                        $0.textMatrix = .identity
                        $0.textPosition = SpacingFixture.origin
                        CTLineDraw(shaped.measurement.native!, $0)
                    }
                    let actual = try SpacingFixture.raster(natural)
                    try SpacingDifference.record(
                        "traits-natural-\(name)-\(Int(size))", actual, reference
                    )
                    #expect(actual.bytes == reference.bytes,
                            "Trait \(name) at size \(size)")
                }
                for amount in [-0.5, 2.0]
                {
                    let line = try SpacedNativeLine(
                        SpacingFixture.plan(shaped, amount: amount)
                    )
                    try SpacingAssertions.geometry(line)
                    let decorations = line.runs.flatMap(\.decorations)
                    let decorated = traits.contains(.underline)
                        || traits.contains(.strikethrough)
                    #expect(decorations.count == (decorated ? 1 : 0))
                    for decoration in decorations
                    {
                        #expect(abs(decoration.bounds.width - line.advance)
                            < 0.000001)
                        #expect(!decoration.sources.isEmpty)
                    }
                    let raster = try SpacingFixture.raster(line)
                    SpacingAssertions.unclipped(raster)
                    try SpacingEvidence.write(
                        "traits-\(name)-\(Int(size))-\(amount)",
                        line: line, raster: raster
                    )
                }
            }
        }
    }
}
