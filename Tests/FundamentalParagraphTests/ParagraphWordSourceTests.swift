@testable import FundamentalParagraph
import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@Suite
struct ParagraphWordSourceTests
{
    @Test
    func retainsExactTextAttributesAndEmptyRuns() throws
    {
        let other = try WordFixture.language("ru_RU")
        let runs = [
            WordFixture.run("👩‍💻", traits: [.strong]),
            WordFixture.scoped("", .language(other), traits: [.inlineCode]),
            WordFixture.run(" "), WordFixture.run("caf"),
            WordFixture.run("e", traits: [.emphasis]),
            WordFixture.run("\u{301}", traits: [.underline])
        ]
        let value = try WordFixture.source(runs)
        #expect(value.source.utf16 == [
            55357, 56425, 8205, 55357, 56507, 32, 99, 97, 102, 101, 769
        ])
        #expect(value.source.graphemeBoundaries == [0, 5, 6, 7, 8, 9, 11])
        #expect(value.spans.map(\.range) == [
            0..<5, 5..<5, 5..<6, 6..<9, 9..<10, 10..<11
        ])
        #expect(value.spans.map(\.index) == [0, 1, 2, 3, 4, 5])
        #expect(value.spans.map(\.attributes) == runs.map(\.attributes))
        for (original, retained) in zip(runs, value.paragraph.runs)
        {
            #expect(original.text.utf16.elementsEqual(retained.text.utf16))
            #expect(original.attributes == retained.attributes)
        }
        let scope = try WordFixture.resolved(value.resolve(6..<11))
        #expect(scope.language.value == "en_US")
        #expect(scope.fragments == [
            .init(runIndex: 3, paragraphRange: 6..<9, runRange: 0..<3),
            .init(runIndex: 4, paragraphRange: 9..<10, runRange: 0..<1),
            .init(runIndex: 5, paragraphRange: 10..<11, runRange: 0..<1)
        ])
    }

    @Test
    func emptyParagraphKeepsAnExplicitSource() throws
    {
        let empty = try WordFixture.source([])
        #expect(empty.source.utf16.isEmpty)
        #expect(empty.source.graphemeBoundaries == [0])
        #expect(empty.spans.isEmpty)
        #expect(empty.resolve(0..<0) == .refused(0..<0, [.emptyRange]))
    }
}
