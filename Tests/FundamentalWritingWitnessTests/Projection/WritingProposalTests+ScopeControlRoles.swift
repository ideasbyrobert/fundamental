import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("scope requests preserve every non-table role and raw source",
          arguments: WritingScopeKind.allCases)
    func scopeControlsRolePreservation(_ kind: WritingScopeKind) throws
    {
        let text = "Ae\u{301}😀Z"
        let run = SemanticRun(text: text, attributes: .scoped(traits: [.strong],
            scopes: try WritingScopeFixture.scopes()[2]))
        for block in try WritingInlineFixture.roles([run])
        {
            let source = try WritingTestDocument(blocks: [block],
                                                  start: 5, end: 1)
            let request = try #require(WritingScopeRequest(
                kind: kind, in: source.projection()
            ))
            let command = try #require(request.setting("Changed"))
            let result = try applied(command, to: source.state)
            let identified = try #require(result.snapshot.document.content
                .blocks.first)
            let changed = try #require(EditableSemanticBlock(
                identified.block
            ))
            #expect(changed.replacingRuns([run]) == block)
            #expect(changed.runs.flatMap { Array($0.text.utf16) } ==
                Array(text.utf16))
            #expect(changed.runs.allSatisfy { $0.traits == [.strong] })
            #expect(result.selection.range.start.utf16Offset.value == 5)
            #expect(result.selection.range.end.utf16Offset.value == 1)
        }
    }
}
