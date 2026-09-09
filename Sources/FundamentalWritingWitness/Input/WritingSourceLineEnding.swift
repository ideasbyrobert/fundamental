import Foundation

enum WritingSourceLineEnding
{
    static func at(_ offset: Int, in source: NSString) -> String?
    {
        guard offset >= 0, offset <= source.length
        else
        {
            return nil
        }
        for index in offset ..< source.length
        {
            if source.character(at: index) == 0x0D
            {
                return index + 1 < source.length &&
                    source.character(at: index + 1) == 0x0A ? "\r\n" : "\r"
            }
            if source.character(at: index) == 0x0A
            {
                return index > 0 &&
                    source.character(at: index - 1) == 0x0D ? "\r\n" : "\n"
            }
        }
        var index = offset
        while index > 0
        {
            index -= 1
            if source.character(at: index) == 0x0A
            {
                return index > 0 &&
                    source.character(at: index - 1) == 0x0D ? "\r\n" : "\n"
            }
            if source.character(at: index) == 0x0D
            {
                return "\r"
            }
        }
        return "\n"
    }
}
