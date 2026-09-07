import AppKit

@MainActor
struct WritingClosePrompt
{
    static func ask() -> WritingCloseDecision
    {
        let alert = NSAlert()
        alert.messageText = "Save changes before closing?"
        alert.informativeText =
            "Save your writing, discard the changes, or continue editing."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Discard")
        alert.addButton(withTitle: "Cancel")
        switch alert.runModal()
        {
        case .alertFirstButtonReturn:
            return .save
        case .alertSecondButtonReturn:
            return .discard
        default:
            return .cancel
        }
    }
}
