import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("ending native scopes clears only the intended typing attributes")
    func nativeScopeBoundary() throws
    {
        let first = try WritingScopeFixture.run("A", form: 2, traits: [.strong])
        let last = SemanticRun(text: "B", traits: [.emphasis])
        let source = try WritingTestDocument(blocks: [.paragraph(
            SemanticParagraph(runs: [first, last])
        )])
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        defer
        {
            window.close()
        }
        window.select(1)
        try WritingScopeFixture.choose(.link(nil), in: window)
        WritingScopeFixture.expect(1, in: window.view.typingAttributes)
        try window.key("x", code: 7)
        try WritingScopeFixture.choose(.language(nil), in: window)
        #expect(window.view.typingAttributes[.link] == nil)
        #expect(window.view.typingAttributes[.languageIdentifier] == nil)
        try window.key("y", code: 16)
        #expect(window.view.string == "AxyB")
        #expect(try WritingInlineFixture.runs(window.session.document) == [
            first,
            try WritingScopeFixture.run("x", form: 1, traits: [.strong]),
            SemanticRun(text: "y", traits: [.strong]), last
        ])
        window.select(0)
        WritingScopeFixture.expect(2, in: window.view.typingAttributes)
        try window.key("z", code: 6)
        #expect(window.view.string == "zAxyB")
        let inserted = try #require(WritingInlineFixture.runs(
            window.session.document
        ).first)
        #expect(try inserted == WritingScopeFixture.run(
            "z", form: 2, traits: [.strong]
        ))
        #expect(window.session.history.undo.count == 3)
    }
}
