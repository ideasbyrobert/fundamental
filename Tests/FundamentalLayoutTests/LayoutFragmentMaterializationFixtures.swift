import Testing

@testable import FundamentalDocument

extension LayoutFragmentMaterializationTests
{
    func emptyTable(
        withRows: Bool = false
    ) throws -> SemanticBlock
    {
        let headers = withRows
            ? [HeaderSemanticTableRow(cells: [])]
            : []
        let bodies = withRows
            ? [BodySemanticTableRow(cells: [])]
            : []
        let content = try #require(SemanticTableContent(
            headerRows: headers,
            bodyRows: bodies,
            columnAlignments: []
        ))
        return .table(.semantic(.regular(
            RegularSemanticTable(content: content)
        )))
    }

    func demandingRuns() throws -> [SemanticRun]
    {
        let link = try #require(
            SemanticLinkDestination("https://fundamental.test/路径")
        )
        let language = try #require(
            SemanticLanguageIdentifier("hy-Armenian")
        )
        return [
            LayoutFixture.direct(
                "cafe\u{301} कि ✈️ 👩🏽‍💻 🇦🇲",
                traits: [.underline, .strikethrough]
            ),
            .scoped(SemanticScopedRun(
                text: " scoped 😀",
                traits: [.emphasis],
                scopes: .linkAndLanguage(
                    link: link,
                    language: language
                )
            ))
        ]
    }

    func longParagraph(_ word: String) -> SemanticBlock
    {
        .paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct(String(
                repeating: "\(word) finite resident truth. ",
                count: 36
            ))
        ]))
    }
}
