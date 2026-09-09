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
        let window = controller.documentWindow
        let front = NSWorkspace.shared.frontmostApplication
        let context = """
            active=\(NSApp.isActive), visible=\(window.isVisible),
            canKey=\(window.canBecomeKey), window=\(window.windowNumber),
            key=\(NSApp.keyWindow?.windowNumber ?? -1),
            front=\(front?.bundleIdentifier ?? "nil"),
            frontPID=\(front?.processIdentifier ?? 0)
            """
        if !ready
        {
            controller.documentWindow.delegate = nil
            controller.documentWindow.close()
        }
        try #require(ready, Comment(rawValue: context))
    }
}
