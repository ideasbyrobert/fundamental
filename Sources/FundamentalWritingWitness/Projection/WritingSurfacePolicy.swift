struct WritingSurfacePolicy
{
    static let maximumUTF16Units = 1_048_576
    static let maximumParagraphs = 16_384
    static let readableMeasure = 720.0

    static func admits(
        _ text: String, allowingLineBreaks: Bool = false
    ) -> Bool
    {
        guard text.utf16.count <= maximumUTF16Units
        else
        {
            return false
        }
        return allowingLineBreaks || !text.unicodeScalars.contains
        {
            $0.value == 0x0A || $0.value == 0x0D
        }
    }
}
