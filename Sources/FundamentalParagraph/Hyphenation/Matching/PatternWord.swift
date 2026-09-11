package struct PatternWord: Sendable
{
    package let text: String
    package let scalars: [UInt32]
    package let boundaries: [PatternBoundary]

    package init(_ text: String) throws(PatternFailure)
    {
        let scalars = text.unicodeScalars.map(\.value)
        guard !scalars.contains(46)
        else
        {
            throw .invalidWord
        }
        var boundaries = [PatternBoundary(scalar: 0, utf16: 0)]
        var scalar = 0
        var utf16 = 0
        for character in text
        {
            scalar += character.unicodeScalars.count
            utf16 += character.utf16.count
            boundaries.append(.init(scalar: scalar, utf16: utf16))
        }
        self.text = text
        self.scalars = scalars
        self.boundaries = boundaries
    }
}
