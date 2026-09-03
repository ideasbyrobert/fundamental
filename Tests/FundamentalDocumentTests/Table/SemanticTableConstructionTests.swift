import Testing

@testable import FundamentalDocument

extension SemanticTableTests
{
    @Test("only the captioned form owns a caption")
    func onlyCaptionedFormOwnsCaption() throws
    {
        let regular = SemanticTable.regular(
            RegularSemanticTable(content: try Self.content())
        )
        let caption = Self.caption()
        let captioned = SemanticTable.captioned(
            CaptionedSemanticTable(
                content: try Self.content(),
                caption: caption
            )
        )

        guard case .regular = regular,
              case let .captioned(table) = captioned
        else
        {
            Issue.record("Expected exact table forms")
            return
        }
        #expect(table.caption == caption)
    }
}
