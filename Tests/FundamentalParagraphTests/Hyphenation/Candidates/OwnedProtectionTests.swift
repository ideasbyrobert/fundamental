@testable import FundamentalParagraph
import Testing

@Suite
struct OwnedProtectionTests
{
    @Test(arguments: HyphenationMark.allCases, ["inside", "before", "after"])
    func marksProtectCompleteAndSplitNativeWords(
        _ mark: HyphenationMark, _ position: String
    ) throws
    {
        let scalar = try #require(Unicode.Scalar(mark.rawValue))
        let content: String
        switch position
        {
        case "inside":
            content = "extra" + String(scalar) + "ordinary"
        case "before":
            content = String(scalar) + "extraordinary"
        default:
            content = "extraordinary" + String(scalar)
        }
        let source = try WordFixture.source([WordFixture.run(content)])
        let experiment = try OwnedEvidence.observe(
            "mark-\(mark.rawValue)-" + position, source: source
        )
        #expect(!experiment.collection.records.isEmpty)
        #expect(experiment.requests.isEmpty)
        for record in experiment.collection.records
        {
            switch record.outcome
            {
            case let .protectedMarks(marks):
                #expect(marks.map(\.mark) == [mark])
            case .sourceRefused:
                guard case .refused(_, [.graphemeBoundary]) =
                    record.word.resolution
                else
                {
                    throw WordFixtureFailure.invalidValue
                }
            default:
                throw WordFixtureFailure.invalidValue
            }
        }
        #expect(source.source.utf16 == Array(content.utf16))
    }

    @Test
    func semanticRefusalsAndTokenFlagsPreventAllLookup() throws
    {
        let code = try WordFixture.source([
            WordFixture.run("extra"),
            WordFixture.run("ordinary", traits: [.inlineCode])
        ])
        let conflict = try WordFixture.source([
            WordFixture.run("extra"),
            WordFixture.scoped(
                "ordinary", .language(WordFixture.language("ru_RU"))
            )
        ])
        for (name, source) in [("code", code), ("conflict", conflict)]
        {
            let experiment = try OwnedEvidence.observe(name, source: source)
            #expect(experiment.requests.isEmpty)
            let record = try #require(experiment.collection.records.first)
            guard case .sourceRefused = record.outcome
            else
            {
                throw WordFixtureFailure.invalidValue
            }
        }
        let flags = try OwnedEvidence.observe(
            "flags", source: WordFixture.source([WordFixture.run("123 👩‍💻")])
        )
        #expect(flags.collection.records.map(\.word.flags) == [1, 4])
        #expect(flags.requests.isEmpty)
    }
}
