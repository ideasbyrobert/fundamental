import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingTestWindow
{
    func chooseInline(_ trait: SemanticInlineTrait, toolbar: Bool = true)
        throws
    {
        if toolbar
        {
            let popup = controller.formatting.text
            let item = try #require(popup.itemArray.first
                { $0.representedObject as? String == trait.rawValue })
            popup.select(item)
            #expect(popup.sendAction(popup.action, to: popup.target))
        }
        else
        {
            let choice = try #require(WritingInlineChoice.all.first
                { $0.trait == trait })
            try performFormat(formatChoice(choice.title, group: "Text Style"))
        }
    }

    func expectInline(
        _ trait: SemanticInlineTrait, _ state: NSControl.StateValue
    ) throws
    {
        let before = storage
        let choice = try #require(WritingInlineChoice.all.first
            { $0.trait == trait })
        let item = try formatChoice(choice.title, group: "Text Style")
        #expect(controller.validateUserInterfaceItem(item))
        #expect(item.state == state)
        let toolbar = try #require(controller.formatting.text.itemArray.first
            { $0.representedObject as? String == trait.rawValue })
        #expect(toolbar.state == state)
        #expect(storage == before)
    }
}
