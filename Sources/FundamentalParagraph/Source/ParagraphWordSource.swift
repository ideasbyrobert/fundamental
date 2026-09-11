import FundamentalDocument
import FundamentalWrapping

package struct ParagraphWordSource: Sendable
{
    package let paragraph: SemanticParagraph
    package let source: WrappingSource
    package let spans: [ParagraphRunSpan]
    let occupiedSpans: [ParagraphRunSpan]
    let hardEndings: [Range<Int>]

    package init(
        _ paragraph: SemanticParagraph,
        defaultLanguage: SemanticLanguageIdentifier
    )
    {
        self.paragraph = paragraph
        source = WrappingSource(paragraph.runs.map(\.text).joined())
        var spans: [ParagraphRunSpan] = []
        var offset = 0
        for (index, run) in paragraph.runs.enumerated()
        {
            let end = offset + run.text.utf16.count
            spans.append(ParagraphRunSpan(
                index: index, range: offset..<end,
                attributes: run.attributes,
                language: Self.language(run, default: defaultLanguage)
            ))
            offset = end
        }
        self.spans = spans
        occupiedSpans = spans.filter { !$0.range.isEmpty }
        hardEndings = source.lines.map(\.endingRange).filter { !$0.isEmpty }
    }
}
