import AppKit
import CoreText
import Testing

@testable import FundamentalNativeWrapping

@MainActor
enum NativeCodeFixture
{
    static func font(_ size: Double = 18) -> NSFont
    {
        .monospacedSystemFont(ofSize: size, weight: .regular)
    }

    static func advance(_ text: String, font: NSFont = font()) -> Double
    {
        CTLineGetTypographicBounds(
            CTLineCreateWithAttributedString(NSAttributedString(
                string: text, attributes: [.font: font]
            )), nil, nil, nil
        )
    }

    static func wrap(
        _ text: String, width: Double, size: Double = 18
    ) throws -> NativeCodeWrapping
    {
        let font = font(size)
        return try #require(NativeCodeWrapping.make(
            NSAttributedString(string: text, attributes: [.font: font]),
            font: font, width: width
        ))
    }
}
