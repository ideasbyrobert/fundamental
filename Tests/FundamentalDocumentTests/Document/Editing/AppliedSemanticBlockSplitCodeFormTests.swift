import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockSplitTests
{
    @Test("both code forms and line endings remain exact")
    func codeFormsAndLineEndingsRemainExact() throws
    {
        let scopeValues = try SemanticRunAttributesTests.scopes()
        let scopes = try #require(scopeValues.last)
        let prefix = "A\r\n"
        let suffix = "B\nC\rD"
        let prefixRun = SemanticRun(text: prefix, traits: [.strong])
        let suffixRun = SemanticRun(
            text: suffix,
            attributes: .scoped(traits: [.emphasis], scopes: scopes)
        )
        let sourceRuns = [prefixRun, suffixRun]
        let forms = try [
            (
                Self.plainCode(sourceRuns),
                Self.plainCode([prefixRun]),
                Self.plainCode([suffixRun])
            ),
            (
                Self.taggedCode(sourceRuns, language: "hy"),
                Self.taggedCode([prefixRun], language: "hy"),
                Self.taggedCode([suffixRun], language: "hy")
            )
        ]

        for form in forms
        {
            let source = try Self.document(blocks: [(2, form.0)])
            let candidate = try Self.apply(at: 3, in: source)
            let result = try #require(candidate)
            let actual = result.document.content.blocks

            #expect(Self.scalarValues(try Self.text(in: result, at: 0)) ==
                Self.scalarValues(prefix))
            #expect(Self.scalarValues(try Self.text(in: result, at: 1)) ==
                Self.scalarValues(suffix))
            #expect(actual[0].block == form.1)
            #expect(actual[1].block == form.2)
        }
    }
}
