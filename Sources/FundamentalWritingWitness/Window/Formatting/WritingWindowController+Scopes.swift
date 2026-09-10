import AppKit
import FundamentalDocument

extension WritingWindowController
{
    @objc func chooseTextScope(_ sender: Any?)
    {
        guard canChooseTextStyle,
              let kind = WritingScopeMenu.kind(from: sender),
              bridge.formattingRange(in: textView) != nil,
              textView.selectedRange() == bridge.projection.selection,
              let request = WritingScopeRequest(kind: kind,
                                                in: bridge.projection)
        else
        {
            formatting.update(bridge.projection)
            return
        }
        let sheet = WritingScopeSheet(selection: request.selection)
        scopeSheet = sheet
        sheet.present(for: documentWindow)
        {
            [weak self] decision in
            guard let self
            else
            {
                return
            }
            scopeSheet = nil
            let command: DocumentSessionCommand?
            switch decision
            {
            case let .apply(value): command = request.setting(value)
            case .remove: command = request.removing()
            case .cancel: command = nil
            }
            if let command
            {
                bridge.submitFormatting(command, in: textView)
            }
            else
            {
                bridge.project(in: textView)
                documentWindow.makeFirstResponder(textView)
            }
        }
    }

    func validateTextScope(_ item: NSValidatedUserInterfaceItem) -> Bool
    {
        (item as? NSMenuItem)?.state = .off
        guard canChooseTextStyle, let kind = WritingScopeMenu.kind(from: item),
              let selected = textSelection
        else
        {
            return false
        }
        let state = WritingScopeSelection(kind: kind, in: selected).state
        (item as? NSMenuItem)?.state = WritingInlineMenu.value(state)
        return true
    }
}
