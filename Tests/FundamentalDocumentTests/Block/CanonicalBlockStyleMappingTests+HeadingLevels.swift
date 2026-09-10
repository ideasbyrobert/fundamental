import Testing

@testable import FundamentalDocument

extension CanonicalBlockStyleMappingTests
{
    @Test("every section style preserves its exact level",
          arguments: SemanticHeadingLevel.allCases)
    func sectionStylePreservesExactLevel(_ level: SemanticHeadingLevel) throws
    {
        let runs = [SemanticRun(text: "Heading e\u{301}😀")]
        let original = SemanticBlock.heading(.section(SectionSemanticHeading(
            runs: runs, level: level
        )))
        let style = try #require(CanonicalBlockStyle(original))
        #expect(style.semanticBlock(runs: runs) == original)
        #expect(style.headingLevel == level.rawValue)
    }

    @Test("the title command stays distinct from section one")
    func titleStyleRemainsDistinctFromSectionOne() throws
    {
        let title = SemanticBlock.heading(.title(
            TitleSemanticHeading(runs: [])
        ))
        let section = SemanticBlock.heading(.section(SectionSemanticHeading(
            runs: [], level: .one
        )))
        let titleStyle = try #require(CanonicalBlockStyle(title))
        let sectionStyle = try #require(CanonicalBlockStyle(section))
        #expect(titleStyle != sectionStyle)
        #expect(titleStyle.semanticBlock(runs: []) == title)
    }
}
