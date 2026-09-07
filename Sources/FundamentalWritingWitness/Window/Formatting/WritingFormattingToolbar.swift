import AppKit

@MainActor
final class WritingFormattingToolbar: NSObject, NSToolbarDelegate
{
    let block = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 150, height: 28))
    let bulleted = NSButton(title: "", target: nil, action: nil)
    let numbered = NSButton(title: "", target: nil, action: nil)
    weak var textView: WritingTextView?

    static let blockID = NSToolbarItem.Identifier("FundamentalBlockStyle")
    static let bulletedID = NSToolbarItem.Identifier("FundamentalBulletedList")
    static let numberedID = NSToolbarItem.Identifier("FundamentalNumberedList")
    static let items = [blockID, bulletedID, numberedID]

    override init()
    {
        super.init()
        configureControls()
    }

    func install(in window: NSWindow, for view: WritingTextView)
    {
        textView = view
        let toolbar = NSToolbar(identifier: "FundamentalWriting")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        window.toolbar = toolbar
        window.toolbarStyle = .unified
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar)
        -> [NSToolbarItem.Identifier]
    {
        Self.items
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar)
        -> [NSToolbarItem.Identifier]
    {
        Self.items
    }

    func toolbar(
        _ toolbar: NSToolbar, itemForItemIdentifier identifier: NSToolbarItem
            .Identifier, willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem?
    {
        let item = NSToolbarItem(itemIdentifier: identifier)
        switch identifier
        {
        case Self.blockID:
            item.view = block
            item.label = "Block style"
        case Self.bulletedID:
            item.view = bulleted
            item.label = "Bulleted list"
        case Self.numberedID:
            item.view = numbered
            item.label = "Numbered list"
        default:
            return nil
        }
        return item
    }
}
