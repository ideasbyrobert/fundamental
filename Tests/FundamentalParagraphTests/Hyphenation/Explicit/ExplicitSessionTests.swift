import Foundation
@testable import FundamentalDocument
import FundamentalParagraph
import Testing

@Suite("Authored hyphens preserve canonical session ownership")
@MainActor
struct ExplicitSessionTests
{
    @Test
    func editAndUndoCannotTransferAnOlderDisplaySelection() throws
    {
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let session = try ParagraphSessionFixture.session([
            WordFixture.run("extra"),
            WordFixture.run("", traits: [.inlineCode]),
            WordFixture.scoped("\u{AD}", .link(link), traits: [.strong]),
            WordFixture.run("ordinary")
        ])
        let initial = session.state
        let source = try ParagraphSessionFixture.source(session)
        let collection = ExplicitParagraphHyphens(source)
        let selection = try collection.select(0)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let original = try encoder.encode(source.paragraph.runs)
        #expect(try collection.project(0..<14).text == "extraordinary")
        #expect(try collection.project(
            0..<6, end: .opportunity(selection)
        ).text == "extra‐")
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
        let edit = session.submit(.edit(
            DocumentObservation(snapshot: initial.snapshot),
            .text(.insertion(SemanticTextInsertion(
                point: editable.selection.range.start, insertion: insertion
            )))
        ))
        guard case .applied = edit
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        let changed = ExplicitParagraphHyphens(
            try ParagraphSessionFixture.source(session)
        )
        #expect(session.isDirty && session.canUndo && !session.canRedo)
        #expect(changed.source.source.utf16
            == Array("X ".utf16) + source.source.utf16)
        #expect(throws: ExplicitProjectionFailure.foreignSelection)
        {
            try changed.project(0..<6, end: .opportunity(selection))
        }
        let undo = session.submit(DocumentHistoryCommand(
            observation: DocumentObservation(snapshot: session.state.snapshot),
            direction: .undo
        ))
        guard case .applied = undo
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        let restored = ExplicitParagraphHyphens(
            try ParagraphSessionFixture.source(session)
        )
        #expect(try encoder.encode(restored.source.paragraph.runs) == original)
        #expect(try encoder.encode(collection.source.paragraph.runs)
            == original)
        #expect(throws: ExplicitProjectionFailure.foreignSelection)
        {
            try restored.project(0..<6, end: .opportunity(selection))
        }
        let retained = try collection.project(
            0..<6, end: .opportunity(selection)
        )
        #expect(retained.text == "extra‐")
        #expect(try ExplicitFixture.reconstructed(retained)
            == Array(source.source.utf16[0..<6]))
        #expect(!session.isDirty && !session.canUndo && session.canRedo)
    }
}
