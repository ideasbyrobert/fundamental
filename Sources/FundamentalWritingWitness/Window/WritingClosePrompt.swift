import AppKit

@MainActor
struct WritingClosePrompt
{
    static func ask() -> WritingCloseDecision
    {
        let alert = NSAlert()
        alert.messageText = "Discard this unsaved writing?"
        alert.informativeText =
            "This writing witness does not save documents. " +
            "Closing it will discard its contents."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Discard")
        return alert.runModal() == .alertSecondButtonReturn ? .discard : .cancel
    }
}
