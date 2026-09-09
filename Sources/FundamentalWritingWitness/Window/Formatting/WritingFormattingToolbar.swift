import AppKit

@MainActor
final class WritingFormattingToolbar: NSObject, NSToolbarDelegate
{
    let block = NSPopUpButton(frame: .zero)
    let list = NSPopUpButton(frame: .zero, pullsDown: true)

    static let blockID = NSToolbarItem.Identifier("FundamentalBlockStyle")
    static let listID = NSToolbarItem.Identifier("FundamentalListStyle")
    static let items = [blockID, listID]

    override init()
    {
        super.init()
        configureControls()
    }

    func install(in window: NSWindow)
    {
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
            item.menuFormRepresentation = WritingFormattingGroup.paragraph
                .menuItem()
        case Self.listID:
            item.view = list
            item.label = "List"
            item.menuFormRepresentation = WritingFormattingGroup.list.menuItem()
        default:
            return nil
        }
        return item
    }
}
