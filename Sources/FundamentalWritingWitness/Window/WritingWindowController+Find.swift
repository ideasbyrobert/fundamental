import AppKit

extension WritingWindowController
{
    @objc func findText(_ sender: Any?)
    {
        showFind(replacing: false)
    }

    @objc func findAndReplace(_ sender: Any?)
    {
        showFind(replacing: true)
    }

    func showFind(replacing: Bool)
    {
        guard !choosingLocation, !hasFormattingSheet
        else
        {
            return
        }
        if finder == nil
        {
            finder = WritingFindController(owner: self)
        }
        finder?.show(replacing: replacing)
    }

    @objc func findNext(_ sender: Any?)
    {
        if finder == nil || finder?.bar.isHidden == true
        {
            findText(sender)
        }
        finder?.nextMatch(sender)
    }

    @objc func findPrevious(_ sender: Any?)
    {
        if finder == nil || finder?.bar.isHidden == true
        {
            findText(sender)
        }
        finder?.previousMatch(sender)
    }
}
