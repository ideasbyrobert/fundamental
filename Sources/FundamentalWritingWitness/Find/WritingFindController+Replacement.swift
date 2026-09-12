import AppKit

extension WritingFindController
{
    @objc func replace(_ sender: Any?)
    {
        replaceMatches(all: false)
    }

    @objc func replaceAll(_ sender: Any?)
    {
        replaceMatches(all: true)
    }

    func replaceMatches(all: Bool)
    {
        guard let owner,
              owner.bridge.finishComposition(in: owner.textView)
        else
        {
            return
        }
        refresh()
        guard let results
        else
        {
            return
        }
        let projection = owner.bridge.projection
        let ranges = all ? results.ranges : [projection.selection]
        guard let replacement = WritingFindReplacement(
            results, ranges: ranges, text: bar.replacement.stringValue,
            in: projection
        )
        else
        {
            refuse("Cannot replace these matches. Use less text or one line.")
            return
        }
        switch owner.fileOwner.session.submit(replacement.command)
        {
        case .applied, .unchanged:
            bar.message.isHidden = true
            owner.bridge.project(in: owner.textView)
            owner.documentWindow.makeFirstResponder(owner.textView)
            layout()
        case .refused:
            refuse("The document changed. Find the text again to replace it.")
        }
    }

    func refuse(_ message: String)
    {
        bar.message.stringValue = message
        bar.message.isHidden = false
        layout()
    }
}
