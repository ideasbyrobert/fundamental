import AppKit

@MainActor
final class WritingScopeSheet: NSObject, NSTextFieldDelegate
{
    let alert = NSAlert()
    let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 320, height: 24))
    let selection: WritingScopeSelection

    init(selection: WritingScopeSelection)
    {
        self.selection = selection
        super.init()
        let kind = selection.kind
        field.stringValue = selection.value
        field.placeholderString = selection.isMixed ? "Multiple values" :
            kind.placeholder
        field.setAccessibilityLabel(kind.title)
        field.setAccessibilityIdentifier(kind.rawValue + "Field")
        field.delegate = self
        alert.messageText = kind.title
        alert.informativeText = selection.isMixed
            ? "Choose one value for the selected text."
            : "Apply to the selected text or new typing."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Apply")
        alert.addButton(withTitle: "Cancel").keyEquivalent = "\u{1b}"
        alert.addButton(withTitle: kind.removalTitle)
        alert.accessoryView = field
        alert.layout()
        alert.window.initialFirstResponder = field
        updateAdmission()
    }

    func present(
        for window: NSWindow,
        completion: @escaping @MainActor (WritingScopeDecision) -> Void
    )
    {
        alert.beginSheetModal(for: window)
        {
            [weak self] response in
            guard let self
            else
            {
                completion(.cancel)
                return
            }
            switch response
            {
            case .alertFirstButtonReturn:
                let value = field.stringValue
                completion(selection.kind.setting(value) != nil
                    ? .apply(value) : .cancel)
            case .alertThirdButtonReturn:
                completion(selection.hasScope ? .remove : .cancel)
            default:
                completion(.cancel)
            }
        }
    }

    func controlTextDidChange(_ notification: Notification)
    {
        updateAdmission()
    }

    private func updateAdmission()
    {
        alert.buttons.first?.isEnabled = selection.kind.setting(
            field.stringValue
        ) != nil
        alert.buttons.last?.isEnabled = selection.hasScope
    }
}
