package struct WrappingSource: Hashable, Sendable
{
    package let text: String
    package let utf16: [UInt16]
    package let graphemeBoundaries: [Int]
    package let lines: [WrappingSourceLine]

    package init(_ text: String)
    {
        self.text = text
        utf16 = Array(text.utf16)
        var boundaries = [0]
        var lines: [WrappingSourceLine] = []
        var offset = 0
        var start = 0
        for character in text
        {
            let end = offset + character.utf16.count
            if let ending = WrappingLineEnding(character)
            {
                lines.append(WrappingSourceLine(
                    contentRange: start ..< offset,
                    endingRange: offset ..< end,
                    ending: ending
                ))
                start = end
            }
            boundaries.append(end)
            offset = end
        }
        lines.append(WrappingSourceLine(
            contentRange: start ..< offset,
            endingRange: offset ..< offset,
            ending: nil
        ))
        graphemeBoundaries = boundaries
        self.lines = lines
    }
}
