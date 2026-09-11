import Foundation
@testable import FundamentalDocument
import FundamentalNativeParagraph
import Testing

@Suite("Paragraph snapshots preserve canonical ownership")
@MainActor
struct ParagraphOwnershipTests
{
    @Test
    func retainedSourceSurvivesAnEditAndUndo() throws
    {
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let runs = [
            WordFixture.run("👩‍💻 "),
            WordFixture.scoped("extra", .link(link), traits: [.strong]),
            WordFixture.run("", traits: [.inlineCode]),
            WordFixture.run("ordinary cafe"),
            WordFixture.run("\u{301}", traits: [.emphasis])
        ]
        let session = try ParagraphSessionFixture.session(runs)
        let initial = session.state
        let source = try ParagraphSessionFixture.source(session)
        let words = try NativeParagraphWords(source: source, language: .english)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let original = try encoder.encode(source.paragraph.runs)
        #expect(session.state == initial)
        #expect(!session.isDirty && !session.canUndo && !session.canRedo)
        guard case let .editable(editable) = initial
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        let insertion = try #require(SemanticInsertion(
            text: "X ", attributes: .direct(traits: [.underline])
        ))
        let result = session.submit(.edit(
            DocumentObservation(snapshot: initial.snapshot),
            .text(.insertion(SemanticTextInsertion(
                point: editable.selection.range.start, insertion: insertion
            )))
        ))
        guard case .applied = result
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        let changed = try ParagraphSessionFixture.source(session)
        #expect(changed.source.utf16 == Array("X ".utf16) + source.source.utf16)
        #expect(session.isDirty && session.canUndo && !session.canRedo)
        #expect(try encoder.encode(source.paragraph.runs) == original)
        #expect(words.returnedUTF16 == source.source.utf16)
        let undo = session.submit(DocumentHistoryCommand(
            observation: DocumentObservation(snapshot: session.state.snapshot),
            direction: .undo
        ))
        guard case .applied = undo
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        let restored = try ParagraphSessionFixture.source(session)
        #expect(try encoder.encode(restored.paragraph.runs) == original)
        #expect(restored.source.utf16 == source.source.utf16)
        #expect(!session.isDirty && !session.canUndo && session.canRedo)
        #expect(try encoder.encode(words.source.paragraph.runs) == original)
    }
}
