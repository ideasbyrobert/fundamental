import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func codeReturnChoosesTheSourceLineEndingWithoutRewritingText()
    {
        for (source, offset, expected) in [
            ("", 0, "\n"), ("AB", 1, "\n"),
            ("A\r\nB\rC\nD", 0, "\r\n"),
            ("A\r\nB\rC\nD", 3, "\r"),
            ("A\r\nB\rC\nD", 5, "\n"),
            ("A\r\nB\rC\nD", 8, "\n"),
            ("X\r\n", 3, "\r\n"), ("X\r", 2, "\r"),
            ("X\r\nY", 4, "\r\n"), ("X\rY", 3, "\r"),
            ("e\u{301} 😀\r\n", 0, "\r\n")
        ]
        {
            #expect(WritingSourceLineEnding.at(offset,
                in: source as NSString) == expected)
        }
        #expect(WritingSourceLineEnding.at(-1, in: "X") == nil)
        #expect(WritingSourceLineEnding.at(2, in: "X") == nil)
    }

    @Test(arguments: [false, true])
    func codeReturnUsesItsOwnBlockInsteadOfGeneratedSeams(tagged: Bool)
        throws
    {
        let fixture = try WritingCodeFixture.document("A\r\nB", tagged: tagged)
        let projection = try fixture.projection()
        for range in [NSRange(location: 7, length: 0),
                      NSRange(location: 11, length: 0),
                      NSRange(location: 7, length: 4)]
        {
            let context = try #require(WritingTextContext(range,
                                                          in: projection))
            #expect(context.lineEnding(in: projection) == "\r\n")
        }
        let prose = try #require(WritingTextContext(
            NSRange(location: 0, length: 0), in: projection
        ))
        #expect(prose.lineEnding(in: projection) == nil)
    }
}
