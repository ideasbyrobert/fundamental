import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("every heading level has an exact enabled current choice")
    func formatPreservesExactHeadingPresentation() throws
    {
        for level in SemanticHeadingLevel.allCases
        {
            let block = SemanticBlock.heading(.section(SectionSemanticHeading(
                runs: [SemanticRun(text: "Exact")], level: level
            )))
            let window = try WritingTestWindow(session: DocumentSession(
                state: WritingTestDocument(blocks: [block]).state,
                initiallySaved: true
            ))
            defer
            {
                window.close()
            }
            let current = window.controller.formatting.block.selectedItem
            #expect(current?.title == "Heading \(level.rawValue)")
            #expect(current?.isEnabled == true)
            for value in 1 ... 6
            {
                let item = try window.formatChoice("Heading \(value)",
                    group: "Paragraph Style")
                #expect(window.controller.validateUserInterfaceItem(item))
                #expect(item.state == (value == level.rawValue ? .on : .off))
            }
            let before = window.storage
            try window.performFormat(window.formatChoice("No List",
                                                          group: "List"))
            #expect(window.storage == before)
            try window.choose(.body)
            let popup = window.controller.formatting.block
            #expect(popup.selectedItem?.title == "Body")
            #expect(popup.item(withTitle: "Mixed")?.isHidden == true)
        }
    }

    @Test("custom toolbar overflow exposes the same native Format actions")
    func formatOverflowHasActionableChoices() throws
    {
        let window = try WritingTestWindow("Text")
        defer
        {
            window.close()
        }
        let items = try #require(window.controller.documentWindow.toolbar)
            .items
        let menu = WritingApplicationMenu.formatMenu()
        #expect(menu.items.map(\.title) == [
            "Paragraph Style", "Text Style", "List"
        ])
        #expect(items.count == 3)
        for (item, group) in zip(items, menu.items)
        {
            let overflow = try #require(item.menuFormRepresentation?.submenu)
            let submenu = try #require(group.submenu)
            overflow.delegate?.menuNeedsUpdate?(overflow)
            submenu.delegate?.menuNeedsUpdate?(submenu)
            #expect(overflow.items.map(\.title) == submenu.items.map(\.title))
            for (command, expected) in zip(overflow.items, submenu.items)
            {
                #expect(command.isSeparatorItem == expected.isSeparatorItem)
                guard !command.isSeparatorItem
                else
                {
                    continue
                }
                #expect(command.action == expected.action)
                #expect(command.representedObject as? String ==
                    expected.representedObject as? String)
                #expect(command.target == nil)
                #expect(window.controller.validateUserInterfaceItem(command) ==
                    (command.identifier != WritingCodeLanguageMenu.identifier &&
                     command.identifier != WritingOpenLinkMenu.identifier))
            }
        }
        let list = try #require(items.last?.menuFormRepresentation?.submenu)
        try window.performFormat(try #require(list.item(withTitle: "Numbered")))
        #expect(window.styles == [.numbered])
    }
}
