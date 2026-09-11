@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@MainActor
@Suite
struct ShapedOwnershipTests
{
    @Test(
        arguments: NativeWordScopeTests.allowedTraits, ["left", "mark", "right"]
    )
    func conditionalInkUsesItsOriginalRun(
        _ traits: Set<SemanticInlineTrait>, _ placement: String
    ) throws
    {
        let left: Set<SemanticInlineTrait> = placement == "left" ? traits : []
        let mark: Set<SemanticInlineTrait> = placement == "mark" ? traits : []
        let right: Set<SemanticInlineTrait> = placement == "right" ? traits : []
        let value = ExplicitParagraphHyphens(try WordFixture.source([
            WordFixture.run("extra", traits: left),
            WordFixture.run("\u{AD}", traits: mark),
            WordFixture.run("ordinary", traits: right)
        ]))
        for size in [18.0, 36.0]
        {
            let selected = try ShapingFixture.line(
                value, range: 0..<6,
                end: .opportunity(value.select(0)), size: size
            )
            let unbroken = try ShapingFixture.line(
                value, range: 0..<14, size: size
            )
            try ShapingAssertions.compare(
                selected, text: "extra‐",
                reference: ShapingReference.line(
                    [("extra", left), ("‐", mark)], size: size
                )
            )
            try ShapingAssertions.compare(
                unbroken, text: "extraordinary",
                reference: ShapingReference.line(
                    [("extra", left), ("ordinary", right)], size: size
                )
            )
            let generated = selected.runs.flatMap(\.glyphs).flatMap(\.sources)
                .filter { $0.kind == .conditionalHyphen }
            try #require(!generated.isEmpty)
            #expect(generated.allSatisfy
            {
                $0.fragment == WordRunFragment(
                    runIndex: 1, paragraphRange: 5..<6, runRange: 0..<1
                )
            })
            let names = traits.map(\.rawValue).sorted().joined(separator: "-")
            try ShapingEvidence.write(
                "traits-" + placement + "-" + names + "-" + String(Int(size)),
                lines: [selected, unbroken]
            )
        }
    }
}
