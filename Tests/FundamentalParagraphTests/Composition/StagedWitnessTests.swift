@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct StagedWitnessTests
{
    @Test func ordinaryWitnessesKeepNativePlansWithLessWork() throws
    {
        for (index, original) in try ComposerWitness.paragraphs().enumerated()
        {
            let full = try TerminalComposition(original)
            let result = try StagedAssertions.compare(
                "witness-\(index)", original: original, width: original.width
            )
            let before = full.paragraph.segments.reduce(0)
            {
                $0 + $1.nativeMeasurements
            }
            let after = result.paragraph.segments.reduce(0)
            {
                $0 + $1.nativeMeasurements
            }
            #expect(after * 5 <= before)
            #expect(result.searches.allSatisfy
            {
                !$0.usedFallback
            })
        }
    }
}
