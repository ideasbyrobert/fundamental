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
            let expected: [SemanticBlock] = [
                .heading(
                    .title(
                        TitleSemanticHeading(runs: runs)
                    )
                ),
                .heading(
                    .section(
                        SectionSemanticHeading(
                            runs: runs,
                            level: .two
                        )
                    )
                ),
                .heading(
                    .section(
                        SectionSemanticHeading(
                            runs: runs,
                            level: .three
                        )
                    )
                ),
                .paragraph(SemanticParagraph(runs: runs)),
                .code(
                    .plain(
                        PlainSemanticCodeBlock(runs: runs)
                    )
                )
            ]
            let actual = CanonicalBlockStyle.allCases.map
            {
                $0.semanticBlock(runs: runs)
            }

            #expect(actual == expected)
        }
    }
}
