@testable import FundamentalParagraph
import Testing

@Suite
struct ExplicitProjectionTests
{
    @Test(arguments: ExplicitCases.all)
    func literalDisplayAndCompleteSourceCoverage(_ fixture: ExplicitCase) throws
    {
        let source = try ExplicitFixture.source(
            fixture.text, language: fixture.language
        )
        let collection = ExplicitParagraphHyphens(source)
        let count = source.source.utf16.count
        let unbroken = try collection.project(0..<count)
        #expect(unbroken.text.utf16.elementsEqual(fixture.unbroken.utf16))
        #expect(unbroken.atoms.allSatisfy { $0.kind != .conditionalHyphen })
        #expect(unbroken.atoms.filter { $0.kind == .suppressedSoftHyphen }.count
            == fixture.text.utf16.filter { $0 == 173 }.count)
        var slices = [unbroken]
        _ = try ExplicitFixture.reconstructed(unbroken)
        let indices = ExplicitFixture.indices(collection)
        #expect(indices.count == fixture.breaks.count)
        for (index, expected) in zip(indices, fixture.breaks)
        {
            let value = try collection.opportunity(at: index)
            #expect(value.sourceOffset == expected.offset)
            #expect(value.ink == expected.ink)
            let left = try collection.project(
                0..<expected.offset, end: .opportunity(collection.select(index))
            )
            let right = try collection.project(expected.offset..<count)
            #expect(left.text.utf16.elementsEqual(expected.prefix.utf16))
            #expect(right.text.utf16.elementsEqual(expected.suffix.utf16))
            let replacements = left.atoms.filter
            {
                $0.kind == .conditionalHyphen
            }
            #expect(replacements.count == (
                expected.ink == .conditionalHyphen ? 1 : 0
            ))
            #expect(right.atoms.allSatisfy { $0.kind != .conditionalHyphen })
            let recovered = try ExplicitFixture.reconstructed(left)
                + ExplicitFixture.reconstructed(right)
            #expect(recovered == Array(fixture.text.utf16))
            slices += [left, right]
        }
        #expect(collection.source.paragraph == source.paragraph)
        #expect(collection.source.source.utf16 == Array(fixture.text.utf16))
        try ExplicitEvidence.write(
            fixture.name, collection: collection, slices: slices
        )
    }
}
