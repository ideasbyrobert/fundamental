import AppKit
import FundamentalPresentation

@MainActor
package final class MacReaderModel
{
    let executor: MacRasterExecutor
    let preparation: SummitPresentationPreparation
    var currentSurface: SummitPresentationSurface
    var currentPublication: MacReaderPublication

    package init?(
        viewportWidth: Double,
        viewportHeight: Double,
        screen: NSScreen,
        appearance: NSAppearance,
        projection: MacReaderDocumentProjection? = nil,
        increasedContrast: Bool = false
    )
    {
        let executor = MacRasterExecutor()
        var admittedExecutions: [MacAdmittedRasterExecution] = []
        guard let environment = MacReaderEnvironment(
            screen: screen,
            appearance: appearance,
            increasedContrast: increasedContrast
        ),
              let surface = environment.surface(
                  viewportWidth: viewportWidth,
                  visibleOriginY: 0,
                  visibleHeight: viewportHeight
              ),
              let preparation = SummitPresentationPreparation(
                  surface: surface,
                  projection: projection,
                  admitting:
                  {
                      snapshot in
                      guard let execution = executor.admit(snapshot)
                      else
                      {
                          return false
                      }
                      admittedExecutions.append(execution)
                      return true
                  }
              ),
              admittedExecutions.count == 1,
              let execution = admittedExecutions.first,
              let publication = MacReaderPublication(
                  snapshot: preparation.currentSnapshot,
                  execution: execution
              )
        else
        {
            return nil
        }
        currentSurface = surface
        self.executor = executor
        self.preparation = preparation
        currentPublication = publication
    }
}
