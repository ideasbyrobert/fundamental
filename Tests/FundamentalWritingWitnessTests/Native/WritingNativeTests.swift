import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite(.serialized)
struct WritingNativeTests
{
    @Test
    func emptySeedOwnsFreshIdentityAndZeroCounters() throws
    {
        let first = try #require(WritingDocumentSeed())
        let second = try #require(WritingDocumentSeed())
        let projection = try #require(WritingProjection(first.state))
        #expect(projection.text.isEmpty)
        #expect(projection.selection == NSRange(location: 0, length: 0))
        #expect(first.state.snapshot.generation == .zero)
        #expect(first.state.snapshot.document.revision == .zero)
        let lhs = first.state.snapshot.document
        let rhs = second.state.snapshot.document
        #expect(lhs.documentID != rhs.documentID)
        #expect(lhs.content.blocks[0].blockID != rhs.content.blocks[0].blockID)
        guard case let .paragraph(paragraph) = lhs.content.blocks[0].block
        else
        {
            Issue.record("seed is not a paragraph")
            return
        }
        #expect(paragraph.runs.isEmpty)
    }

    @Test
    func nativeConfigurationKeepsTextKitTwoAndCanonicalUndo() throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        try window.expect("", selection: NSRange(location: 0, length: 0))
        #expect(!window.view.isRichText)
        #expect(!window.view.importsGraphics)
        #expect(!window.view.smartInsertDeleteEnabled)
        #expect(window.view.writingToolsBehavior == .none)
        #expect(window.view.accessibilityLabel() == "Fundamental document")
        #expect(window.controller.documentWindow.styleMask.contains(.titled))
        #expect(window.controller.documentWindow.title ==
            "Fundamental Writing Witness — Unsaved")
        #expect(window.session.history.undo.isEmpty)
        #expect(window.session.state.snapshot.generation.value == 3)
    }
}
