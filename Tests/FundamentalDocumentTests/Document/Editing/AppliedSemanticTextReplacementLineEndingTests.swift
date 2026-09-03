import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    @Test("prose refuses and code preserves CR and LF")
    func blockFormsApplyLineEndingPolicy() throws
    {
        let prose = [
            Self.paragraph([SemanticRun(text: "AB")]),
            Self.title([SemanticRun(text: "AB")])
        ]
        for block in prose
        {
            for text in ["\n", "\r", "\r\n"]
            {
                let blocks: [(UInt8, SemanticBlock)] = [(2, block)]
                let result = try Self.apply(
                    text: text,
                    start: 0,
                    end: 1,
                    blocks: blocks
                )
                #expect(result == nil)
            }
        }

        let admittedProse: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([SemanticRun(text: "A\nB")]))
        ]
        let admittedCandidate = try Self.apply(
            text: "X",
            start: 0,
            end: 1,
            blocks: admittedProse
        )
        let admittedResult = try #require(admittedCandidate)
        #expect(try Self.text(in: admittedResult) == "X\nB")

        let code = try [
            Self.plainCode([SemanticRun(text: "AB")]),
            Self.taggedCode([SemanticRun(text: "AB")])
        ]
        for block in code
        {
            for text in ["\n", "\r", "\r\n"]
            {
                let blocks: [(UInt8, SemanticBlock)] = [(2, block)]
                let candidate = try Self.apply(
                    text: text,
                    start: 0,
                    end: 1,
                    blocks: blocks
                )
                let result = try #require(candidate)
                #expect(try Self.text(in: result) == text + "B")
            }
        }
    }
}
