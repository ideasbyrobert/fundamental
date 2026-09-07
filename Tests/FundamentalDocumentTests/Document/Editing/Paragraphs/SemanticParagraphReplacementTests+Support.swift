import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    func request(
        in source: SessionTestDocument,
        from start: (Int, Int),
        to end: (Int, Int),
        text: [String]
    ) throws -> SemanticParagraphReplacement
    {
        let range = try #require(DocumentRange(
            start: source.point(start.1, block: start.0),
            end: source.point(end.1, block: end.0)
        ))
        return try #require(SemanticParagraphReplacement(
            range: range,
            paragraphs: text.map
            {
                SemanticParagraph(runs: $0.isEmpty ? [] : [
                    SemanticRun(text: $0)
                ])
            },
            continuationBlockIDs: text.dropFirst().enumerated().map
            {
                FundamentalBlockID(SessionTestDocument.identity(
                    UInt8($0.offset + 100)
                ))
            }
        ))
    }

    func text(_ document: CanonicalDocument) -> [String]
    {
        document.content.blocks.map
        {
            guard case let .paragraph(paragraph) = $0.block
            else
            {
                return "Unsupported"
            }
            return paragraph.runs.map(\.text).joined()
        }
    }
}
