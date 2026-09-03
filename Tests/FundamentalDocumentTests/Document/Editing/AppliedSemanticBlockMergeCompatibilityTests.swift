import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
{
    @Test("paragraphs merge with exact form")
    func paragraphsMergeWithExactForm() throws
    {
        let runs = try Self.contrastingRuns()
        let cases = [
            runs,
            ([], runs.1),
            (runs.0, []),
            ([], [])
        ]
        for pair in cases
        {
            let result = try Self.merge(
                Self.paragraph(pair.0),
                Self.paragraph(pair.1)
            )
            #expect(result.document.content.firstBlock.block ==
                Self.paragraph(pair.0 + pair.1))
            let seam = pair.0.map(\.text).joined().utf16.count
            #expect(result.caret.point.utf16Offset.value == seam)
            let resolved = try #require(ResolvedDocumentPoint(
                result.caret.point,
                in: result.document
            ))
            #expect(result.caret == resolved)
        }
    }

    @Test("titles merge with exact form")
    func titlesMergeWithExactForm() throws
    {
        let runs = try Self.contrastingRuns()
        let result = try Self.merge(
            Self.title(runs.0),
            Self.title(runs.1)
        )
        #expect(result.document.content.firstBlock.block ==
            Self.title(runs.0 + runs.1))
    }

    @Test("identical section levels merge with exact form")
    func identicalSectionLevelsMergeWithExactForm() throws
    {
        let runs = try Self.contrastingRuns()
        for level in SemanticHeadingLevel.allCases
        {
            let result = try Self.merge(
                Self.section(runs.0, level: level),
                Self.section(runs.1, level: level)
            )
            #expect(result.document.content.firstBlock.block == Self.section(
                runs.0 + runs.1,
                level: level
            ))
        }
    }

    @Test("plain code blocks merge with exact form")
    func plainCodeBlocksMergeWithExactForm() throws
    {
        let runs = try Self.contrastingRuns(
            leadingText: "A\n",
            trailingText: "B\r"
        )
        let result = try Self.merge(
            Self.plainCode(runs.0),
            Self.plainCode(runs.1)
        )
        #expect(result.document.content.firstBlock.block ==
            Self.plainCode(runs.0 + runs.1))
    }

    @Test("equal tagged code languages merge with exact form")
    func equalTaggedCodeLanguagesMergeWithExactForm() throws
    {
        let runs = try Self.contrastingRuns()
        let leading = try Self.taggedCode(
            runs.0,
            language: "hy"
        )
        let trailing = try Self.taggedCode(
            runs.1,
            language: "hy"
        )
        let result = try Self.merge(leading, trailing)

        #expect(result.document.content.firstBlock.block ==
            (try Self.taggedCode(runs.0 + runs.1, language: "hy")))
    }
}
