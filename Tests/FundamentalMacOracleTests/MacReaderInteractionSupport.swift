import AppKit
import FundamentalPresentation

@testable import FundamentalMacOracle

extension MacReaderInteractionTests
{
    static func line(
        in snapshot: PresentationSnapshot
    ) throws -> (PresentedResident, PresentedTextLine)
    {
        for resident in snapshot.presentedDocument.residents.all
        {
            let line: PresentedTextLine?
            switch resident.content
            {
            case let .body(value), let .title(value):
                line = value
            case let .section(_, value):
                line = value
            default:
                line = nil
            }
            if let line,
               line.caretSites.count > 2
            {
                return (resident, line)
            }
        }
        throw MacOracleTestFailure.admission
    }

    static func event(
        type: NSEvent.EventType,
        site: PresentedCaretSite,
        view: MacReaderView,
        window: NSWindow
    ) throws -> NSEvent
    {
        let local = NSPoint(
            x: site.position.x + view.horizontalInset,
            y: site.position.y
        )
        let position = view.convert(local, to: nil)
        guard let event = NSEvent.mouseEvent(
            with: type,
            location: position,
            modifierFlags: [],
            timestamp: 1,
            windowNumber: window.windowNumber,
            context: nil,
            eventNumber: 1,
            clickCount: 1,
            pressure: 1
        )
        else
        {
            throw MacOracleTestFailure.admission
        }
        return event
    }
}
