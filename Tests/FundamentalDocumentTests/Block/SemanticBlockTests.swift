import Testing

@testable import FundamentalDocument

@Suite("A semantic block")
struct SemanticBlockTests
{
    @Test("all four forms preserve their exact occupied leaves")
    func formsPreserveExactOccupiedLeaves()
    {
        let run = SemanticRun(text: "Text")
        let paragraph = SemanticParagraph(runs: [run])
        let heading = SemanticHeading.title(
            TitleSemanticHeading(runs: [run])
        )
        let code = SemanticCodeBlock.plain(
            PlainSemanticCodeBlock(runs: [run])
        )
        let table = Self.emptyTableRecord()
        let blocks: [SemanticBlock] = [
            .paragraph(paragraph),
            .heading(heading),
            .code(code),
            .table(table)
        ]

        for block in blocks
        {
            switch block
            {
            case let .paragraph(actual):
                #expect(actual == paragraph)
            case let .heading(actual):
                #expect(actual == heading)
            case let .code(actual):
                #expect(actual == code)
            case let .table(actual):
                #expect(actual == table)
            }
        }
    }

    @Test("all four forms derive their exact semantic kinds")
    func formsDeriveExactSemanticKinds()
    {
        let run = SemanticRun(text: "")
        let blocks: [(SemanticBlock, SemanticBlockKind)] = [
            (
                .paragraph(SemanticParagraph(runs: [run])),
                .paragraph
            ),
            (
                .heading(.title(TitleSemanticHeading(runs: [run]))),
                .heading
            ),
            (
                .code(.plain(PlainSemanticCodeBlock(runs: [run]))),
                .code
            ),
            (
                .table(Self.emptyTableRecord()),
                .table
            )
        ]

        for (block, kind) in blocks
        {
            #expect(block.kind == kind)
        }
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let run = SemanticRun(text: "Original")
        let original = SemanticBlock.paragraph(
            SemanticParagraph(runs: [run])
        )
        let replacement = SemanticBlock.code(
            .plain(
                PlainSemanticCodeBlock(
                    runs: [SemanticRun(text: "Replacement")]
                )
            )
        )

        #expect(
            original == .paragraph(SemanticParagraph(runs: [run]))
        )
        #expect(replacement != original)
    }
}
