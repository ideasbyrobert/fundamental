import CoreText
import Foundation

@MainActor
package struct NativeWrappingLine
{
    package let range: Range<Int>
    package let inlineOffset: Double
    package let attributed: NSAttributedString
    package let native: CTLine?
    package let advance: Double
    package let trailingWhitespace: Double
}
