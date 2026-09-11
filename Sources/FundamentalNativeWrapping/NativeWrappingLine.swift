import CoreText

@MainActor
package struct NativeWrappingLine
{
    package let range: Range<Int>
    package let inlineOffset: Double
    package let native: CTLine?
    package let advance: Double
    package let trailingWhitespace: Double
}
