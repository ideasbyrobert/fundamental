enum CanonicalBlockStyle:
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
        }
    }

    var semanticKind: SemanticBlockKind
    {
        switch self
        {
        case .title, .heading, .subheading:
            .heading
        case .body:
            .paragraph
        case .monostyled:
            .code
        }
    }

    var headingLevel: Int?
    {
        switch self
        {
        case .title:
            1
        case .heading:
            2
        case .subheading:
            3
        case .body, .monostyled:
            nil
        }
    }

    var roleHint: SemanticRoleHint
    {
        switch self
        {
        case .title:
            .title
        case .heading:
            .heading2
        case .subheading:
            .heading3
        case .body:
            .body
        case .monostyled:
            .code
        }
    }
}
