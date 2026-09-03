import AppKit
import FundamentalPresentation

@testable import FundamentalMacOracle

@MainActor
enum MacOracleTestSurface
{
    static func screen() throws -> NSScreen
    {
        guard let screen = NSScreen.main
        else
        {
            throw MacOracleTestFailure.admission
        }
        return screen
    }

    static func appearance(
        _ name: NSAppearance.Name = .aqua
    ) throws -> NSAppearance
    {
        guard let appearance = NSAppearance(named: name)
        else
        {
            throw MacOracleTestFailure.admission
        }
        return appearance
    }

    static func model(
        width: Double = 820,
        height: Double = 680,
        appearanceName: NSAppearance.Name = .aqua
    ) throws -> MacReaderModel
    {
        guard let model = MacReaderModel(
            viewportWidth: width,
            viewportHeight: height,
            screen: try screen(),
            appearance: try appearance(appearanceName)
        )
        else
        {
            throw MacOracleTestFailure.admission
        }
        return model
    }

    static func snapshot(
        width: Double = 820,
        height: Double = 680,
        appearanceName: NSAppearance.Name = .aqua
    ) throws -> PresentationSnapshot
    {
        guard let environment = MacReaderEnvironment(
                  screen: try screen(),
                  appearance: try appearance(appearanceName),
                  increasedContrast: false
              ),
              let surface = environment.surface(
                  viewportWidth: width,
                  visibleOriginY: 0,
                  visibleHeight: height
              ),
              let preparation = SummitPresentationPreparation(
                  surface: surface,
                  admitting: { _ in true }
              )
        else
        {
            throw MacOracleTestFailure.admission
        }
        return preparation.currentSnapshot
    }

    static func window(
        width: Double = 820,
        height: Double = 680,
        appearanceName: NSAppearance.Name = .aqua
    ) throws -> MacReaderWindowController
    {
        guard let controller = MacReaderWindowController(
            contentSize: NSSize(width: width, height: height),
            screen: try screen(),
            appearance: try appearance(appearanceName)
        )
        else
        {
            throw MacOracleTestFailure.admission
        }
        return controller
    }
}
