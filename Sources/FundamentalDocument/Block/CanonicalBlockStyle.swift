package enum CanonicalBlockStyle:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case title
    case heading
    case subheading
    case body
    case monostyled
    case bulleted
    case numbered

    func semanticBlock(
        runs: [SemanticRun]
    ) -> SemanticBlock
    {
        switch self
        {
        case .title:
            .heading(
                .title(
                    TitleSemanticHeading(runs: runs)
                )
            )
        case .heading:
            .heading(
                .section(
                    SectionSemanticHeading(
                        runs: runs,
                        level: .two
                    )
                )
            )
        case .subheading:
            .heading(
                .section(
                    SectionSemanticHeading(
                        runs: runs,
                        level: .three
                    )
                )
            )
        case .body:
            .paragraph(
                SemanticParagraph(runs: runs)
            )
        case .monostyled:
            .code(
                .plain(
                    PlainSemanticCodeBlock(runs: runs)
                )
            )
        case .bulleted:
            .listItem(SemanticListItem(kind: .bulleted, runs: runs))
        case .numbered:
            .listItem(SemanticListItem(kind: .numbered, runs: runs))
        }
    }
}
