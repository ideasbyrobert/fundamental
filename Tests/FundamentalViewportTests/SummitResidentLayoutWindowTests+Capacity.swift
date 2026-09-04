import Testing

@testable import FundamentalLayout
@testable import FundamentalViewport

extension SummitResidentLayoutWindowTests
{
    @Test("capacity refusal publishes nothing and preserves the index")
    func capacityRefusalAndRecovery() throws
    {
        let projection = try ViewportWindowFixture.projection([
            ViewportWindowFixture.paragraph("capacity truth")
        ])
        let value = try ViewportWindowFixture.product(
            projection: projection,
            width: 360,
            originY: 0,
            height: 100,
            overscan: 0,
            limit: 8
        )
        let zeroRich = try #require(LayoutMaterializationCapacity(
            reconstructedBlocks: 8,
            reconstructedFragments: 8,
            materializedFragments: 8,
            glyphs: 0,
            caretStops: 0,
            sourceSlices: 0,
            decorations: 0,
            fontVariations: 0,
            residentUTF16Units: 0
        ))
        let refused = try ViewportSnapshot.windowAdmissionDiagnostics(
            value.indexed,
            request: value.request,
            capacity: zeroRich
        )
        #expect(refused == nil)
        let recovered = try #require(
            try ViewportSnapshot.windowAdmissionDiagnostics(
                value.indexed,
                request: value.request,
                capacity: ViewportWindowFixture.materializationCapacity()
            )
        )
        #expect(recovered.snapshot == value.expected)
    }
}
