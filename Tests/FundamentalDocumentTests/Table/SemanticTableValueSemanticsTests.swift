import Testing

@testable import FundamentalDocument

extension SemanticTableTests
{
    @Test("reconstruction leaves the original table unchanged")
    func reconstructionLeavesOriginalTableUnchanged() throws
    {
        let original = SemanticTable.regular(
            RegularSemanticTable(content: try Self.content())
        )
        let changed = SemanticTable.captioned(
            CaptionedSemanticTable(
                content: try Self.content(alignment: .center),
                caption: Self.caption("Changed")
            )
        )

        let expected = try Self.content()
        #expect(original != changed)
        #expect(original.content == expected)
    }
}
