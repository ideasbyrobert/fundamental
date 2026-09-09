import AppKit
import FundamentalDocument

extension WritingFormattingToolbar
{
    @objc func chooseBlock(_ sender: NSPopUpButton)
    {
        apply(sender, fromList: false)
    }

    @objc func chooseList(_ sender: NSPopUpButton)
    {
        apply(sender, fromList: true)
    }

    private func apply(_ sender: NSPopUpButton, fromList: Bool)
    {
        guard let value = sender.selectedItem?.representedObject as? String,
              let style = CanonicalBlockStyle(rawValue: value),
              let view = textView,
              let bridge = view.delegate as? WritingNativeBridge
        else
        {
            return
        }
        if fromList && style == .body
        {
            bridge.removeLists(in: view)
        }
        else
        {
            bridge.changeStyle(style, in: view)
        }
    }
}
