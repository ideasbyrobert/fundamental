import AppKit
import Testing

extension WritingScopeFixture
{
    @MainActor
    static func expect(
        _ form: Int, in attributes: [NSAttributedString.Key: Any]
    )
    {
        let destination = attributes[.link] as? String
        let identifier = attributes[.languageIdentifier] as? String
        if form == 1
        {
            #expect(destination == nil)
        }
        else
        {
            #expect(destination?.utf16.elementsEqual(link.utf16) == true)
        }
        if form == 0
        {
            #expect(identifier == nil)
        }
        else
        {
            #expect(identifier?.utf16.elementsEqual(language.utf16) == true)
        }
    }
}
