import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("preedit forwards clause ranges with canonical base appearance")
    @MainActor
    func markedAppearance() throws
    {
        let source = NSMutableAttributedString(string: "e\u{301}😀")
        source.addAttributes([
            .font: NSFont.systemFont(ofSize: 88), .foregroundColor: NSColor.red,
            .markedClauseSegment: 3, .underlineStyle: 2
        ], range: NSRange(location: 0, length: 2))
        source.addAttributes([
            .markedClauseSegment: 7, .underlineColor: NSColor.blue,
            .backgroundColor: NSColor.yellow
        ], range: NSRange(location: 2, length: 2))
        let base = try #require(WritingTypography.body[.font] as? NSFont)
        let candidate = try #require(WritingMarkedInput(source,
            attributes: WritingTypography.body)).text
        #expect(candidate.string.utf16.elementsEqual(source.string.utf16))
        for offset in 0 ..< candidate.length
        {
            let attributes = candidate.attributes(at: offset,
                                                   effectiveRange: nil)
            #expect(attributes[.font] as? NSFont == base)
            #expect(attributes[.foregroundColor] as? NSColor != .red)
            #expect(attributes[.markedClauseSegment] as? Int ==
                (offset < 2 ? 3 : 7))
        }
        #expect(candidate.attribute(.underlineStyle, at: 0,
                                     effectiveRange: nil) as? Int == 2)
        #expect(candidate.attribute(.backgroundColor, at: 2,
            effectiveRange: nil) as? NSColor == .yellow)
        #expect(candidate.attribute(.underlineColor, at: 2,
            effectiveRange: nil) as? NSColor == .blue)
    }
}
