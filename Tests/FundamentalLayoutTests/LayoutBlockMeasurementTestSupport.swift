import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

extension LayoutBlockMeasurementTests
{
    @MainActor
    func product(
        _ block: SemanticBlock,
        width: Double
    ) throws -> (
        measurement: LayoutBlockMeasurement,
        snapshot: LayoutSnapshot,
        projection: ProjectionSnapshot
    )
    {
        let projection = try LayoutFixture.projection([block])
        let request = try LayoutFixture.request(width: width)
        let layout = NativeTextKit2Layout()
        return (
            try layout.measure(
                projection.firstBlock,
                parameters: request.parameters
            ),
            try layout.layout(projection, request: request),
            projection
        )
    }

    func expectParity(
        _ measurement: LayoutBlockMeasurement,
        _ snapshot: LayoutSnapshot
    )
    {
        #expect(measurement.extents.map(\.source)
            == snapshot.fragments.map(\.source))
        #expect(measurement.extents.map(\.anchor)
            == snapshot.fragments.map(\.anchor))
        #expect(measurement.extents.map(\.frame)
            == snapshot.fragments.map(\.frame))
        #expect(measurement.extents.map(\.content)
            == expectedContents(snapshot.fragments))
        #expect(measurement.contentFonts
            == expectedContentFonts(snapshot.fragments))
        #expect(measurement.resolvedFonts
            == snapshot.lineage.specification.resolvedFonts)
    }

    func tableFacts(
        _ measurement: LayoutBlockMeasurement
    ) -> LayoutTableMeasurement?
    {
        guard case let .table(table) = measurement.kind
        else
        {
            return nil
        }
        return table
    }

    func storedTypeTokens(
        _ value: Any
    ) -> Set<String>
    {
        let name = String(reflecting: type(of: value))
        var tokens = Set(name.split
        {
            !$0.isLetter && !$0.isNumber && $0 != "_"
        }.map(String.init))
        for child in Mirror(reflecting: value).children
        {
            tokens.formUnion(storedTypeTokens(child.value))
        }
        return tokens
    }
}
