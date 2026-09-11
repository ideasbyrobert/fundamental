@testable import FundamentalParagraph
import Testing

@Suite
struct ExplicitRefusalTests
{
    @Test(arguments: ExplicitRefusalCases.all)
    func contextsRetainEveryRefusal(_ fixture: ExplicitRefusalCase) throws
    {
        let source = try ExplicitFixture.source(fixture.text)
        let collection = ExplicitParagraphHyphens(source)
        #expect(!collection.records.isEmpty)
        #expect(ExplicitFixture.indices(collection).isEmpty)
        #expect(collection.records.allSatisfy
        {
            $0.outcome == .refused(fixture.refusal)
        })
        #expect(collection.records.map(\.mark) == collection.marks)
        #expect(collection.source.source.utf16 == Array(fixture.text.utf16))
        try ExplicitEvidence.write(
            "refused-" + fixture.name, collection: collection
        )
    }

    @Test(arguments: [
        HyphenationMark.nonbreakingHyphen, .wordJoiner, .zeroWidthJoiner,
        .zeroWidthNonJoiner, .zeroWidthNoBreakSpace
    ])
    func inhibitorsProtectTheCompleteMarkedGroup(_ inhibitor: HyphenationMark)
        throws
    {
        let scalar = try #require(Unicode.Scalar(inhibitor.rawValue))
        let text = "extra\u{AD}ordi" + String(scalar) + "nary"
        let source = try ExplicitFixture.source(text)
        let collection = ExplicitParagraphHyphens(source)
        #expect(collection.records.count == 2)
        let blocked = SourceHyphenationMark(mark: inhibitor, range: 10..<11)
        #expect(collection.records.map(\.outcome) == [
            .refused(.protectedGroup([blocked])), .refused(.notBreakMark)
        ])
        let slices = try ExplicitFixture.allSlices(collection)
        #expect(slices.count == 1)
        #expect(slices[0].text == "extraordi" + String(scalar) + "nary")
        _ = try ExplicitFixture.reconstructed(slices[0])
        try ExplicitEvidence.write(
            "inhibitor-\(inhibitor.rawValue)",
            collection: collection, slices: slices
        )
    }
}
