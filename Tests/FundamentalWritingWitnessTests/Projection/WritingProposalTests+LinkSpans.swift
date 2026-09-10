import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("separator-only selections have no link while uniform spans do")
    func linkOpeningSpans() throws
    {
        let linked = try WritingScopeFixture.run("A", form: 0)
        let source = try WritingTestDocument(blocks: [
            .paragraph(.init(runs: [linked])),
            .paragraph(.init(runs: [linked]))
        ])
        let projection = try source.projection()
        for pair in [(NSRange(location: 1, length: 1), false),
                     (NSRange(location: 0, length: 3), true)]
        {
            let native = try #require(projection.range(pair.0))
            for backward in [false, true]
            {
                let range = try #require(DocumentRange(
                    start: backward ? native.end : native.start,
                    end: backward ? native.start : native.end
                ))
                let successor = try applied(.select(projection.observation,
                    DocumentSelection(range: range)), to: source.state)
                let selected = try #require(WritingProjection(
                    .editable(successor)
                ))
                #expect((selected.selectedLink != nil) == pair.1)
                #expect(selected.snapshot.selection.range == range)
                #expect(selected.snapshot.snapshot.document ==
                    source.state.snapshot.document)
            }
        }
    }
}
