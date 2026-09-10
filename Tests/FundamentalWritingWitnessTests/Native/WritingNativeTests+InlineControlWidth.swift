import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test(arguments: [NSAppearance.Name.aqua, .darkAqua])
    func inlineControlsFitNamedDocument(appearance: NSAppearance.Name) throws
    {
        let window = try WritingTestWindow("Text")
        defer
        {
            window.close()
        }
        let native = window.controller.documentWindow
        native.appearance = NSAppearance(named: appearance)
        let toolbar = try #require(native.toolbar)
        for style in [CanonicalBlockStyle.body, .title, .heading,
                      .subheading, .monostyled]
        {
            try window.choose(style)
            native.title = "Formatting.fun"
            native.representedURL = URL(fileURLWithPath: "/tmp/Formatting.fun")
            native.setContentSize(NSSize(width: 540, height: 600))
            native.contentView?.superview?.layoutSubtreeIfNeeded()
            native.displayIfNeeded()
            let visible = toolbar.visibleItems?.map(\.itemIdentifier) ?? []
            let controls = [window.controller.formatting.block,
                            window.controller.formatting.text,
                            window.controller.formatting.list]
            let sizes = controls.map
            {
                "\($0.frame.size); intrinsic \($0.intrinsicContentSize)"
            }.joined(separator: "; ")
            #expect(visible == WritingFormattingToolbar.items,
                    Comment(rawValue: style.rawValue + ": " + sizes))
            let block = window.controller.formatting.block
            let font = try #require(block.font)
            let cell = try #require(block.cell)
            let title = (block.title as NSString).size(
                withAttributes: [.font: font]
            )
            let available = cell.titleRect(forBounds: block.bounds).width
            #expect(title.width <= available)
        }
    }
}
