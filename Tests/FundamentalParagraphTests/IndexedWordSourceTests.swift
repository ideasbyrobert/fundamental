@testable import FundamentalParagraph
import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@Suite
struct IndexedWordSourceTests
{
    @Test(arguments: [1, 64, 4096])
    func actualWordQueriesVisitOnlyMatchingSource(_ count: Int) throws
    {
        let foreign = try WordFixture.language("ru_RU")
        let runs = (0..<count).flatMap
        {
            _ in
            [WordFixture.run("word\n", traits: [.strong]),
             WordFixture.scoped("", .language(foreign), traits: [.inlineCode])]
        }
        let source = try WordFixture.source(runs)
        let start = (count - 1) * 5
        let range = start..<(start + 4)
        let fragments = source.fragments(in: range)
        let endings = source.endings(in: range)
        let limit = 2 * (Int.bitWidth - count.leadingZeroBitCount)
        #expect(source.spans.count == count * 2)
        #expect(source.occupiedSpans.count == count)
        #expect(source.hardEndings.count == count)
        #expect(fragments.fragments == [
            .init(runIndex: (count - 1) * 2,
                  paragraphRange: range, runRange: 0..<4)
        ])
        #expect(fragments.searchComparisons <= limit)
        #expect(fragments.visitedRuns == 1)
        #expect(endings.searchComparisons <= limit)
        #expect(endings.visitedEndings == 0)
        #expect(endings.ranges.isEmpty)
        let scope = try WordFixture.resolved(source.resolve(range))
        #expect(scope.fragments == fragments.fragments)
        #expect(scope.language.value == "en_US")
        let inclusive = start..<(start + 5)
        let included = source.endings(in: inclusive)
        #expect(included.visitedEndings == 1)
        #expect(included.ranges == [(start + 4)..<(start + 5)])
        #expect(source.resolve(inclusive) == .refused(
            inclusive, [.hardEndings(included.ranges)]
        ))
        let linear = LinearWordOracle.fragments(in: range, source: source)
        let oldEndings = LinearWordOracle.endings(in: range, source: source)
        #expect(linear.values == fragments.fragments)
        #expect(oldEndings.values == endings.ranges)
        #expect(linear.reads == count * 2)
        #expect(oldEndings.reads == count + 1)
        if count >= 64
        {
            #expect(linear.reads > limit + fragments.fragments.count)
            #expect(oldEndings.reads > limit + endings.ranges.count)
        }
        try RangeEvidence.record("source-\(count)", values: [
            "sourceRuns": source.spans.count, "occupiedRuns": count,
            "spanSearchComparisons": fragments.searchComparisons,
            "visitedRuns": fragments.visitedRuns,
            "endingSearchComparisons": endings.searchComparisons,
            "visitedEndings": endings.visitedEndings,
            "linearSpanReads": linear.reads,
            "linearEndingReads": oldEndings.reads
        ])
    }

    @Test
    func languageKeysKeepExactSpellingAndFirstOccurrence() throws
    {
        let first = try WordFixture.language("é")
        let second = try WordFixture.language("e\u{301}")
        let third = try WordFixture.language("ru_RU")
        let languages = [first, second, third, first, second]
        let source = try WordFixture.source(languages.map
        {
            WordFixture.scoped("a", .language($0))
        })
        #expect(source.resolve(0..<5) == .refused(
            0..<5, [.incompatibleLanguages([first, second, third])]
        ))
    }
}
