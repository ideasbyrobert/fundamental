import Testing

@testable import FundamentalDocument

@Suite("A semantic table")
struct SemanticTableTests
{
    static func content(
        alignment: SemanticTableColumnAlignment = .leading
    ) throws -> SemanticTableContent
    {
        try #require(SemanticTableContent(
            headerRows: [HeaderSemanticTableRow(cells: [])],
            bodyRows: [BodySemanticTableRow(cells: [])],
            columnAlignments: [alignment]
        ))
    }

    static func caption(
        _ text: String = "Caption"
    ) -> SemanticTableCaption
    {
        SemanticTableCaption(
            firstRun: SemanticRun(text: text),
            remainingRuns: []
        )
    }

    @Test("regular and captioned forms preserve exact leaves")
    func regularAndCaptionedFormsPreserveExactLeaves() throws
    {
        let content = try Self.content()
        let caption = Self.caption()
        let regular = RegularSemanticTable(content: content)
        let captioned = CaptionedSemanticTable(
            content: content,
            caption: caption
        )

        #expect(SemanticTable.regular(regular) == .regular(regular))
        #expect(
            SemanticTable.captioned(captioned) == .captioned(captioned)
        )
    }

    @Test("content projection exposes only canonical facts")
    func contentProjectionExposesOnlyCanonicalFacts() throws
    {
        let regularContent = try Self.content(alignment: .leading)
        let captionedContent = try Self.content(alignment: .trailing)
        let regular = SemanticTable.regular(
            RegularSemanticTable(content: regularContent)
        )
        let captioned = SemanticTable.captioned(
            CaptionedSemanticTable(
                content: captionedContent,
                caption: Self.caption()
            )
        )

        #expect(regular.content == regularContent)
        #expect(captioned.content == captionedContent)
    }
}
