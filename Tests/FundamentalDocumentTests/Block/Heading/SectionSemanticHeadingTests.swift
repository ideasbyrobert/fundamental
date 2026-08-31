import Testing

@testable import FundamentalDocument

@Suite("A section semantic heading")
struct SectionSemanticHeadingTests
{
    @Test("initialization preserves the required level and ordered runs")
    func initializationPreservesRequiredFacts()
    {
        let runs = [
            SemanticRun(text: "First"),
            SemanticRun(
                text: "Second",
                traits: [.strong]
            )
        ]
        for level in SemanticHeadingLevel.allCases
        {
            let heading = SectionSemanticHeading(
                runs: runs,
                level: level
            )

            #expect(heading.runs == runs)
            #expect(heading.level == level)
        }
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged()
    {
        let run = SemanticRun(text: "Heading")
        let original = SectionSemanticHeading(
            runs: [run],
            level: .two
        )
        let replacement = SectionSemanticHeading(
            runs: [run],
            level: .five
        )

        #expect(original.level == .two)
        #expect(replacement.level == .five)
    }
}
