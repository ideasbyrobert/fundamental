import Testing

@testable import FundamentalDocument

@Suite("A semantic heading")
struct SemanticHeadingTests
{
    @Test("both forms expose only their exact occupied facts")
    func formsExposeExactOccupiedFacts()
    {
        let titleRun = SemanticRun(text: "Title")
        let sectionRun = SemanticRun(text: "Section")
        let title = SemanticHeading.title(
            TitleSemanticHeading(runs: [titleRun])
        )
        let section = SemanticHeading.section(
            SectionSemanticHeading(
                runs: [sectionRun],
                level: .four
            )
        )

        #expect(title.runs == [titleRun])
        #expect(title.level == .one)
        #expect(section.runs == [sectionRun])
        #expect(section.level == .four)
    }

    @Test("empty title and level one section forms remain distinct")
    func levelOneFormsRemainDistinct()
    {
        let title = SemanticHeading.title(
            TitleSemanticHeading(runs: [])
        )
        let section = SemanticHeading.section(
            SectionSemanticHeading(
                runs: [],
                level: .one
            )
        )

        #expect(title != section)
        #expect(title.runs.isEmpty)
        #expect(section.runs.isEmpty)
        #expect(title.level == section.level)
    }
}
