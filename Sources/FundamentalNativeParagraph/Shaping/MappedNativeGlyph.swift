import CoreText

package struct MappedNativeGlyph<Source>
{
    package let identifier: CGGlyph
    package let position: CGPoint
    package let advance: CGSize
    package let stringIndex: Int
    package let displayRange: Range<Int>
    package let sources: [Source]
}

extension MappedNativeGlyph: Sendable where Source: Sendable
{
}
