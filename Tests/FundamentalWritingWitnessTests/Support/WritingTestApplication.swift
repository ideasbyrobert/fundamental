import AppKit
import Testing

@testable import FundamentalWritingWitness

@MainActor
struct WritingTestApplication
{
    static func activate(_ controller: WritingWindowController) throws
    {
        NSApp.activate()
        controller.showWindow(nil)
        let deadline = Date(timeIntervalSinceNow: 5)
        while !controller.documentWindow.isKeyWindow && Date() < deadline
        {
            if let event = NSApp.nextEvent(
                matching: .any, until: Date(timeIntervalSinceNow: 0.01),
                inMode: .default, dequeue: true
            )
            {
                NSApp.sendEvent(event)
            }
        }
        let ready = controller.documentWindow.isKeyWindow
        if !ready
        {
            controller.documentWindow.delegate = nil
            controller.documentWindow.close()
        }
        try #require(ready)
    }
}
