import AppKit
import CoreText
import FundamentalNativeWrapping
import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

@MainActor
struct LayoutContextualFixture
{
    let attributed: NSAttributedString
    let lines: [LayoutLine]

    init(originX: Double = 0) throws
    {
        let font = NSFont.monospacedSystemFont(ofSize: 26, weight: .regular)
        let projection = try LayoutFixture.projection([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("\talpha\t"),
                LayoutFixture.direct("beta\t"),
                LayoutFixture.direct("gamma\t")
            ]))
        ])
        guard case let .prose(source, prose) = projection.firstBlock
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let layout = NativeTextKit2Layout()
        let (input, segments) = try layout.attributedSource(
            runs: prose.runs, font: font
        )
        let paragraph = NSMutableParagraphStyle()
        paragraph.headIndent = CTLineGetTypographicBounds(
            CTLineCreateWithAttributedString(NSAttributedString(
                string: "    ", attributes: [.font: font]
            )), nil, nil, nil
        )
        let copy = NSMutableAttributedString(attributedString: input)
        copy.addAttribute(.paragraphStyle, value: paragraph.copy(),
                          range: NSRange(location: 0, length: copy.length))
        attributed = copy
        let storage = NSTextContentStorage()
        let manager = NSTextLayoutManager()
        let container = NSTextContainer(size: CGSize(
            width: 120, height: 100_000
        ))
        container.lineFragmentPadding = 0
        storage.addTextLayoutManager(manager)
        manager.textContainer = container
        storage.attributedString = attributed
        manager.ensureLayout(for: storage.documentRange)
        let shaping = try #require(NativeWrappingText(attributed))
        lines = try layout.nativeLines(
            storage: storage, manager: manager,
            shaping: shaping, segments: segments,
            defaultFont: layout.fontIdentity(font as CTFont),
            originX: originX, originY: 0,
            pointContext: .block(source.blockID)
        )
    }
}
