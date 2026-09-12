import AppKit

@MainActor
final class WritingFindController:
    NSObject, NSSearchFieldDelegate, NSMenuDelegate
{
    weak var owner: WritingWindowController?
    let bar = WritingFindBar()
    var results: WritingFindResults?
    var caseSensitive = false

    init(owner: WritingWindowController)
    {
        self.owner = owner
        super.init()
        bar.query.delegate = self
        bar.replacement.delegate = self
        let actions: [(NSControl, Selector)] = [
            (bar.query, #selector(nextMatch(_:))),
            (bar.previous, #selector(previousMatch(_:))),
            (bar.next, #selector(nextMatch(_:))),
            (bar.done, #selector(close(_:))),
            (bar.replace, #selector(replace(_:))),
            (bar.replaceAll, #selector(replaceAll(_:)))
        ]
        for (control, action) in actions
        {
            control.target = self
            control.action = action
        }
        configureOptions()
    }

    func show(replacing: Bool)
    {
        guard let owner,
              owner.bridge.finishComposition(in: owner.textView)
        else
        {
            return
        }
        bar.isHidden = false
        bar.replacementRow.isHidden = !replacing
        layout()
        refresh()
        owner.documentWindow.makeFirstResponder(bar.query)
        bar.query.selectText(nil)
    }

    @objc func close(_ sender: Any?)
    {
        bar.isHidden = true
        layout()
        owner?.documentWindow.makeFirstResponder(owner?.textView)
        if let owner
        {
            let selection = owner.bridge.projection.selection
            owner.textView.scrollRangeToVisible(selection)
        }
    }

    func layout()
    {
        let content = owner?.documentWindow.contentView as? WritingWindowContent
        content?.show(bar)
        owner?.updateWritingGeometry()
    }

    func controlTextDidChange(_ notification: Notification)
    {
        if !bar.message.isHidden
        {
            bar.message.isHidden = true
            layout()
        }
        refresh()
    }

    func control(
        _ control: NSControl, textView: NSTextView,
        doCommandBy commandSelector: Selector
    ) -> Bool
    {
        if commandSelector == #selector(NSResponder.cancelOperation(_:)),
           !textView.hasMarkedText()
        {
            close(nil)
            return true
        }
        return false
    }
}
