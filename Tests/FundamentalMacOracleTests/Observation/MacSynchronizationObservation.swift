import AppKit
import FundamentalPresentation

@testable import FundamentalMacOracle

@MainActor
struct MacSynchronizationObservation
{
    let snapshot: PresentationSnapshot
    let execution: MacAdmittedRasterExecution
    let layoutExecutions: Int
    let origin: NSPoint
    let viewSize: NSSize
    let accessibilityFrame: NSRect

    init(_ controller: MacReaderWindowController) throws
    {
        let view = controller.readerView
        snapshot = view.model.snapshot
        execution = view.model.rasterExecution
        layoutExecutions = view.model.layoutExecutionCount
        origin = controller.scrollView.contentView.bounds.origin
        viewSize = view.frame.size
        accessibilityFrame = try MacAccessibilityGeometryTestSupport.frame(
            MacAccessibilityGeometryTestSupport.firstElement(view)
        )
    }

    var form: String
    {
        switch snapshot
        {
        case .document:
            "document"
        case .caret:
            "caret"
        case .selection:
            "selection"
        }
    }

    func report(
        _ label: String,
        after next: MacSynchronizationObservation
    )
    {
        let reused = execution.documentExecution
            === next.execution.documentExecution
        print(
            "OBSERVATION \(label)"
                + " generation=\(snapshot.lineage.generation)"
                + "->\(next.snapshot.lineage.generation)"
                + " layout=\(layoutExecutions)->\(next.layoutExecutions)"
                + " storageReused=\(reused)"
                + " form=\(form)->\(next.form)"
                + " origin=\(origin)->\(next.origin)"
                + " size=\(viewSize)->\(next.viewSize)"
                + " accessibility=\(accessibilityFrame)"
                + "->\(next.accessibilityFrame)"
        )
    }
}
