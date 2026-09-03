import AppKit

@MainActor
final class MacApplicationDelegate: NSObject, NSApplicationDelegate
{
    private var windows: [MacReaderWindowController] = []

    func applicationDidFinishLaunching(
        _ notification: Notification
    )
    {
        guard let screen = NSScreen.main,
              let controller = MacReaderWindowController(
                  contentSize: NSSize(width: 820, height: 680),
                  screen: screen,
                  appearance: NSApplication.shared.effectiveAppearance
              )
        else
        {
            NSApplication.shared.terminate(nil)
            return
        }
        windows = [controller]
        controller.window?.center()
        controller.showWindow(nil)
        controller.window?.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate()
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool
    {
        true
    }
}
