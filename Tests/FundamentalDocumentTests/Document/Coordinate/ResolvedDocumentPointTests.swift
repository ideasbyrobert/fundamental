import Testing

@testable import FundamentalDocument

@Suite("Resolved document points")
struct ResolvedDocumentPointTests
{
    @Test("resolution preserves the point and first block position")
    func resolutionPreservesPointAndBlockPosition() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["AB", "CD"]))
        ])
        let point = try Self.point(offset: 1)
        let resolved = try #require(
            ResolvedDocumentPoint(point, in: document)
        )

        #expect(resolved.point == point)
        #expect(resolved.blockIndex == 0)
        #expect(resolved.runPosition == .run(
            index: 0,
            utf16Offset: try Self.offset(1)
        ))
    }

    @Test("later canonical blocks retain their exact indices")
    func laterBlocksRetainIndices() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["First"])),
            (7, Self.paragraph(["Later"]))
        ])
        let point = try Self.point(blockMarker: 7, offset: 5)
        let resolved = try #require(
            ResolvedDocumentPoint(point, in: document)
        )

        #expect(resolved.blockIndex == 1)
        #expect(resolved.runPosition == .run(
            index: 0,
            utf16Offset: try Self.offset(5)
        ))
    }

    @Test("every editable semantic form resolves")
    func everyEditableSemanticFormResolves() throws
    {
        let run = SemanticRun(text: "A")
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        let blocks: [SemanticBlock] = [
            .paragraph(SemanticParagraph(runs: [run])),
            .heading(.title(TitleSemanticHeading(runs: [run]))),
            .heading(.section(SectionSemanticHeading(
                runs: [run],
                level: .six
            ))),
            .code(.plain(PlainSemanticCodeBlock(runs: [run]))),
            .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
                runs: [run],
                language: language
            )))
        ]

        for block in blocks
        {
            let document = try Self.document(blocks: [(2, block)])
            let point = try Self.point(offset: 1)
            #expect(ResolvedDocumentPoint(point, in: document) != nil)
        }
    }
}
