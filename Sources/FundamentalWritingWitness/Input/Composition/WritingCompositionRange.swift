import Foundation

struct WritingCompositionRange
{
    static func valid(_ range: NSRange, in text: String) -> Bool
    {
        let (end, overflow) = range.location.addingReportingOverflow(
            range.length
        )
        let source = text as NSString
        guard !overflow, range.location >= 0, range.length >= 0,
              end <= source.length
        else
        {
            return false
        }
        return boundary(range.location, in: source) && boundary(end, in: source)
    }

    static func boundary(_ offset: Int, in text: NSString) -> Bool
    {
        offset == text.length ||
            !(0xDC00 ... 0xDFFF).contains(text.character(at: offset))
    }

    static func string(_ value: Any) -> String?
    {
        (value as? String) ?? (value as? NSAttributedString)?.string
    }
}
