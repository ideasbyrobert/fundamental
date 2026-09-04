import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    func expectBlockLocalFontAssociation() throws
    {
        let value = try product([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("Prose font")
            ])),
            .code(.plain(PlainSemanticCodeBlock(runs: [
                LayoutFixture.direct("code font")
            ])))
        ])
        let proseFonts = try #require(
            value.indexed.resolvedFonts(atBlockOrdinal: 0)
        )
        let codeFonts = try #require(
            value.indexed.resolvedFonts(atBlockOrdinal: 1)
        )
        let layout = NativeTextKit2Layout()
        let laid = try layout.blockLayout(
            value.projection.firstBlock,
            originY: 0,
            parameters: value.request.parameters
        )
        let global = Set(
            value.index.lineage.specification.resolvedFonts
        )
        #expect(Set(codeFonts).isSubset(of: global))
        #expect(layout.reconstructedFontsAreAdmitted(
            laid,
            as: proseFonts
        ))
        #expect(!layout.reconstructedFontsAreAdmitted(
            laid,
            as: codeFonts
        ))
    }
}
