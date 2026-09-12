import AppKit

@MainActor
final class WritingApplicationDelegate: NSObject, NSApplicationDelegate
{
    var controllers: [WritingWindowController] = []
    var terminationPending = false
    var choosingTextImport = false
    let recoveryStore: WritingRecoveryStore?
    let zoomPreferences: WritingZoomPreferences?

    init(
        controller: WritingWindowController,
        recoveryStore: WritingRecoveryStore? = nil,
        zoomPreferences: WritingZoomPreferences? = nil
    )
    {
        self.recoveryStore = recoveryStore
        self.zoomPreferences = zoomPreferences
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
        if let zoomPreferences
        {
            controller.zoomPreferences = zoomPreferences
            controller.applyZoom(zoomPreferences.zoom)
        }
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
