import AppKit

@MainActor
final class WritingFormattingMenuDelegate: NSObject, NSMenuDelegate
{
    static let shared = WritingFormattingMenuDelegate()

    func menuNeedsUpdate(_ menu: NSMenu)
    {
        let action = #selector(WritingWindowController.chooseCodeLanguage(_:))
        let controller = NSApp.target(forAction: action, to: nil, from: menu)
            as? WritingWindowController
        WritingCodeLanguageMenu.update(menu,
            available: controller?.canChooseCodeLanguage == true)
    }
}
