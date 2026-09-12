import Foundation

struct WritingFindQuery: Equatable, Sendable
{
    let text: String
    let caseSensitive: Bool

    init?(_ text: String, caseSensitive: Bool)
    {
        guard !text.isEmpty,
              text.utf16.count <= WritingSurfacePolicy.maximumUTF16Units,
              Self.isSingleLine(text)
        else
        {
            return nil
        }
        self.text = text
        self.caseSensitive = caseSensitive
    }

    static func isSingleLine(_ text: String) -> Bool
    {
        !text.unicodeScalars.contains { CharacterSet.newlines.contains($0) }
    }
}
