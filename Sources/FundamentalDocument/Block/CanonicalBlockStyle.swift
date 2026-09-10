package enum CanonicalBlockStyle:
    String,
    Codable,
    CaseIterable,
    Sendable
{
    case title
    case heading1
    case heading
    case subheading
    case heading4
    case heading5
    case heading6
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
        case .heading1:
            Self.section(.one, runs: runs)
        case .heading:
            Self.section(.two, runs: runs)
        case .subheading:
            Self.section(.three, runs: runs)
        case .heading4:
            Self.section(.four, runs: runs)
        case .heading5:
            Self.section(.five, runs: runs)
        case .heading6:
            Self.section(.six, runs: runs)
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

    private static func section(
        _ level: SemanticHeadingLevel, runs: [SemanticRun]
    ) -> SemanticBlock
    {
        .heading(.section(SectionSemanticHeading(runs: runs, level: level)))
    }
}
