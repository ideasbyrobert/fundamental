import AppKit
import FundamentalPresentation

@MainActor
package final class MacReaderModel
{
    private let executor: MacRasterExecutor
    private let preparation: SummitPresentationPreparation
    private var currentSurface: SummitPresentationSurface
    private var currentPublication: MacReaderPublication

    package init?(
        viewportWidth: Double,
        viewportHeight: Double,
        screen: NSScreen,
        appearance: NSAppearance,
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

    package var snapshot: PresentationSnapshot
    {
        currentPublication.snapshot
    }

    var rasterExecution: MacAdmittedRasterExecution
    {
        currentPublication.execution
    }

    package var layoutExecutionCount: Int
    {
        preparation.layoutExecutionCount
    }

    package var documentWidth: Double
    {
        snapshot.presentedDocument.plane.documentSize.width
    }

    package var documentHeight: Double
    {
        snapshot.presentedDocument.plane.documentSize.height
    }

    package var readableMeasure: Double
    {
        currentSurface.readableMeasure
    }

    package var visibleOriginY: Double
    {
        snapshot.lineage.raster.viewport.specification
            .visibleBounds.minY
    }

    @discardableResult
    package func update(
        viewportWidth: Double,
        viewportHeight: Double,
        visibleOriginY: Double,
        screen: NSScreen,
        appearance: NSAppearance,
        increasedContrast: Bool = false
    ) -> Bool
    {
        guard let environment = MacReaderEnvironment(
            screen: screen,
            appearance: appearance,
            increasedContrast: increasedContrast
        )
        else
        {
            return false
        }
        guard let surface = environment.surface(
            viewportWidth: viewportWidth,
            visibleOriginY: max(0, visibleOriginY),
            visibleHeight: viewportHeight
        ),
              publish(surface: surface, intent: .document)
        else
        {
            return false
        }
        return true
    }

    @discardableResult
    package func showCaret(
        at position: PresentationTextPosition
    ) -> Bool
    {
        publish(
            surface: currentSurface,
            intent: .caret(position)
        )
    }

    @discardableResult
    package func showSelection(
        anchor: PresentationTextPosition,
        focus: PresentationTextPosition
    ) -> Bool
    {
        if anchor == focus
        {
            return showCaret(at: focus)
        }
        guard let selection = PresentationTextSelection(
            anchor: anchor,
            focus: focus
        )
        else
        {
            return false
        }
        return publish(
            surface: currentSurface,
            intent: .selection(selection)
        )
    }

    package func nearestPosition(
        to point: PresentationPoint
    ) -> PresentationTextPosition?
    {
        let candidates = snapshot.presentedDocument.residents.all.enumerated()
            .flatMap
        {
            residentIndex, resident
                -> [(
                    Int,
                    Int,
                    PresentedResident,
                    PresentedCaretSite,
                    PresentationRectangle
                )] in
            guard let line = Self.textLine(resident.content)
            else
            {
                return []
            }
            return line.caretSites.enumerated().map
            {
                siteIndex, site in
                (
                    residentIndex,
                    siteIndex,
                    resident,
                    site,
                    line.lineBounds
                )
            }
        }
        guard let candidate = candidates.min(by:
        {
            let leftY = Self.verticalDistance(point, bounds: $0.4)
            let rightY = Self.verticalDistance(point, bounds: $1.4)
            if leftY != rightY
            {
                return leftY < rightY
            }
            let leftX = abs($0.3.position.x - point.x)
            let rightX = abs($1.3.position.x - point.x)
            if leftX != rightX
            {
                return leftX < rightX
            }
            if $0.0 != $1.0
            {
                return $0.0 < $1.0
            }
            return $0.1 < $1.1
        })
        else
        {
            return nil
        }
        return PresentationTextPosition(
            residentID: candidate.2.residentID,
            sourcePoint: candidate.3.sourcePoint
        )
    }

    private func publish(
        surface: SummitPresentationSurface,
        intent: FundamentalPresentation.PresentationIntent
    ) -> Bool
    {
        guard let lease = preparation.reserveAttempt(),
              let attempt = preparation.prepare(
                  surface: surface,
                  intent: intent,
                  lease: lease
              ),
              publish(attempt)
        else
        {
            return false
        }
        return true
    }

    @discardableResult
    func publish(_ attempt: SummitPresentationAttempt) -> Bool
    {
        guard let execution = executor.admit(
            attempt.snapshot,
            reusing: currentPublication.execution.documentExecution
        ),
              let publication = MacReaderPublication(
                  snapshot: attempt.snapshot,
                  execution: execution
              ),
              preparation.publish(attempt)
        else
        {
            return false
        }
        currentPublication = publication
        currentSurface = attempt.surface
        return true
    }

    private static func verticalDistance(
        _ point: PresentationPoint,
        bounds: PresentationRectangle
    ) -> Double
    {
        if point.y < bounds.minY
        {
            return bounds.minY - point.y
        }
        if point.y > bounds.maxY
        {
            return point.y - bounds.maxY
        }
        return 0
    }

    private static func textLine(
        _ content: PresentedResidentContent
    ) -> PresentedTextLine?
    {
        switch content
        {
        case let .body(line),
             let .title(line),
             let .code(line),
             let .caption(line):
            return line
        case let .section(_, line):
            return line
        case let .headerCell(_, _, .line(line)),
             let .bodyCell(_, _, .line(line)):
            return line
        case .table,
             .tableColumn,
             .headerRow,
             .bodyRow,
             .headerCell(_, _, .area),
             .bodyCell(_, _, .area):
            return nil
        }
    }
}
