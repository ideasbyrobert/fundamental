import AppKit
import CoreText

@MainActor
enum NativeWrappingFixture
{
    static let font = NSFont.monospacedSystemFont(ofSize: 26, weight: .regular)

    static func text(_ string: String) -> NSAttributedString
    {
        NSAttributedString(string: string, attributes: [.font: font])
    }

    static var indentation: Double
    {
        CTLineGetTypographicBounds(
            CTLineCreateWithAttributedString(text("    ")), nil, nil, nil
        )
    }
}
