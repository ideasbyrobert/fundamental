import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func captionFont() throws -> NSFont
    {
        try serifFont(ofSize: 14, weight: .regular)
    }

}
