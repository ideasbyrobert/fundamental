struct WritingSurfacePolicy
{
    static let maximumUTF16Units = 1_048_576
    static let maximumParagraphs = 16_384
    static let readableMeasure = 720.0

    static func admits(_ text: String) -> Bool
    {
        text.utf16.count <= maximumUTF16Units
    }
}
