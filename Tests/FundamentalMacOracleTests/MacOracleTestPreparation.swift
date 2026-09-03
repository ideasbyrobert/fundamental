import FundamentalPresentation

@testable import FundamentalMacOracle

@MainActor
enum MacOracleTestPreparation
{
    static func make(
        width: Double = 820,
        height: Double = 680,
        originY: Double = 0
    ) throws -> (
        SummitPresentationPreparation,
        SummitPresentationSurface
    )
    {
        guard let environment = MacReaderEnvironment(
            screen: try MacOracleTestSurface.screen(),
            appearance: try MacOracleTestSurface.appearance(),
            increasedContrast: false
        ),
              let surface = environment.surface(
                  viewportWidth: width,
                  visibleOriginY: originY,
                  visibleHeight: height
              )
        else
        {
            throw MacOracleTestFailure.admission
        }
        let executor = MacRasterExecutor()
        guard let preparation = SummitPresentationPreparation(
            surface: surface,
            admitting:
            {
                executor.admit($0) != nil
            }
        )
        else
        {
            throw MacOracleTestFailure.admission
        }
        return (preparation, surface)
    }
}
