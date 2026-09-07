import AppKit
import FundamentalDocument

extension WritingFormattingToolbar
{
    func configureControls()
    {
        block.autoenablesItems = false
        for (title, style) in [("Body", CanonicalBlockStyle.body),
                               ("Title", .title), ("Heading", .heading),
                               ("Subheading", .subheading)]
        {
            block.addItem(withTitle: title)
            block.lastItem?.representedObject = style.rawValue
        }
        block.addItem(withTitle: "Mixed")
        block.lastItem?.isEnabled = false
        block.target = self
        block.action = #selector(chooseBlock(_:))
        block.setAccessibilityLabel("Block style")
        block.toolTip = "Choose the meaning of the selected paragraphs"
        configure(bulleted, symbol: "list.bullet", label: "Bulleted list")
        configure(numbered, symbol: "list.number", label: "Numbered list")
        bulleted.action = #selector(toggleBulleted(_:))
        numbered.action = #selector(toggleNumbered(_:))
    }

    private func configure(_ button: NSButton, symbol: String, label: String)
    {
        button.image = NSImage(systemSymbolName: symbol,
                               accessibilityDescription: label)
        button.imagePosition = .imageOnly
        button.bezelStyle = .rounded
        button.setButtonType(.pushOnPushOff)
        button.allowsMixedState = true
        button.target = self
        button.toolTip = label
        button.setAccessibilityLabel(label)
        button.setFrameSize(NSSize(width: 38, height: 28))
    }

    @objc func chooseBlock(_ sender: NSPopUpButton)
    {
        guard let value = sender.selectedItem?.representedObject as? String,
              let style = CanonicalBlockStyle(rawValue: value)
        else
        {
            return
        }
        apply(style)
    }

    @objc func toggleBulleted(_ sender: NSButton)
    {
        apply(.bulleted, toggle: true)
    }

    @objc func toggleNumbered(_ sender: NSButton)
    {
        apply(.numbered, toggle: true)
    }

    private func apply(_ style: CanonicalBlockStyle, toggle: Bool = false)
    {
        guard let view = textView,
              let bridge = view.delegate as? WritingNativeBridge
        else
        {
            return
        }
        bridge.changeStyle(style, toggle: toggle, in: view)
    }
}
