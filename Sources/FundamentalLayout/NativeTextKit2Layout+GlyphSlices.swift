import AppKit
import CoreText

extension NativeTextKit2Layout
{
    func glyphSlices(
        stringIndex: CFIndex,
        logicalIndices: [CFIndex],
        runRange: CFRange,
        documentOffset: Int,
        segments: [NativeSourceSegment],
        text: NSString
    ) throws -> [LayoutSourceSlice]
    {
        if stringIndex == kCFNotFound
        {
            return []
        }
        guard let position = logicalIndices.firstIndex(of: stringIndex)
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let upper: Int
        if position + 1 < logicalIndices.count
        {
            upper = logicalIndices[position + 1]
        }
        else
        {
            upper = runRange.location + runRange.length
        }
        guard stringIndex >= runRange.location,
              stringIndex < upper,
              upper <= runRange.location + runRange.length
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        let mapped = slices(
            for: NSRange(
                location: documentOffset + stringIndex,
                length: upper - stringIndex
            ),
            segments: segments,
            text: text
        )
        guard !mapped.isEmpty,
              mapped.reduce(0, { $0 + $1.text.utf16.count })
                == upper - stringIndex
        else
        {
            throw LayoutFailure.invalidNativeSourceRange
        }
        return mapped
    }
}
