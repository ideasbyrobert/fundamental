import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("inline selection state excludes empty runs and generated separators")
    func inlineSelectionState() throws
    {
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "Ae\u{301}", traits: [.strong]),
                SemanticRun(text: "", traits: [.emphasis])
            ])), .paragraph(SemanticParagraph(runs: [])),
            .code(.plain(PlainSemanticCodeBlock(runs: [
                SemanticRun(text: "B", traits: [.strong, .emphasis])
            ])))
        ])
        let projection = try source.projection()
        let selected = try #require(WritingSelectionProposal(
            ranges: [NSRange(location: 0, length: projection.text.utf16.count)],
            in: projection
        ))
        let state = try applied(selected.command, to: source.state)
        let selectedProjection = try #require(WritingProjection(
            .editable(state)
        ))
        let observed = try #require(WritingInlineSelection(selectedProjection))
        #expect(observed.state(of: .strong) == .on)
        #expect(observed.state(of: .emphasis) == .mixed)
        #expect(observed.state(of: .underline) == .off)
        let seam = try #require(WritingSelectionProposal(
            ranges: [NSRange(location: 3, length: 2)], in: projection
        ))
        let empty = try applied(seam.command, to: source.state)
        let emptyProjection = try #require(WritingProjection(.editable(empty)))
        #expect(WritingInlineSelection(emptyProjection) == nil)
    }
}
