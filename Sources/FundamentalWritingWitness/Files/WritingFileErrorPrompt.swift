import AppKit

@MainActor
struct WritingFileErrorPrompt
{
    static func show(_ error: Error, for window: NSWindow?) async
    {
        let message = WritingFileErrorMessage(error)
        let alert = NSAlert()
        alert.messageText = message.title
        alert.informativeText = message.detail
        alert.addButton(withTitle: "OK")
        await present(alert, locations: message.recoveryLocations, for: window)
    }

    static func showRetained(_ locations: [URL], for window: NSWindow) async
    {
        let alert = NSAlert()
        alert.messageText = "Your document was saved."
        alert.informativeText = "Some recovery files could not be removed."
        alert.addButton(withTitle: "OK")
        await present(alert, locations: locations, for: window)
    }

    private static func present(
        _ alert: NSAlert,
        locations: [URL],
        for window: NSWindow?
    ) async
    {
        if !locations.isEmpty
        {
            alert.addButton(withTitle: "Show Recovery Files")
        }
        let result: NSApplication.ModalResponse
        if let window
        {
            result = await alert.beginSheetModal(for: window)
        }
        else
        {
            result = alert.runModal()
        }
        if result == .alertSecondButtonReturn
        {
            NSWorkspace.shared.activateFileViewerSelecting(locations)
        }
    }
}
