import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("scope sheet completion cannot edit a superseded selection",
          arguments: WritingScopeKind.allCases, [false, true])
    func scopeControlsSheetStale(_ kind: WritingScopeKind, remove: Bool)
        async throws
    {
        let source = try WritingScopeControlFixture.document(kind: kind)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let sheet = try window.openScopeSheet(kind)
        window.setScopeValue("Changed", in: sheet)
        let proposal = try #require(WritingSelectionProposal(
            ranges: [NSRange(location: 0, length: 0)],
            in: window.controller.bridge.projection
        ))
        window.session.submit(proposal.command)
        window.controller.bridge.project(in: window.view)
        let current = window.storage
        try await window.finishScopeSheet(sheet, response: remove
            ? .alertThirdButtonReturn : .alertFirstButtonReturn)
        #expect(window.storage == current)
        #expect(window.session.document == source.state.snapshot.document)
        #expect(window.view.selectedRange() == NSRange(location: 0, length: 0))
        #expect(!window.session.isDirty && window.session.history.undo.isEmpty)
        #expect(window.controller.documentWindow.firstResponder === window.view)
    }
}
