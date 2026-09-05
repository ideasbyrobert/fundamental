import AppKit

@MainActor
final class WritingApplicationDelegate: NSObject, NSApplicationDelegate
{
    let controller: WritingWindowController

    init(controller: WritingWindowController)
    {
        self.controller = controller
    }

    func applicationDidFinishLaunching(_ notification: Notification)
    {
        controller.documentWindow.center()
        controller.showWindow(nil)
        NSApplication.shared.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool
    {
        true
    }

    func applicationShouldTerminate(
        _ sender: NSApplication
    ) -> NSApplication.TerminateReply
    {
        controller.mayClose() ? .terminateNow : .terminateCancel
    }
}
