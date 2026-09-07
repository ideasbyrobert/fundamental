import AppKit

@MainActor
final class WritingApplicationDelegate: NSObject, NSApplicationDelegate
{
    var controllers: [WritingWindowController] = []
    var terminationPending = false

    init(controller: WritingWindowController)
    {
        super.init()
        retain(controller)
    }

    func applicationDidFinishLaunching(_ notification: Notification)
    {
        controllers.first?.documentWindow.center()
        controllers.first?.showWindow(nil)
        NSApplication.shared.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool
    {
        false
    }

    func retain(_ controller: WritingWindowController)
    {
        controllers.append(controller)
        controller.didClose =
        {
            [weak self, weak controller] in
            self?.controllers.removeAll { $0 === controller }
        }
    }
}
