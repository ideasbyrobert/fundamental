import Testing

@testable import FundamentalDocument

extension SemanticTableTests
{
    @Test("reconstruction leaves the original table unchanged")
    func reconstructionLeavesOriginalTableUnchanged()
    {
        let original = SemanticTable.regular(
            RegularSemanticTable(content: Self.content())
        )
        let changed = SemanticTable.captioned(
            CaptionedSemanticTable(
                content: Self.content(alignment: .center),
                caption: Self.caption("Changed")
            )
        )

        #expect(original != changed)
        #expect(original.content == Self.content())
    }
}
