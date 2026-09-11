import AppKit
import CoreText
import FundamentalWrapping

@MainActor
package struct NativeWrappingText
{
    package let source: WrappingSource
    package let attributed: NSAttributedString
    private let typesetter: CTTypesetter

    package init?(_ input: NSAttributedString)
    {
        var immutable = true
        input.enumerateAttribute(.paragraphStyle, in: NSRange(
            location: 0, length: input.length
        ))
        {
            value, _, stop in
            if value is NSMutableParagraphStyle
            {
                immutable = false
                stop.pointee = true
            }
        }
        guard immutable
        else
        {
            return nil
        }
        attributed = NSAttributedString(attributedString: input)
        source = WrappingSource(attributed.string)
        typesetter = CTTypesetterCreateWithAttributedString(attributed)
    }

    package func line(
        in range: Range<Int>, inlineOffset: Double
    ) -> NativeWrappingLine?
    {
        guard inlineOffset.isFinite, inlineOffset >= 0,
              range.lowerBound >= 0, range.upperBound <= source.utf16.count,
              let valid = source.range(location: range.lowerBound,
                                       length: range.count), valid == range
        else
        {
            return nil
        }
        if range.isEmpty
        {
            return NativeWrappingLine(
                range: range, inlineOffset: inlineOffset, native: nil,
                advance: 0, trailingWhitespace: 0
            )
        }
        let native = CTTypesetterCreateLineWithOffset(
            typesetter,
            CFRange(location: range.lowerBound, length: range.count),
            inlineOffset
        )
        let advance = CTLineGetTypographicBounds(native, nil, nil, nil)
        let trailing = CTLineGetTrailingWhitespaceWidth(native)
        guard advance.isFinite, advance >= 0,
              trailing.isFinite, trailing >= 0
        else
        {
            return nil
        }
        return NativeWrappingLine(
            range: range, inlineOffset: inlineOffset, native: native,
            advance: advance, trailingWhitespace: trailing
        )
    }
}
