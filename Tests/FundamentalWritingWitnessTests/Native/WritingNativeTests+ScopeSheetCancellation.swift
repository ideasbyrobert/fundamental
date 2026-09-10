import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("mixed scope sheets preserve cancellation and document ownership",
          arguments: WritingScopeKind.allCases)
    func scopeControlsSheetCancellation(_ kind: WritingScopeKind) async throws
    {
        let source = try WritingScopeControlFixture.document(kind: kind)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        let before = window.storage
        let item = try window.formatChoice(kind.title + "…",
                                            group: "Text Style")
        #expect(window.controller.validateUserInterfaceItem(item))
        #expect(item.state == .mixed)
        let sheet = try window.openScopeSheet(kind)
        #expect(sheet.field.stringValue.isEmpty)
        #expect(sheet.field.placeholderString == "Multiple values")
        #expect(!sheet.alert.buttons[0].isEnabled)
        #expect(sheet.alert.buttons[2].isEnabled)
        #expect(window.controller.hasFormattingSheet)
        #expect(!window.controller.canFormatSelection)
        #expect(!window.controller.mayClose())
        let save = NSMenuItem(title: "Save",
            action: #selector(WritingWindowController.saveDocument(_:)),
            keyEquivalent: "s")
        #expect(!window.controller.validateUserInterfaceItem(save))
        #expect(await window.controller.performSave(choosingLocation: false,
                                                    closing: false) == false)
        window.setScopeValue("Cancelled", in: sheet)
        try await window.finishScopeSheet(sheet,
                                          response: .alertSecondButtonReturn)
        #expect(!window.controller.hasFormattingSheet)
        #expect(window.storage == before)
        #expect(window.session.document == source.state.snapshot.document)
        #expect(window.session.history.undo.isEmpty)
        #expect(window.view.selectedRange() == NSRange(location: 0, length: 2))
        #expect(window.controller.documentWindow.firstResponder === window.view)
    }
}
