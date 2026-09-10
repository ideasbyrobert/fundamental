import AppKit

extension MacAccessibilityElement
{
    nonisolated static func validTextRange(
        _ range: NSRange, source: String
    ) -> Bool
    {
        let value = source as NSString
        guard range.location >= 0, range.length >= 0,
              range.location <= value.length,
              range.length <= value.length - range.location
        else
        {
            return false
        }
        return scalarBoundary(range.location, value: value)
            && scalarBoundary(range.location + range.length, value: value)
    }

    nonisolated static func scalarBoundary(
        _ index: Int, value: NSString
    ) -> Bool
    {
        guard index > 0, index < value.length
        else
        {
            return true
        }
        let previous = value.character(at: index - 1)
        let next = value.character(at: index)
        return !(0xD800...0xDBFF).contains(previous)
            || !(0xDC00...0xDFFF).contains(next)
    }
}
