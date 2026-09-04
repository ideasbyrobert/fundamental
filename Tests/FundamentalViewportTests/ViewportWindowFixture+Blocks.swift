@testable import FundamentalDocument

extension ViewportWindowFixture
{
    static func paragraph(
        _ text: String,
        traits: Set<SemanticInlineTrait> = []
    ) -> SemanticBlock
    {
        .paragraph(SemanticParagraph(runs: [run(text, traits: traits)]))
    }

    static func fixedBlocks(
        count: Int,
        prefix: String
    ) -> [SemanticBlock]
    {
        (0 ..< count).map
        {
            paragraph("\(prefix) \($0) finite resident line")
        }
    }

    static func largeBlock() -> SemanticBlock
    {
        paragraph(String(
            repeating: "one complete selected block remains truthful. ",
            count: 80
        ))
    }
}
