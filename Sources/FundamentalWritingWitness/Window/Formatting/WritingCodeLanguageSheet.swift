import AppKit
import FundamentalDocument

@MainActor
final class WritingCodeLanguageSheet: NSObject, NSTextFieldDelegate
{
    let alert = NSAlert()
    let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 280, height: 24))

    init(value: String)
    {
        super.init()
        field.stringValue = value
        field.placeholderString = "e.g. Swift"
        field.setAccessibilityLabel("Code language")
        field.setAccessibilityIdentifier("FundamentalCodeLanguageField")
        field.delegate = self
        alert.messageText = "Code Language"
        alert.informativeText = "Leave empty for plain code."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Apply")
        alert.addButton(withTitle: "Cancel").keyEquivalent = "\u{1b}"
        alert.accessoryView = field
        alert.layout()
        alert.window.initialFirstResponder = field
        updateAdmission()
    }

    func present(
        for window: NSWindow,
        completion: @escaping @MainActor (String?) -> Void
    )
    {
        alert.beginSheetModal(for: window)
        {
            [weak self] response in
            completion(response == .alertFirstButtonReturn
                ? self?.field.stringValue : nil)
        }
    }

    func controlTextDidChange(_ notification: Notification)
    {
        updateAdmission()
    }

    private func updateAdmission()
    {
        let value = field.stringValue
        alert.buttons.first?.isEnabled = value.isEmpty ||
            SemanticCodeLanguageIdentifier(value) != nil
    }
}
