import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite(
    "Native admission boundary observations",
    .serialized,
    .enabled(if: ProcessInfo.processInfo.environment[
        "FUNDAMENTAL_NATIVE_OBSERVATION"
    ] == "1")
)
@MainActor
struct MacAdmissionObservationTests
{
    @Test("environment admission observes current native facts")
    func environment() throws
    {
        let screen = try MacOracleTestSurface.screen()
        let appearance = try MacOracleTestSurface.appearance()
        let reference = try #require(MacReaderEnvironment(
            screen: screen,
            appearance: appearance,
            increasedContrast: false
        ))
        _ = try MacAdmissionMeasurement.measure(
            "environment",
            prepare: { $0 },
            action:
            {
                _ in
                MacReaderEnvironment(
                    screen: screen,
                    appearance: appearance,
                    increasedContrast: false
                )
            },
            consume:
            {
                _, value in
                let admitted = try #require(value)
                #expect(admitted.surface(
                    viewportWidth: 820,
                    visibleOriginY: 0,
                    visibleHeight: 680
                ) == reference.surface(
                    viewportWidth: 820,
                    visibleOriginY: 0,
                    visibleHeight: 680
                ))
            }
        )
    }
}
