import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingInlineFixture
{
    @MainActor
    static func expect(
        _ traits: Set<SemanticInlineTrait>,
        in attributes: [NSAttributedString.Key: Any], base: NSFont
    ) throws
    {
        let font = try #require(attributes[.font] as? NSFont)
        #expect(font.pointSize == base.pointSize)
        let symbolic = font.fontDescriptor.symbolicTraits
        if traits.contains(.strong)
        {
            #expect(symbolic.contains(.bold))
        }
        if traits.contains(.emphasis)
        {
            #expect(symbolic.contains(.italic))
        }
        if traits.contains(.inlineCode)
        {
            #expect(font.isFixedPitch)
        }
        if base.fontDescriptor.symbolicTraits.contains(.bold)
        {
            #expect(symbolic.contains(.bold))
        }
        let underline = attributes[.underlineStyle] as? Int ?? 0
        let strike = attributes[.strikethroughStyle] as? Int ?? 0
        #expect(underline == (traits.contains(.underline) ? 1 : 0))
        #expect(strike == (traits.contains(.strikethrough) ? 1 : 0))
        let value = attributes[.baselineOffset] as? NSNumber
        let baseline = value?.doubleValue ?? 0
        let expected = traits.contains(.subscriptText) ? -base.pointSize * 0.2 :
            traits.contains(.superscript) ? base.pointSize * 0.3 : 0
        #expect(abs(baseline - expected) < 0.001)
    }
}
