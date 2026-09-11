import AppKit
import CoreText

extension NativeTextKit2Layout
{
    func captionFont() throws -> NSFont
    {
        try serifFont(ofSize: 14, weight: .regular)
    }

}
