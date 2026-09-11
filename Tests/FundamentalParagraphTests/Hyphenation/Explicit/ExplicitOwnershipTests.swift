@testable import FundamentalParagraph
import FundamentalDocument
import Testing

@Suite
struct ExplicitOwnershipTests
{
    @Test(
        arguments: NativeWordScopeTests.allowedTraits, ["left", "mark", "right"]
    )
    func markerOwnsConditionalInkAcrossEveryTraitPlacement(
        _ traits: Set<SemanticInlineTrait>, _ placement: String
    ) throws
    {
        let source = try WordFixture.source([
            WordFixture.run("extra", traits: placement == "left" ? traits : []),
            WordFixture.run(
                "\u{AD}", traits: placement == "mark" ? traits : []
            ),
            WordFixture.run(
                "ordinary", traits: placement == "right" ? traits : []
            )
        ])
        let collection = ExplicitParagraphHyphens(source)
        let value = try collection.opportunity(at: 0)
        #expect(value.owner == .init(
            runIndex: 1, paragraphRange: 5..<6, runRange: 0..<1
        ))
        let slices = try ExplicitFixture.allSlices(collection)
        let selected = try #require(slices.dropFirst().first)
        #expect(selected.text == "extra‐")
        let glyph = try #require(selected.atoms.last)
        #expect(glyph.kind == .conditionalHyphen)
        #expect(glyph.fragment == value.owner)
        let owner = selected.source.paragraph.runs[glyph.fragment.runIndex]
        #expect(owner.traits == (placement == "mark" ? traits : []))
        for slice in slices
        {
            _ = try ExplicitFixture.reconstructed(slice)
        }
        let names = traits.map(\.rawValue).sorted().joined(separator: "-")
        try ExplicitEvidence.write(
            "traits-" + placement + "-" + names,
            collection: collection, slices: slices
        )
    }

    @Test
    func linkAndLanguageStayOnMarkerAcrossEmptyRuns() throws
    {
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let language = try WordFixture.language("en_GB")
        let source = try WordFixture.source([
            WordFixture.run("extra"),
            WordFixture.scoped(
                "", .language(WordFixture.language("ru_RU")),
                traits: [.inlineCode]
            ),
            WordFixture.scoped(
                "\u{AD}", .linkAndLanguage(link: link, language: language),
                traits: [.strong, .underline]
            ),
            WordFixture.run(""),
            WordFixture.run("ordinary")
        ], language: "en_GB")
        let collection = ExplicitParagraphHyphens(source)
        let value = try collection.opportunity(at: 0)
        #expect(value.owner == .init(
            runIndex: 2, paragraphRange: 5..<6, runRange: 0..<1
        ))
        let slices = try ExplicitFixture.allSlices(collection)
        #expect(slices[1].source.paragraph.runs[2].attributes
            == source.paragraph.runs[2].attributes)
        #expect(slices[1].source.paragraph.runs.count == 5)
        for slice in slices
        {
            _ = try ExplicitFixture.reconstructed(slice)
        }
        try ExplicitEvidence.write(
            "link-owner", collection: collection, slices: slices
        )
    }
}
