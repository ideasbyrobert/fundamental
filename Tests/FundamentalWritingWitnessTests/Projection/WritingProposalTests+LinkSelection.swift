import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("link opening uses existing caret context and exact selected links")
    func linkOpeningSelection() throws
    {
        let linked = try WritingScopeFixture.run("e\u{301}😀", form: 2)
        let block = SemanticBlock.paragraph(.init(runs: [
            SemanticRun(text: "A"), SemanticRun(text: ""), linked,
            SemanticRun(text: "Z")
        ]))
        for offset in [0, 1, 3, 5, 6]
        {
            let source = try WritingTestDocument(blocks: [block],
                                                  start: offset, end: offset)
            let projection = try source.projection()
            #expect((projection.selectedLink != nil) ==
                [3, 5].contains(offset))
        }
        for pair in [(1, 5, true), (5, 1, true), (0, 5, false), (1, 6, false)]
        {
            let source = try WritingTestDocument(blocks: [block],
                                                  start: pair.0, end: pair.1)
            #expect((try source.projection().selectedLink != nil) == pair.2)
        }
        let projection = try WritingTestDocument(blocks: [block]).projection()
        for index in [Int.min, -1, 0, 1, 2, 3, 4, 5, 6, Int.max]
        {
            #expect((projection.link(at: index) != nil) ==
                (1 ... 4).contains(index))
        }
    }

    @Test("typing-only links cannot replace an existing navigation target")
    func linkOpeningTypingIntent() throws
    {
        for linked in [false, true]
        {
            let run = linked ? try WritingScopeFixture.run("A", form: 0) :
                SemanticRun(text: "A")
            let state = try WritingTestDocument(
                blocks: [.paragraph(.init(runs: [run]))], start: 1, end: 1
            ).state
            let projection = try #require(WritingProjection(state))
            let target = try #require(SemanticLinkDestination(
                "https://future.invalid"
            ))
            let successor = try applied(.typingScope(projection.observation,
                .link(target)), to: state)
            let current = try #require(WritingProjection(.editable(successor)))
            #expect(current.snapshot.typingAttributes(
                in: current.snapshot.selection.range
            ) == .scoped(traits: [], scopes: .link(target)))
            #expect(current.selectedLink == projection.selectedLink)
            #expect((WritingLinkRequest(in: current) != nil) == linked)
        }
        #expect(try WritingTestDocument().projection().selectedLink == nil)
    }
}
