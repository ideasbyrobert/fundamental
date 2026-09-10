import Testing

@testable import FundamentalDocument

extension CanonicalBlockStyleMappingTests
{
    @Test("every style constructs its exact semantic block")
    func blockConstructionIsExact() throws
    {
        let link = try #require(
            SemanticLinkDestination("chapter")
        )
        let runSets: [[SemanticRun]] = [
            [],
            [SemanticRun(text: "Content")],
            [
                .scoped(
                    SemanticScopedRun(
                        text: "Scoped",
                        scopes: .link(link)
                    )
                )
            ]
        ]

        for runs in runSets
        {
            let sections = SemanticHeadingLevel.allCases.map
            {
                SemanticBlock.heading(.section(SectionSemanticHeading(
                    runs: runs, level: $0
                )))
            }
            let expected: [SemanticBlock] = [
                .heading(
                    .title(
                        TitleSemanticHeading(runs: runs)
                    )
                )
            ] + sections + [
                .paragraph(SemanticParagraph(runs: runs)),
                .code(
                    .plain(
                        PlainSemanticCodeBlock(runs: runs)
                    )
                ),
                .listItem(SemanticListItem(kind: .bulleted, runs: runs)),
                .listItem(SemanticListItem(kind: .numbered, runs: runs))
            ]
            let actual = CanonicalBlockStyle.allCases.map
            {
                $0.semanticBlock(runs: runs)
            }

            #expect(actual == expected)
        }
    }
}
