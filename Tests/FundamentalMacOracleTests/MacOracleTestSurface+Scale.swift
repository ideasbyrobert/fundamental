import FundamentalPresentation

@testable import FundamentalMacOracle

extension MacOracleTestSurface
{
    static func snapshot(
        backingScale: Double
    ) throws -> PresentationSnapshot
    {
        guard let environment = MacReaderEnvironment(
                  screen: try screen(),
                  appearance: try appearance(),
                  increasedContrast: false
              ),
              let source = environment.surface(
                  viewportWidth: 820,
                  visibleOriginY: 0,
                  visibleHeight: 680
              ),
              let surface = SummitPresentationSurface(
                  readableMeasure: source.readableMeasure,
                  visibleOriginY: source.visibleOriginY,
                  visibleHeight: source.visibleHeight,
                  overscanExtent: source.overscanExtent,
                  maximumResidentCount: source.maximumResidentCount,
                  backingScale: backingScale,
                  appearance: source.appearance,
                  colorSpace: source.colorSpace,
                  palette: source.palette,
                  adornmentPalette: source.adornmentPalette,
                  caretWidth: source.caretWidth,
                  maximumSelectionFragmentCount:
                    source.maximumSelectionFragmentCount
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
        return preparation.currentSnapshot
    }
}
