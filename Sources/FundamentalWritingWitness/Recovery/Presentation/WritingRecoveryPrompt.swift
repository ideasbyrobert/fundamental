import AppKit

@MainActor
struct WritingRecoveryPrompt
{
    enum Decision
    {
        case recover
        case discard
        case later
    }

    static func ask(
        _ record: WritingRecoveryRecord, for window: NSWindow?
    ) async -> Decision
    {
        let alert = NSAlert()
        alert.messageText = "Recover “\(record.name)”?"
        alert.informativeText = "An unsaved checkpoint is available. " +
            "Recover it as a new document, keeping the original file intact."
        alert.addButton(withTitle: "Recover")
        alert.addButton(withTitle: "Discard")
        alert.addButton(withTitle: "Later")
        let response: NSApplication.ModalResponse
        if let window
        {
            response = await alert.beginSheetModal(for: window)
        }
        else
        {
            response = alert.runModal()
        }
        switch response
        {
        case .alertFirstButtonReturn: return .recover
        case .alertSecondButtonReturn: return .discard
        default: return .later
        }
    }

    static func failure(_ message: String, for window: NSWindow?) async
    {
        let alert = NSAlert()
        alert.messageText = "Recovery checkpoint could not be updated"
        alert.informativeText = message +
            "\nUse Save to protect your latest writing."
        alert.addButton(withTitle: "OK")
        if let window
        {
            await alert.beginSheetModal(for: window)
        }
        else
        {
            alert.runModal()
        }
    }
}
