import AppKit

@MainActor
final class WritingApplicationDelegate: NSObject, NSApplicationDelegate
{
    var controllers: [WritingWindowController] = []
    var terminationPending = false
    let recoveryStore: WritingRecoveryStore?

    init(
        controller: WritingWindowController,
        recoveryStore: WritingRecoveryStore? = nil
    )
    {
        self.recoveryStore = recoveryStore
        super.init()
        retain(controller)
    }

    func applicationDidFinishLaunching(_ notification: Notification)
    {
        controllers.first?.documentWindow.center()
        controllers.first?.showWindow(nil)
        NSApplication.shared.activate()
        Task { await offerRecovery() }
    }

    func applicationShouldTerminateAfterLastWindowClosed(
        _ sender: NSApplication
    ) -> Bool
    {
        false
    }

    func retain(_ controller: WritingWindowController)
    {
        if let recoveryStore
        {
            controller.installRecovery(using: recoveryStore)
        }
        controllers.append(controller)
        controller.didClose =
        {
            [weak self, weak controller] in
            self?.controllers.removeAll { $0 === controller }
        }
    }
}
