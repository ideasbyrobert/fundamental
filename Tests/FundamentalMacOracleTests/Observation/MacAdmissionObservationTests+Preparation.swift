import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacAdmissionObservationTests
{
    @Test("changed preparation excludes reservation and publication")
    func preparation() throws
    {
        let environment = try #require(MacReaderEnvironment(
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance(),
            increasedContrast: false
        ))
        let initial = try #require(environment.surface(
            viewportWidth: 820,
            visibleOriginY: 0,
            visibleHeight: 680
        ))
        let preparation = try #require(SummitPresentationPreparation(
            surface: initial,
            admitting: { MacRasterExecutor().admit($0) != nil }
        ))
        let layouts = preparation.layoutExecutionCount
        let lineage = preparation.currentSnapshot.lineage.raster.viewport
            .layout
        let origins = [24.0, 48.0, 24.0, 0.0]
        var previous = 0.0
        _ = try MacAdmissionMeasurement.measure(
            "preparation",
            prepare:
            {
                index in
                let origin = origins[index % origins.count]
                try #require(origin != previous)
                let surface = try #require(environment.surface(
                    viewportWidth: 820,
                    visibleOriginY: origin,
                    visibleHeight: 680
                ))
                let lease = try #require(preparation.reserveAttempt())
                return (surface, lease)
            },
            action:
            {
                preparation.prepare(
                    surface: $0.0,
                    intent: .document,
                    lease: $0.1
                )
            },
            consume:
            {
                input, value in
                let attempt = try #require(value)
                #expect(attempt.surface == input.0)
                #expect(attempt.snapshot.lineage.raster.viewport.layout
                    == lineage)
                let origin = attempt.snapshot.lineage.raster.viewport
                    .specification.visibleBounds.minY
                try #require(origin != previous)
                #expect(origin == input.0.visibleOriginY)
                #expect(attempt.snapshot.lineage.generation
                    == input.1.generation)
                #expect(MacRasterExecutor().admit(attempt.snapshot) != nil)
                try #require(preparation.publish(attempt))
                #expect(preparation.currentSnapshot == attempt.snapshot)
                #expect(preparation.layoutExecutionCount == layouts)
                previous = input.0.visibleOriginY
                MacAdmissionWorkload(attempt.snapshot).report("preparation")
            }
        )
    }
}
