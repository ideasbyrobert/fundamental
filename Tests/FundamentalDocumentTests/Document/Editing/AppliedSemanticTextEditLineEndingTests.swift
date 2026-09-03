import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextEditTests
{
    @Test("paragraph and heading refuse CR and LF")
    func paragraphAndHeadingRefuseLineEndings() throws
    {
        let blocks = [
            Self.paragraph([SemanticRun(text: "AB")]),
            Self.title([SemanticRun(text: "AB")])
        ]
        for block in blocks
        {
            for text in ["\n", "\r", "\r\n"]
            {
                let result = try Self.apply(
                    text: text,
                    at: 1,
                    blocks: [(2, block)]
                )
                #expect(result == nil)
            }
        }
    }

    @Test("both code forms preserve CR and LF")
    func bothCodeFormsPreserveLineEndings() throws
    {
        let blocks = try [
            Self.plainCode([SemanticRun(text: "AB")]),
            Self.taggedCode([SemanticRun(text: "AB")])
        ]
        for block in blocks
        {
            for text in ["\n", "\r", "\r\n"]
            {
                let typedBlocks: [(UInt8, SemanticBlock)] = [(2, block)]
                let candidate = try Self.apply(
                    text: text,
                    at: 1,
                    blocks: typedBlocks
                )
                let result = try #require(candidate)
                #expect(try Self.text(in: result) == "A" + text + "B")
            }
        }
    }
}
