import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("unchanged visible text retains a real exact-scope rewrite",
          arguments: [false, true])
    func nativeScopeSameSpelling(_ linked: Bool) throws
    {
        let attributes = try [" é ", " e\u{301} "].map
        {
            value in
            let scope: SemanticRunScopes = linked
                ? .link(try #require(SemanticLinkDestination(value)))
                : .language(try #require(SemanticLanguageIdentifier(value)))
            return SemanticRunAttributes.scoped(traits: [.strong],
                                                scopes: scope)
        }
        let source = try WritingTestDocument(blocks: [.paragraph(
            SemanticParagraph(runs: [
                SemanticRun(text: "A", attributes: attributes[0]),
                SemanticRun(text: "B", attributes: attributes[1])
            ])
        )], start: 0, end: 2)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let before = window.storage
        window.mark("AB")
        #expect(window.storage == before)
        window.commit("AB")
        #expect(window.view.string == "AB")
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.isDirty)
        #expect(try WritingInlineFixture.runs(window.session.document) == [
            SemanticRun(text: "AB", attributes: attributes[0])
        ])
        let after = window.session.document.content
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        #expect(!window.session.isDirty)
        window.view.redoCanonicalEdit(nil)
        #expect(window.session.document.content == after)
    }
}
