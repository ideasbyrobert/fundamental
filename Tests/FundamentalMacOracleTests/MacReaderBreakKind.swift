@testable import FundamentalDocument

enum MacReaderBreakKind: CaseIterable, Sendable
{
    case paragraph
    case code
    case bulleted
    case numbered

    @MainActor
    func block(_ text: String) -> SemanticBlock
    {
        block(runs: [SemanticRun(text: text)])
    }

    @MainActor
    func block(runs: [SemanticRun]) -> SemanticBlock
    {
        switch self
        {
        case .paragraph:
            .paragraph(SemanticParagraph(runs: runs))
        case .code:
            .code(.plain(PlainSemanticCodeBlock(runs: runs)))
        case .bulleted:
            .listItem(SemanticListItem(kind: .bulleted, runs: runs))
        case .numbered:
            .listItem(SemanticListItem(kind: .numbered, runs: runs))
        }
    }
}
