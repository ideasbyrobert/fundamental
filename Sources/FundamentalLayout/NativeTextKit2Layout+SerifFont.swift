import AppKit
import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func serifFont(
        ofSize size: Double,
        weight: NSFont.Weight
    ) throws -> NSFont
    {
        let base = NSFont.systemFont(
            ofSize: size,
            weight: weight
        )
        guard let descriptor = base.fontDescriptor.withDesign(.serif),
              let resolved = NSFont(
                  descriptor: descriptor,
                  size: size
              )
        else
        {
            throw LayoutFailure.missingResolvedFontIdentity
        }
        return resolved
    }

}
